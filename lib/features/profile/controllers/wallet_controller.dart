import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../models/wallet_models.dart';
import '../services/wallet_service.dart';

class WalletController extends GetxController {
  final WalletService _walletService;

  WalletController({WalletService? walletService})
      : _walletService = walletService ?? WalletService();

  final RxDouble balance = 0.0.obs;
  final RxBool isBalanceLoading = false.obs;

  String get formattedBalanceForStats {
    final val = balance.value;
    if (val >= 10000000) {
      return '${AppStrings.currencySymbol}${(val / 10000000).toStringAsFixed(1)}${AppStrings.suffixCrore}';
    } else if (val >= 100000) {
      return '${AppStrings.currencySymbol}${(val / 100000).toStringAsFixed(1)}${AppStrings.suffixLakh}';
    } else if (val >= 10000) {
      return '${AppStrings.currencySymbol}${(val / 1000).toStringAsFixed(1)}${AppStrings.suffixThousand}';
    } else if (val >= 1000) {
      return '${AppStrings.currencySymbol}${val.toInt()}';
    } else {
      return '${AppStrings.currencySymbol}${val.toStringAsFixed(val % 1 == 0 ? 0 : 2)}';
    }
  }
  final RxList<WalletTransactionItem> transactions =
      <WalletTransactionItem>[].obs;
  final RxBool isTransactionsLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString selectedFilter = 'ALL'.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxString errorMessage = ''.obs;

  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    loadWalletData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value &&
          !isTransactionsLoading.value &&
          currentPage.value + 1 < totalPages.value) {
        loadMoreTransactions();
      }
    }
  }

  Future<void> loadWalletData() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(refresh: true),
    ]);
  }

  Future<void> fetchBalance() async {
    isBalanceLoading.value = true;
    try {
      final response = await _walletService.getWalletBalance();
      if (response.success && response.data != null) {
        balance.value = response.data!.balance;
      }
    } finally {
      isBalanceLoading.value = false;
    }
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      isTransactionsLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _walletService.getWalletTransactions(
        type: selectedFilter.value,
        page: currentPage.value,
        size: 20,
      );

      if (response.success && response.data != null) {
        totalPages.value = response.data!.totalPages;
        if (refresh) {
          transactions.assignAll(response.data!.content);
        } else {
          transactions.addAll(response.data!.content);
        }
      } else {
        errorMessage.value = response.message ?? '';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || currentPage.value + 1 >= totalPages.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      final response = await _walletService.getWalletTransactions(
        type: selectedFilter.value,
        page: currentPage.value,
        size: 20,
      );

      if (response.success && response.data != null) {
        transactions.addAll(response.data!.content);
        totalPages.value = response.data!.totalPages;
      } else {
        currentPage.value--;
      }
    } catch (_) {
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void changeFilter(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchTransactions(refresh: true);
  }

  Future<void> onRefresh() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(refresh: true),
    ]);
  }
}
