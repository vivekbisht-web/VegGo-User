//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/features/profile/screens/language_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, AppStrings.notificationPreferences),
            AppSpacing.h16,
            _buildSwitchTile(
              context,
              title: AppStrings.pushNotifications,
              subtitle: AppStrings.pushNotificationsDesc,
              value: true,
              onChanged: (val) {},
            ),
            _buildSwitchTile(
              context,
              title: AppStrings.emailUpdates,
              subtitle: AppStrings.emailUpdatesDesc,
              value: false,
              onChanged: (val) {},
            ),
            _buildSwitchTile(
              context,
              title: AppStrings.smsAlerts,
              subtitle: AppStrings.smsAlertsDesc,
              value: true,
              onChanged: (val) {},
            ),
            AppSpacing.h32,
            _buildSectionHeader(context, AppStrings.languageAndRegion),
            AppSpacing.h16,
            _buildListTile(
              context,
              icon: Icons.language,
              title: AppStrings.appLanguage,
              trailingText: AppStrings.englishUS,
              onTap: () => Get.to(() => const LanguageScreen()),
            ),
            AppSpacing.h32,
            _buildSectionHeader(
              context,
              AppStrings.accountManagement,
              color: AppColors.error,
            ),
            AppSpacing.h16,
            Material(
              color: AppColors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: AppSpacing.paddingAll8,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
                title: Text(
                  AppStrings.deleteAccount,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                subtitle: Text(
                  AppStrings.deleteAccountWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    Color? color,
  }) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: color ?? AppColors.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: AppSpacing.paddingAll12.copyWith(top: 0, left: 0, right: 0),
      padding: AppSpacing.paddingHorizontal16.copyWith(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.h4,
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trailingText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.w8,
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
