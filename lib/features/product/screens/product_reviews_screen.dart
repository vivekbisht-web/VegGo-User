//
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  final List<Map<String, dynamic>> reviews = const [
    {
      'name': 'Sarah Jenkins',
      'date': '2 days ago',
      'rating': 5,
      'comment': 'Extremely fresh lemons! Perfect for my morning detox drinks.',
    },
    {
      'name': 'David Miller',
      'date': '1 week ago',
      'rating': 4,
      'comment': 'Good quality produce delivered within 30 minutes.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.productReviews,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.paddingResponsiveAll(0.04),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppSpacing.screenWidth * 0.03,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        '4.8',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16,
                          ),
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        '128 Reviews',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomButton(text: AppStrings.writeReview, onPressed: () {}),
                ],
              ),
            ),
            AppSpacing.responsiveHeight(0.03),

            ...reviews.map(
              (r) => Container(
                margin: AppSpacing.paddingOnly(
                  bottom: AppSpacing.screenWidth * 0.03,
                ),
                padding: AppSpacing.paddingResponsiveAll(0.04),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.03,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Text(
                          r['date'] as String,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    AppSpacing.h4,
                    Row(
                      children: List.generate(
                        r['rating'] as int,
                        (index) => const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 14,
                        ),
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      r['comment'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
