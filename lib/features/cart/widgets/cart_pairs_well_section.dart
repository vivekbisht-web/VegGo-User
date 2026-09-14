//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';

class CartPairsWellSection extends StatelessWidget {
  const CartPairsWellSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Obx(() {
      final recommended = homeController.bestDeals.take(4).toList();
      if (recommended.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.pairsWellWith,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.responsiveHeight(0.015),
          SizedBox(
            height: AppSpacing.screenHeight * 0.28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              separatorBuilder: (context, index) =>
                  AppSpacing.responsiveWidth(0.04),
              itemBuilder: (context, index) {
                final item = recommended[index].toMap();
                return _buildRecommendationCard(context, item);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final double cardWidth = AppSpacing.screenWidth * 0.42;
    final CartController cartController = Get.find<CartController>();

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: AppSpacing.screenWidth * 0.22,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.borderLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.screenWidth * 0.04),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.screenWidth * 0.04),
              ),
              child: CustomImageView(
                imageUrl: (item['image'] ?? item['imageUrl']) as String? ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: AppSpacing.paddingSymmetric(
              horizontal: AppSpacing.screenWidth * 0.02,
              vertical: AppSpacing.screenWidth * 0.015,
            ),
            child: Column(
              children: [
                Text(
                  item['name'] as String? ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.responsiveHeight(0.005),
                Text(
                  '${AppStrings.currencySymbol}${((item['price'] as num?) ?? 0).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.responsiveHeight(0.015),

                InkWell(
                  onTap: () {
                    cartController.addToCart(item);
                    AnimationOverlayHelper.showRocketAddToCart(
                      context,
                      onComplete: () {},
                    );
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: AppSpacing.paddingResponsiveAll(0.012),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.surface,
                      size: AppSpacing.screenWidth * 0.045,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
