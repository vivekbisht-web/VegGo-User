//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class ProductTrustBanner extends StatelessWidget {
  const ProductTrustBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontal16,
      child: Container(
        padding: AppSpacing.paddingSymmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(color: AppColors.chipBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTrustItem(
                context,
                icon: Icons.electric_moped_outlined,
                title: AppStrings.deliveryIn,
                subtitle: AppStrings.deliveryMins30To45,
              ),
            ),
            Container(height: 28, width: 1, color: AppColors.chipBorder),

            Expanded(
              child: _buildTrustItem(
                context,
                icon: Icons.replay_rounded,
                title: AppStrings.easyReturns,
                subtitle: AppStrings.daysReturn7,
              ),
            ),
            Container(height: 28, width: 1, color: AppColors.chipBorder),

            Expanded(
              child: _buildTrustItem(
                context,
                icon: Icons.security_outlined,
                title: AppStrings.qualityGuarantee,
                subtitle: AppStrings.refund100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          AppSpacing.w4,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
