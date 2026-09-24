//
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import '../models/notification_model.dart';
import '../services/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo = NotificationRepository();

  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxInt currentPage = 0.obs;
  final RxBool hasMorePages = true.obs;

  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 0;
      hasMorePages.value = true;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    hasError.value = false;

    final result = await _repo.getNotifications(
      page: currentPage.value,
      size: _pageSize,
    );

    isLoading.value = false;

    if (result == null || !result.success || result.data == null) {
      hasError.value = true;
      return;
    }

    final items = result.data!.content;
    if (isRefresh) {
      notifications.assignAll(items);
    } else {
      notifications.addAll(items);
    }

    final totalPages = result.data!.totalPages;
    hasMorePages.value = currentPage.value < totalPages - 1;
  }

  Future<void> loadMore() async {
    if (!hasMorePages.value || isLoadingMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    currentPage.value++;

    final result = await _repo.getNotifications(
      page: currentPage.value,
      size: _pageSize,
    );

    isLoadingMore.value = false;

    if (result?.success == true && result?.data != null) {
      notifications.addAll(result!.data!.content);
      hasMorePages.value = currentPage.value < result.data!.totalPages - 1;
    } else {
      currentPage.value--;
    }
  }

  final RxSet<String> highlightedIds = <String>{}.obs;

  void onNotificationScreenOpened() {
    final unreadIds =
        notifications.where((n) => !n.read).map((n) => n.id).toList();
    highlightedIds.addAll(unreadIds);

    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].read) {
        notifications[i] = notifications[i].copyWith(read: true);
      }
    }
    unreadCount.value = 0;
    _repo.markAllAsRead();
  }

  void dismissHighlight(String id) {
    highlightedIds.remove(id);
  }

  Future<void> fetchUnreadCount() async {
    final count = await _repo.getUnreadCount();
    if (count != null) unreadCount.value = count;
  }

  Future<void> markAsRead(String id) async {
    dismissHighlight(id);
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || notifications[idx].read) return;

    notifications[idx] = notifications[idx].copyWith(read: true);
    if (unreadCount.value > 0) unreadCount.value--;

    final success = await _repo.markAsRead(id);
    if (!success) {
      notifications[idx] = notifications[idx].copyWith(read: false);
      if (unreadCount.value < notifications.where((n) => !n.read).length + 1) {
        unreadCount.value++;
      }
      Get.snackbar(
        AppStrings.notifications,
        AppStrings.failedToMarkRead,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> markAllAsRead({bool showSnackbar = true}) async {
    highlightedIds.clear();
    if (notifications.every((n) => n.read)) {
      unreadCount.value = 0;
      return;
    }

    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].read) {
        notifications[i] = notifications[i].copyWith(read: true);
      }
    }
    unreadCount.value = 0;

    final success = await _repo.markAllAsRead();
    if (success && showSnackbar) {
      Get.snackbar(
        AppStrings.notifications,
        AppStrings.allMarkedRead,
        backgroundColor: AppColors.success,
        colorText: AppColors.surface,
        duration: const Duration(seconds: 2),
      );
    } else if (!success) {
      await fetchNotifications(isRefresh: true);
      await fetchUnreadCount();
    }
  }
}
