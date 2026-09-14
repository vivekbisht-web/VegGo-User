//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import '../controllers/product_details_controller.dart';
import '../models/product_details_model.dart';
import '../screens/product_details_screen.dart';

class ProductRelatedSection extends StatelessWidget {
  const ProductRelatedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductDetailsController controller =
        Get.find<ProductDetailsController>();
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Obx(() {
      if (controller.isRelatedLoading.value) {
        return const _RelatedProductsShimmer();
      }

      final items = controller.relatedProducts;
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.paddingHorizontal16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.relatedProductsTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: AppSpacing.paddingSymmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.discountGreen,
                    borderRadius: BorderRadius.circular(AppSpacing.radius6),
                  ),
                  child: Text(
                    AppStrings.similarItems,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h10,
          SizedBox(
            height: 185,
            child: ListView.separated(
              padding: AppSpacing.paddingHorizontal16,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => AppSpacing.w10,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildRelatedCard(context, item, cartController);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRelatedCard(
    BuildContext context,
    ProductDetailsData item,
    CartController cartController,
  ) {
    final priceStr =
        '${AppStrings.rupeeSymbol}${item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2)}';
    final originalPriceStr = item.originalPrice != null
        ? '${AppStrings.rupeeSymbol}${item.originalPrice!.toStringAsFixed(item.originalPrice! % 1 == 0 ? 0 : 2)}'
        : null;

    return InkWell(
      onTap: () => Get.to(
        () => ProductDetailsScreen(productData: item.toMap()),
        preventDuplicates: false,
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        width: 130,
        padding: AppSpacing.paddingAll8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(color: AppColors.chipBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: CustomImageView(
                  imageUrl: item.imageUrl,
                  height: 65,
                  width: 65,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            AppSpacing.h4,

            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
            ),

            Text(
              item.unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9.5,
              ),
            ),
            AppSpacing.h4,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                    if (originalPriceStr != null)
                      Text(
                        originalPriceStr,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.strikethrough,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 8.5,
                        ),
                      ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    cartController.addToCart(item.toMap());
                    AnimationOverlayHelper.showRocketAddToCart(
                      context,
                      onComplete: () {},
                    );
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radius4),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radius4),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedProductsShimmer extends StatelessWidget {
  const _RelatedProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSpacing.radius4),
            ),
          ),
          AppSpacing.h10,
          SizedBox(
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => AppSpacing.w10,
              itemBuilder: (context, index) {
                return Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radius12),
                    border: Border.all(color: AppColors.chipBorder),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
