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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: AppSpacing.paddingZero,
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.radius10,
        mainAxisSpacing: AppSpacing.radius10,
        childAspectRatio: 2.65,
      ),
      itemBuilder: (context, index) {
        return _QuickActionCard(action: actions[index]);
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(AppSpacing.radius12);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: cardRadius,
        child: Container(
          padding: AppSpacing.paddingSymmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            border: Border.all(color: AppColors.chipBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlayLight.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: action.iconBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radius10),
                    ),
                    child: Center(
                      child: Icon(
                        action.icon,
                        color: action.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  if (action.badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppSpacing.radius8),
                        ),
                        child: Text(
                          action.badge!,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w800,
                            fontSize: 8.5,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.w8,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.15,
                      ),
                    ),
                    AppSpacing.h2,
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        height: 1.15,
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
