//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/cart/screens/coupons_screen.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/orders/screens/my_orders_screen.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    final actions = <_QuickAction>[
      _QuickAction(
        title: AppStrings.repeatOrder,
        subtitle: AppStrings.yourLastOrder,
        icon: Icons.autorenew_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.successBackground,
        onTap: () => Get.to(() => const MyOrdersScreen()),
      ),
      _QuickAction(
        title: AppStrings.offers,
        subtitle: AppStrings.latestDeals,
        icon: Icons.local_offer_rounded,
        iconColor: AppColors.surface,
        iconBackground: AppColors.purpleTag,
        badge: '3',
        onTap: () => Get.to(() => const CouponsScreen()),
      ),
      _QuickAction(
        title: AppStrings.newArrivals,
        subtitle: AppStrings.freshItems,
        icon: Icons.notifications_active_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.successBackground,
        onTap: () => dashboardController.changeTabIndex(1),
      ),
      _QuickAction(
        title: AppStrings.bestSellers,
        subtitle: AppStrings.topProducts,
        icon: Icons.local_fire_department_rounded,
        iconColor: AppColors.surface,
        iconBackground: AppColors.orangeFlame,
        onTap: () => dashboardController.changeTabIndex(1),
      ),
    ];

    return SizedBox(
      height: AppSpacing.quickActionHeight,
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            Expanded(child: _QuickActionCard(action: actions[i])),
            if (i != actions.length - 1) AppSpacing.w4,
          ],
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(AppSpacing.radius10);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: cardRadius,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: cardRadius,
        child: Container(
          padding: AppSpacing.paddingFromLTRB(5, 6, 5, 6),
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            border: Border.all(color: AppColors.chipBorder, width: 0.8),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: AppSpacing.quickActionIconSize,
                    height: AppSpacing.quickActionIconSize,
                    decoration: BoxDecoration(
                      color: action.iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        action.icon,
                        color: action.iconColor,
                        size: 16,
                      ),
                    ),
                  ),
                  if (action.badge != null)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 14,
                        height: 14,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          action.badge!,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w800,
                            fontSize: 7.5,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.w4,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        action.title,
                        maxLines: 1,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    AppSpacing.h2,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        action.subtitle,
                        maxLines: 1,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 8,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String? badge;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
    this.badge,
  });
}
