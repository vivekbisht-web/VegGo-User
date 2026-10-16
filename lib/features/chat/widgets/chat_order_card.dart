import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';
import '../models/chat_models.dart';

class ChatOrderCard extends StatelessWidget {
  final ChatOrder order;
  final bool enabled;
  final VoidCallback? onTap;

  const ChatOrderCard({
    super.key,
    required this.order,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(order.status);
    final placedAt = DateTime.tryParse(order.placedAt ?? '')?.toLocal();

    return Card(
      color: theme.colorScheme.surface,
      margin: AppSpacing.paddingVertical8,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: AppSpacing.paddingAll12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SelectableText(
                        order.orderNumber,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Container(
                      padding: AppSpacing.paddingSymmetric(
                        horizontal: AppSpacing.radius8,
                        vertical: AppSpacing.radius4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius12,
                        ),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  '${AppStrings.chatOrderTotal}: ${PriceFormatter.format(order.total.toDouble())}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '${AppStrings.chatOrderItems}: ${order.itemCount}',
                  style: theme.textTheme.bodySmall,
                ),
                if (placedAt != null)
                  Text(
                    '${AppStrings.chatPlacedAt}: ${DateFormat.yMMMd().add_jm().format(placedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
      case 'CONFIRMED':
      case 'PREPARING':
      case 'READY_FOR_PICKUP':
        return AppColors.warning;
      case 'OUT_FOR_DELIVERY':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
