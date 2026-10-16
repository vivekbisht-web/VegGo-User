//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class ComplaintStatusBadge extends StatelessWidget {
  const ComplaintStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radius20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }

  static (Color, Color, String) _resolve(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return (
          AppColors.complaintPendingBg,
          AppColors.complaintPendingText,
          AppStrings.complaintStatusPending,
        );
      case 'RESOLVED':
        return (
          AppColors.complaintResolvedBg,
          AppColors.complaintResolvedText,
          AppStrings.complaintStatusResolved,
        );
      case 'REOPENED':
        return (
          AppColors.complaintReopenedBg,
          AppColors.complaintReopenedText,
          AppStrings.complaintStatusReopened,
        );
      default:
        return (
          AppColors.chipBackground,
          AppColors.textSecondary,
          AppStrings.complaintStatusUnknown,
        );
    }
  }
}
