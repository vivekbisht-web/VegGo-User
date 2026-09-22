//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/dashboard/controllers/notification_controller.dart';
import 'package:vegon_user/features/dashboard/widgets/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _NotificationAppBar(ctrl: ctrl),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (ctrl.hasError.value && ctrl.notifications.isEmpty) {
          return _ErrorState(onRetry: ctrl.fetchNotifications);
        }

        if (ctrl.notifications.isEmpty) {
          return _EmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ctrl.fetchNotifications(isRefresh: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount:
                ctrl.notifications.length + (ctrl.hasMorePages.value ? 1 : 0),
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: AppColors.borderLight.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              if (index == ctrl.notifications.length) {
                return _PaginationLoader(ctrl: ctrl);
              }
              final item = ctrl.notifications[index];
              return NotificationTile(
                notification: item,
                onTap: () => ctrl.markAsRead(item.id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final NotificationController ctrl;

  const _NotificationAppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: Get.back,
      ),
      title: Obx(() {
        final count = ctrl.unreadCount.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.notifications,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (count > 0) ...[
              AppSpacing.w8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
      actions: [
        Obx(() {
          final hasUnread = ctrl.notifications.any((n) => !n.read);
          if (!hasUnread) return const SizedBox.shrink();
          return TextButton(
            onPressed: ctrl.markAllAsRead,
            child: Text(
              AppStrings.markAllRead,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _PaginationLoader extends StatefulWidget {
  final NotificationController ctrl;

  const _PaginationLoader({required this.ctrl});

  @override
  State<_PaginationLoader> createState() => _PaginationLoaderState();
}

class _PaginationLoaderState extends State<_PaginationLoader> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => widget.ctrl.isLoadingMore.value
          ? const Padding(
              padding: AppSpacing.paddingVertical16,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: AppSpacing.screenWidth * 0.2,
            color: AppColors.borderLight,
          ),
          AppSpacing.h16,
          Text(
            AppStrings.noNewNotifications,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.h8,
          Padding(
            padding: AppSpacing.paddingHorizontal24,
            child: Text(
              AppStrings.noNewNotificationsDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: AppSpacing.screenWidth * 0.18,
            color: AppColors.borderLight,
          ),
          AppSpacing.h16,
          Text(
            AppStrings.failedToLoadNotifications,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.h16,
          TextButton(
            onPressed: onRetry,
            child: Text(
              AppStrings.tryAgain,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
