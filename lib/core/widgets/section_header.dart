//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool showViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.showViewAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActionText =
        actionText ?? (showViewAll ? AppStrings.viewAll : null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: AppSpacing.sectionHeaderTitleSize,
            ),
          ),
        ),
        if (effectiveActionText != null && onActionTap != null)
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(AppSpacing.radius8),
            child: Padding(
              padding: AppSpacing.paddingSymmetric(
                horizontal: AppSpacing.radius6,
                vertical: AppSpacing.radius4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    effectiveActionText,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: AppSpacing.sectionHeaderActionSize,
                    ),
                  ),
                  AppSpacing.w2,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppSpacing.sectionHeaderIconSize,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
