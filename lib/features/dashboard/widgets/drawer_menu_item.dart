import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? textColor;
  final Color? iconColor;
  final Widget? trailing;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.textColor,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isSelected
        ? AppColors.primary
        : (iconColor ?? AppColors.textSecondary);
    final effectiveTextColor = isSelected
        ? AppColors.primary
        : (textColor ?? AppColors.textPrimary);
    final effectiveBgColor =
        isSelected ? AppColors.mintLight : AppColors.transparent;

    return Container(
      margin: AppSpacing.paddingHorizontal8,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radius8),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radius8),
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.paddingFromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                Icon(
                  isSelected ? (selectedIcon ?? icon) : icon,
                  color: effectiveIconColor,
                  size: AppSpacing.drawerIconSize,
                ),
                AppSpacing.w12,
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: effectiveTextColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  AppSpacing.w6,
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerSectionLabel extends StatelessWidget {
  final String title;

  const DrawerSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingFromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class DrawerFooter extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const DrawerFooter({super.key, required this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingFromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onLogoutTap,
            borderRadius: BorderRadius.circular(AppSpacing.radius8),
            child: Padding(
              padding: AppSpacing.paddingVertical8,
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: AppSpacing.drawerIconSize,
                  ),
                  AppSpacing.w12,
                  Text(
                    AppStrings.logout,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppStrings.bullet,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                AppStrings.appVersion,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.h2,
          Text(
            AppStrings.freshFastTrustedTagline,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
