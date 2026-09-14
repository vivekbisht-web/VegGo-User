//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/auth/controllers/auth_controller.dart';
import 'package:vegon_user/features/profile/screens/favorites_screen.dart';
import 'package:vegon_user/features/profile/screens/help_center_screen.dart';
import 'package:vegon_user/features/profile/screens/notifications_settings_screen.dart';
import 'package:vegon_user/features/profile/screens/payment_methods_screen.dart';
import 'package:vegon_user/features/profile/screens/saved_addresses_screen.dart';
import 'package:vegon_user/features/profile/screens/terms_privacy_screen.dart';
import 'package:vegon_user/features/profile/screens/wallet_screen.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItemTile(
            context,
            icon: Icons.location_on_outlined,
            title: AppStrings.addresses,
            subtitle: AppStrings.manageAddressesDesc,
            onTap: () => Get.to(() => SavedAddressesScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.favorite_border,
            title: AppStrings.savedItems,
            subtitle: AppStrings.savedItemsDesc,
            onTap: () => Get.to(() => const FavoritesScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.payment_outlined,
            title: AppStrings.paymentMethods,
            subtitle: AppStrings.paymentMethodsDesc,
            onTap: () => Get.to(() => const PaymentMethodsScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: AppStrings.walletTransactions,
            subtitle: AppStrings.walletTransactionsDesc,
            onTap: () => Get.to(() => const WalletScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            subtitle: AppStrings.notificationsDesc,
            onTap: () => Get.to(() => const NotificationsSettingsScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.headset_mic_outlined,
            title: AppStrings.helpSupport,
            subtitle: AppStrings.helpSupportDesc,
            onTap: () => Get.to(() => const HelpCenterScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.aboutDailyMarket,
            subtitle: AppStrings.aboutDailyMarketDesc,
            onTap: () => Get.to(() => const TermsPrivacyScreen()),
          ),
          _buildDivider(),
          _buildMenuItemTile(
            context,
            icon: Icons.logout,
            title: AppStrings.logout,
            subtitle: AppStrings.logoutDesc,
            isDestructive: true,
            onTap: () => Get.put(AuthController()).logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive
        ? AppColors.error
        : AppColors.primary;
    final textColor = isDestructive
        ? AppColors.error
        : AppColors.textPrimary;

    return Material(
      color: AppColors.transparent,
      child: ListTile(
        contentPadding: AppSpacing.paddingResponsiveSymmetric(
          horizontal: 0.04,
          vertical: 0.005,
        ),
        leading: Container(
          padding: AppSpacing.paddingAll8,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withAlpha(20)
                : AppColors.successBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: AppSpacing.screenWidth * 0.05,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
          size: AppSpacing.screenWidth * 0.05,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.borderLight.withAlpha(30),
      height: 1,
      indent: AppSpacing.screenWidth * 0.16,
      endIndent: AppSpacing.screenWidth * 0.04,
    );
  }
}
