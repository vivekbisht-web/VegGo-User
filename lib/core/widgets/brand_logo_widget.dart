import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class BrandLogoWidget extends StatelessWidget {
  final bool isCenterAligned;

  const BrandLogoWidget({
    super.key,
    this.isCenterAligned = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isCenterAligned
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              color: AppColors.primary,
              size: isCenterAligned ? 18 : 20,
            ),
            AppSpacing.w2,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppStrings.veg,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: isCenterAligned ? 20 : 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: AppStrings.go,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.orangeFlame,
                      fontWeight: FontWeight.w900,
                      fontSize: isCenterAligned ? 20 : 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.w4,
            Container(
              padding: AppSpacing.paddingFromLTRB(isCenterAligned ? 3 : 4, 1, isCenterAligned ? 3 : 4, 1),
              decoration: BoxDecoration(
                color: AppColors.mintHeader,
                borderRadius: BorderRadius.circular(AppSpacing.radius4),
              ),
              child: Text(
                AppStrings.freshCaps,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: isCenterAligned ? 7.5 : 8.5,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.h2,
        Text(
          isCenterAligned ? AppStrings.freshFastTrustedWithDashes : AppStrings.eatFreshLiveHealthyWithLeaves,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isCenterAligned ? AppColors.orangeFlame : AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: isCenterAligned ? 8 : 8.5,
            letterSpacing: isCenterAligned ? 0.8 : 0.5,
          ),
        ),
      ],
    );
  }
}
