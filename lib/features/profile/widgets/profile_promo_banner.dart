//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';

class ProfilePromoBanner extends StatelessWidget {
  const ProfilePromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        border: Border.all(color: AppColors.mintBadge.withAlpha(80)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.eatFreshLiveHealthy,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  AppStrings.eatFreshDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.w12,
          GestureDetector(
            onTap: () {
              if (Get.isRegistered<DashboardController>()) {
                Get.find<DashboardController>().changeTabIndex(1);
              }
            },
            child: Container(
              padding: AppSpacing.paddingResponsiveSymmetric(
                horizontal: 0.035,
                vertical: 0.02,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(
                  AppSpacing.screenWidth * 0.03,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.shopNow,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.w4,
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.surface,
                    size: AppSpacing.screenWidth * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
