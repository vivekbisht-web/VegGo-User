import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/dashboard/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final bool isHighlighted;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = isHighlighted || !notification.read;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: isNew ? AppColors.mintLight : AppColors.surface,
        padding: AppSpacing.paddingAll16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeIcon(type: notification.type, isRead: !isNew),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: isNew
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                      AppSpacing.w8,
                      Text(
                        _formatTime(notification.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h4,
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isNew) ...[
              AppSpacing.w8,
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inHours < 1) return '${diff.inMinutes}${AppStrings.minuteAgo}';
    if (diff.inDays < 1) return '${diff.inHours}${AppStrings.hourAgo}';
    return '${diff.inDays}${AppStrings.dayAgo}';
  }
}

class _TypeIcon extends StatelessWidget {
  final String type;
  final bool isRead;

  const _TypeIcon({required this.type, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(type);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isRead ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  (IconData, Color) _iconForType(String type) {
    switch (type) {
      case 'NEW_ORDER_REQUEST':
        return (Icons.shopping_bag_outlined, AppColors.primary);
      case 'ORDER_ACCEPTED':
        return (Icons.check_circle_outline_rounded, AppColors.success);
      case 'ORDER_CANCELLED':
        return (Icons.cancel_outlined, AppColors.error);
      case 'ORDER_DELIVERED':
        return (Icons.local_shipping_outlined, AppColors.secondary);
      default:
        return (Icons.notifications_none_rounded, AppColors.textSecondary);
    }
  }
}
