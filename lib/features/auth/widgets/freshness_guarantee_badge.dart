//
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';

class FreshnessGuaranteeBadge extends StatelessWidget {
  const FreshnessGuaranteeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_outlined,
          color: AppColors.warning,
          size: 16,
        ),
        AppSpacing.responsiveWidth(0.015),
        Text(
          AppStrings.freshnessGuarantee,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
