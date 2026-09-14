//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class ProductHeroFeaturesBox extends StatelessWidget {
  const ProductHeroFeaturesBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll8,
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(AppSpacing.radius10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  context,
                  icon: Icons.eco_outlined,
                  title: AppStrings.farmFresh,
                  subtitle: AppStrings.handpickedProduce,
                ),
              ),
              AppSpacing.w6,
              Expanded(
                child: _buildFeatureItem(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: AppStrings.noPreservatives,
                  subtitle: AppStrings.naturalAndHealthy,
                ),
              ),
            ],
          ),
          AppSpacing.h6,
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: AppStrings.fastDelivery,
                  subtitle: AppStrings.onTimeEveryTime,
                ),
              ),
              AppSpacing.w6,
              Expanded(
                child: _buildFeatureItem(
                  context,
                  icon: Icons.workspace_premium_outlined,
                  title: AppStrings.bestQuality,
                  subtitle: AppStrings.carefullySelected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        AppSpacing.w4,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 8.5,
                  height: 1.1,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 7.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
