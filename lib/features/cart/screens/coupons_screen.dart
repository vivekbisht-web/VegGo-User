//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  final List<Map<String, String>> coupons = const [
    {
      'code': 'FRESH20',
      'title': '20% OFF on Organic Vegetables',
      'description':
          'Valid on orders over ${AppStrings.currencySymbol}150. Maximum discount ${AppStrings.currencySymbol}50.',
      'expiry': 'Expires in 3 days',
    },
    {
      'code': 'FREESHIP',
      'title': 'Free Delivery on First 3 Orders',
      'description': 'Applicable for all fresh produce categories.',
      'expiry': 'Expires tomorrow',
    },
    {
      'code': 'VEGON5',
      'title': '${AppStrings.currencySymbol}50 Instant Cashback',
      'description': 'Valid on wallet payments.',
      'expiry': 'Expires in 7 days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: ListView.separated(
        padding: AppSpacing.paddingResponsiveAll(0.04),
        itemCount: coupons.length,
        separatorBuilder: (_, _) => AppSpacing.responsiveHeight(0.02),
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return Container(
            padding: AppSpacing.paddingResponsiveAll(0.04),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppSpacing.screenWidth * 0.03,
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: AppSpacing.paddingSymmetric(
                        horizontal: AppSpacing.screenWidth * 0.03,
                        vertical: AppSpacing.screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.screenWidth * 0.01,
                        ),
                      ),
                      child: Text(
                        coupon['code']!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CustomButton(
                      text: AppStrings.apply,
                      onPressed: () => Get.back(result: coupon['code']),
                      textColor: AppColors.primary,
                      isTextButton: true,
                    ),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  coupon['title']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  coupon['description']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.h8,
                Text(
                  coupon['expiry']!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
