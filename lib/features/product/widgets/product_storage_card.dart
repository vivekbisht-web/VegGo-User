//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';

class ProductStorageCard extends StatelessWidget {
  const ProductStorageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingResponsiveAll(0.02),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco,
                  color: AppColors.warning,
                  size: AppSpacing.screenWidth * 0.05,
                ),
              ),
              AppSpacing.responsiveWidth(0.03),
              Text(
                AppStrings.storageTips,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.responsiveHeight(0.05),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.paddingResponsiveAll(0.02),
                decoration: BoxDecoration(
                  color: AppColors.borderLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.02,
                  ),
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: AppColors.textSecondary,
                  size: AppSpacing.screenWidth * 0.05,
                ),
              ),
              AppSpacing.responsiveWidth(0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.storeRoomTemp,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.responsiveHeight(0.01),
                    Text(
                      AppStrings.storeRoomTempDesc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.responsiveHeight(0.04),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.paddingResponsiveAll(0.02),
                decoration: BoxDecoration(
                  color: AppColors.borderLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.02,
                  ),
                ),
                child: Icon(
                  Icons.ac_unit,
                  color: AppColors.textSecondary,
                  size: AppSpacing.screenWidth * 0.05,
                ),
              ),
              AppSpacing.responsiveWidth(0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.avoidFridge,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.responsiveHeight(0.01),
                    Text(
                      AppStrings.avoidFridgeDesc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
