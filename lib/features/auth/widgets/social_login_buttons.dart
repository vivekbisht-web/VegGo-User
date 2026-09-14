//
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.borderLight)),
            Padding(
              padding: AppSpacing.paddingHorizontal16,
              child: Text(
                AppStrings.orContinueWith,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.borderLight)),
          ],
        ),
        AppSpacing.responsiveHeight(0.03),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: AppStrings.google,
                icon: Icons.g_mobiledata,
                iconColor: AppColors.success,
                textColor: AppColors.textPrimary,
                isOutlined: true,
                onPressed: () {},
              ),
            ),
            AppSpacing.responsiveWidth(0.04),
            Expanded(
              child: CustomButton(
                text: AppStrings.apple,
                icon: Icons.apple,
                iconColor: AppColors.textPrimary,
                textColor: AppColors.textPrimary,
                isOutlined: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
