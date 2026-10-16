//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/routes/app_routes.dart';
import '../models/complaint_model.dart';
import 'complaint_status_badge.dart';

class ComplaintCard extends StatelessWidget {
  const ComplaintCard({super.key, required this.complaint});

  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.complaintDetails,
        arguments: complaint,
      ),
      child: Container(
        margin: AppSpacing.paddingOnly(bottom: 12),
        padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.complaintTicketNumber}${complaint.ticketNumber}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.w8,
                ComplaintStatusBadge(status: complaint.status),
              ],
            ),
            AppSpacing.h8,
            Text(
              complaint.title,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.h4,
            Text(
              _categoryLabel(complaint.category),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.primary),
            ),
            AppSpacing.h8,
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.textSecondary),
                AppSpacing.w4,
                Text(
                  '${AppStrings.complaintCreatedOn} ${_formatDate(complaint.createdAt)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'ORDER_ISSUE':
        return AppStrings.catOrderIssue;
      case 'PAYMENT_ISSUE':
        return AppStrings.catPaymentIssue;
      case 'DELIVERY_ISSUE':
        return AppStrings.catDeliveryIssue;
      case 'PRODUCT_QUALITY':
        return AppStrings.catProductQuality;
      case 'APP_ISSUE':
        return AppStrings.catAppIssue;
      case 'ACCOUNT_ISSUE':
        return AppStrings.catAccountIssue;
      case 'VENDOR_BEHAVIOR':
        return AppStrings.catVendorBehavior;
      case 'DELIVERY_BEHAVIOR':
        return AppStrings.catDeliveryBehavior;
      default:
        return AppStrings.catOther;
    }
  }
}

