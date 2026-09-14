//
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import '../models/order_history_response_model.dart';
import '../models/order_invoice_response_model.dart';
import '../models/order_model.dart';
import '../models/order_track_response_model.dart';
import '../services/orders_repository.dart';

class OrdersController extends GetxController {
  final OrdersRepository _ordersRepo = OrdersRepository();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);
  final Rx<OrderHistoryItem?> selectedOrderDetails = Rx<OrderHistoryItem?>(
    null,
  );
  final Rx<OrderTrackData?> orderTrackingData = Rx<OrderTrackData?>(null);
  final Rx<OrderInvoiceData?> orderInvoiceData = Rx<OrderInvoiceData?>(null);

  final RxBool isLoading = false.obs;

  /// True only while fetching an additional page (pagination),
  /// separate from `isLoading` which is for the very first load /
  /// pull-to-refresh. UI uses this to show a small bottom loader
  /// instead of the full-screen spinner.
  final RxBool isLoadingMore = false.obs;

  final RxBool isDetailsLoading = false.obs;
  final RxBool isTrackingLoading = false.obs;
  final RxBool isInvoiceLoading = false.obs;
  final RxBool isCancelling = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 0.obs;
  final RxBool hasMorePages = true.obs;

  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  /// Sorts newest orders first. Called after every fetch/merge so the
  /// list order stays correct regardless of what page data arrived on
  /// or the backend's own ordering.
  void _sortNewestFirst() {
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  Future<void> fetchOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 0;
      hasMorePages.value = true;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _ordersRepo.getOrderHistory(
        page: currentPage.value,
        size: _pageSize,
      );

      if (response != null && response.data != null) {
        final content = response.data!.content ?? [];
        final fetchedOrders = content
            .map((item) => OrderModel.fromHistoryItem(item))
            .toList();

        if (isRefresh || currentPage.value == 0) {
          orders.assignAll(fetchedOrders);
        } else {
          orders.addAll(fetchedOrders);
        }

        _sortNewestFirst();

        final totalPages = response.data!.totalPages ?? 1;
        if (currentPage.value + 1 >= totalPages || fetchedOrders.isEmpty) {
          hasMorePages.value = false;
        }

        if (orders.isNotEmpty && selectedOrder.value == null) {
          selectedOrder.value = orders.first;
        }
      } else {
        if (isRefresh || currentPage.value == 0) {
          orders.clear();
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads the next page of order history and appends it to the
  /// existing list (used for pagination / infinite scroll).
  ///
  /// Guards against duplicate calls while a fetch is already in
  /// flight, and stops once the backend reports no more pages.
  Future<void> loadMoreOrders() async {
    if (isLoading.value || isLoadingMore.value) return;
    if (!hasMorePages.value) return;

    isLoadingMore.value = true;
    hasError.value = false;

    try {
      final nextPage = currentPage.value + 1;
      final response = await _ordersRepo.getOrderHistory(
        page: nextPage,
        size: _pageSize,
      );

      if (response != null && response.data != null) {
        final content = response.data!.content ?? [];
        final fetchedOrders = content
            .map((item) => OrderModel.fromHistoryItem(item))
            .toList();

        if (fetchedOrders.isNotEmpty) {
          // Avoid duplicate entries if the same order somehow comes
          // back again (e.g. list shifted between calls).
          final existingIds = orders.map((o) => o.id).toSet();
          final newOnes = fetchedOrders
              .where((o) => !existingIds.contains(o.id))
              .toList();

          orders.addAll(newOnes);
          _sortNewestFirst();
          currentPage.value = nextPage;
        }

        final totalPages = response.data!.totalPages ?? 1;
        if (nextPage + 1 >= totalPages || fetchedOrders.isEmpty) {
          hasMorePages.value = false;
        }
      } else {
        hasMorePages.value = false;
      }
    } catch (e) {
      // Don't blow away the existing list on a pagination error —
      // just surface it and let the user retry by scrolling again.
      errorMessage.value = e.toString();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    if (orderId.isEmpty) return;
    isDetailsLoading.value = true;
    try {
      final response = await _ordersRepo.getOrderDetails(orderId);
      if (response != null && response.data != null) {
        selectedOrderDetails.value = response.data;
        selectedOrder.value = OrderModel.fromHistoryItem(response.data!);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<void> fetchOrderTrack(String orderId) async {
    if (orderId.isEmpty) return;
    isTrackingLoading.value = true;
    try {
      final response = await _ordersRepo.getOrderTrack(orderId);
      if (response != null && response.data != null) {
        orderTrackingData.value = response.data;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isTrackingLoading.value = false;
    }
  }

  Future<void> fetchOrderInvoice(String orderId) async {
    if (orderId.isEmpty) return;
    isInvoiceLoading.value = true;
    try {
      final response = await _ordersRepo.getOrderInvoice(orderId);
      if (response != null && response.data != null) {
        orderInvoiceData.value = response.data;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isInvoiceLoading.value = false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    if (orderId.isEmpty || isCancelling.value) return false;
    isCancelling.value = true;
    try {
      final response = await _ordersRepo.cancelOrder(orderId);
      if (response != null && response.success == true) {
        final index = orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final existing = orders[index];
          orders[index] = OrderModel(
            id: existing.id,
            orderDate: existing.orderDate,
            status: OrderStatus.cancelled,
            subtotal: existing.subtotal,
            deliveryFee: existing.deliveryFee,
            tax: existing.tax,
            discount: existing.discount,
            totalAmount: existing.totalAmount,
            deliveryAddress: existing.deliveryAddress,
            paymentMethod: existing.paymentMethod,
            items: existing.items,
            driverName: existing.driverName,
            driverPhone: existing.driverPhone,
            estimatedDeliveryTime: existing.estimatedDeliveryTime,
            orderNumber: existing.orderNumber,
            shopName: existing.shopName,
            shopBusinessPhone: existing.shopBusinessPhone,
            deliveryAgentName: existing.deliveryAgentName,
            deliveryAgentPhone: existing.deliveryAgentPhone,
            canTrack: false,
            canReorder: existing.canReorder,
            canCancel: false,
          );
          if (selectedOrder.value?.id == orderId) {
            selectedOrder.value = orders[index];
          }
        }
        Get.snackbar(
          AppStrings.myOrders,
          AppStrings.orderCancelledSuccess,
          backgroundColor: AppColors.primary,
          colorText: AppColors.surface,
        );
        return true;
      } else {
        Get.snackbar(
          AppStrings.error,
          response?.message ?? AppStrings.failedToCancelOrder,
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.unexpectedError,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  List<OrderModel> get activeOrders => orders
      .where(
        (o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled,
      )
      .toList();

  List<OrderModel> get completedOrders => orders
      .where(
        (o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.cancelled,
      )
      .toList();

  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
    fetchOrderDetails(order.id);
    fetchOrderTrack(order.id);
    fetchOrderInvoice(order.id);
  }

  final RxBool isRating = false.obs;
  final RxBool isReordering = false.obs;

  Future<bool> rateOrder(
    String orderId,
    int ratingValue,
    String comment,
  ) async {
    if (orderId.isEmpty || isRating.value) return false;
    isRating.value = true;
    try {
      final response = await _ordersRepo.rateOrder(
        orderId,
        ratingValue,
        comment,
      );
      if (response != null && response.success == true) {
        Get.snackbar(
          AppStrings.success,
          response.message ?? AppStrings.orderRatedSuccess,
          backgroundColor: AppColors.primary,
          colorText: AppColors.surface,
        );
        return true;
      } else {
        Get.snackbar(
          AppStrings.error,
          response?.message ?? AppStrings.failedToRateOrder,
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return false;
    } finally {
      isRating.value = false;
    }
  }

  Future<bool> reorder(String orderId) async {
    if (orderId.isEmpty || isReordering.value) return false;
    isReordering.value = true;
    try {
      final response = await _ordersRepo.reorder(orderId);
      if (response != null && response.success == true) {
        Get.snackbar(
          AppStrings.success,
          response.message ?? AppStrings.orderReorderedSuccess,
          backgroundColor: AppColors.primary,
          colorText: AppColors.surface,
        );
        return true;
      } else {
        Get.snackbar(
          AppStrings.error,
          response?.message ?? AppStrings.failedToReorder,
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return false;
    } finally {
      isReordering.value = false;
    }
  }

  void addOrder(OrderModel order) {
    orders.insert(0, order);
    selectedOrder.value = order;
  }
}
