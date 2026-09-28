import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/cart/screens/coupons_screen.dart';
import 'package:vegon_user/features/profile/controllers/wallet_controller.dart';
import 'package:vegon_user/features/profile/screens/dm_points_screen.dart';
import 'package:vegon_user/features/profile/screens/refer_earn_screen.dart';
import 'package:vegon_user/features/profile/screens/wallet_screen.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveSymmetric(
        horizontal: 0.02,
        vertical: 0.03,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        border: Border.all(color: AppColors.statsBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Obx(
              () => _buildStatItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: AppStrings.dmWallet,
                value: walletController.formattedBalanceForStats,
                actionLabel: AppStrings.viewWalletAction,
                onTap: () => Get.to(() => const WalletScreen()),
              ),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.confirmation_number_outlined,
              title: AppStrings.myCoupons,
              value: AppStrings.couponsStatsValue,
              actionLabel: AppStrings.viewCouponsAction,
              onTap: () => Get.to(() => const CouponsScreen()),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.star_outline,
              title: AppStrings.dmPoints,
              value: AppStrings.pointsStatsValue,
              actionLabel: AppStrings.viewPointsAction,
              onTap: () => Get.to(() => const DmPointsScreen()),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.card_giftcard_outlined,
              title: AppStrings.referEarn,
              value: AppStrings.referStatsValue,
              actionLabel: AppStrings.referNowAction,
              onTap: () => Get.to(() => const ReferEarnScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.screenWidth * 0.05,
          ),
          AppSpacing.h4,
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.h2,
          Padding(
            padding: AppSpacing.paddingHorizontal2_5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
          AppSpacing.h4,
          Text(
            actionLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: AppSpacing.screenWidth * 0.12,
      width: 1,
      color: AppColors.borderLight.withAlpha(50),
    );
  }
}
