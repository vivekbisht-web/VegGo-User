//
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'custom_button.dart';
import 'custom_image_view.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    this.imagePath,
    this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAll24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              CustomImageView(
                imageUrl: imagePath!,
                isAsset: true,
                height: 200,
                fit: BoxFit.contain,
              ),
              AppSpacing.h24,
            ],
            if (icon != null) ...[
              Icon(
                icon,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              AppSpacing.h24,
            ],

            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.h12,

            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            if (buttonText != null && onButtonPressed != null) ...[
              AppSpacing.h32,
              SizedBox(
                width: 250,
                child: CustomButton(
                  text: buttonText!,
                  onPressed: onButtonPressed!,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.surface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
