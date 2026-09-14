import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class DrawerQuickActions extends StatelessWidget {
  final VoidCallback onOrdersTap;
  final VoidCallback onWalletTap;
  final VoidCallback onWishlistTap;

  const DrawerQuickActions({
    super.key,
    required this.onOrdersTap,
    required this.onWalletTap,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.paddingHorizontal12,
      padding: AppSpacing.paddingVertical8,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionItem(
            icon: Icons.inventory_2_outlined,
            label: AppStrings.myOrders,
            onTap: onOrdersTap,
          ),
          Container(
            height: 24,
            width: 1,
            color: AppColors.borderLight,
          ),
          _QuickActionItem(
            icon: Icons.account_balance_wallet_outlined,
            label: AppStrings.wallet,
            onTap: onWalletTap,
          ),
          Container(
            height: 24,
            width: 1,
            color: AppColors.borderLight,
          ),
          _QuickActionItem(
            icon: Icons.favorite_border_rounded,
            label: AppStrings.wishlist,
            onTap: onWishlistTap,
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius8),
      child: Padding(
        padding: AppSpacing.paddingHorizontal8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.drawerIconSize,
              color: AppColors.primary,
            ),
            AppSpacing.h4,
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
