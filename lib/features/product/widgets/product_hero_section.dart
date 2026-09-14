//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/core/widgets/quantity_selector.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import '../controllers/product_details_controller.dart';
import '../controllers/wishlist_controller.dart';
import 'product_hero_features_box.dart';

class ProductHeroSection extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductHeroSection({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final ProductDetailsController controller =
        Get.find<ProductDetailsController>();
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final WishlistController wishlistController = WishlistController.to;

    return Obx(() {
      final details = controller.productDetails.value;
      final String resolvedId = (details != null && details.id.isNotEmpty)
          ? details.id
          : (productData['id']?.toString() ??
              productData['productId']?.toString() ??
              productData['catalogProductId']?.toString() ??
              '');
      final String name = details?.name.isNotEmpty == true
          ? details!.name
          : (productData['name'] as String? ?? '');
      final String unit = details?.unit.isNotEmpty == true
          ? details!.unit
          : (productData['unit'] as String? ??
                productData['qty'] as String? ??
                AppStrings.kg1);
      final String imageUrl = (details != null && details.imageUrl.isNotEmpty)
          ? details.imageUrl
          : (productData['image'] as String? ??
                productData['imageUrl'] as String? ??
                '');
      final double price =
          details?.price ??
          ((productData['price'] is num)
              ? (productData['price'] as num).toDouble()
              : 0.0);
      final double originalPrice =
          details?.originalPrice ??
          ((productData['originalPrice'] is num)
              ? (productData['originalPrice'] as num).toDouble()
              : (productData['mrp'] is num)
              ? (productData['mrp'] as num).toDouble()
              : price);
      final int discountPercent =
          details?.discountPercent ??
          ((productData['discountPercent'] is int)
              ? productData['discountPercent'] as int
              : 0);

      final priceStr = PriceFormatter.format(price);
      final originalPriceStr = PriceFormatter.format(originalPrice);

      return Padding(
        padding: AppSpacing.paddingHorizontal16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 46,
              child: Container(
                height: 245,
                padding: AppSpacing.paddingAll8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  border: Border.all(color: AppColors.chipBorder, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: AppSpacing.paddingAll16,
                        child: CustomImageView(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 2,
                      right: 2,
                      child: Obx(() {
                        final isFav = wishlistController.isWishlisted(resolvedId);
                        return InkWell(
                          onTap: () {
                            if (resolvedId.isNotEmpty) {
                              wishlistController.toggleWishlist(
                                resolvedId,
                                product: details,
                                productMap: productData,
                              );
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.chipBorder,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              color: isFav
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        );
                      }),
                    ),

                    Positioned(
                      bottom: 34,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final isActive = index == 0;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: isActive ? 10 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius4,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    Positioned(
                      bottom: 2,
                      left: 2,
                      child: Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.discountGreen,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius6,
                          ),
                          border: Border.all(
                            color: AppColors.mintBadge.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco_outlined,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            AppSpacing.w4,
                            Text(
                              AppStrings.farmFresh,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.w12,

            Expanded(
              flex: 54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  AppSpacing.h2,

                  Text(
                    unit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppSpacing.h4,

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          priceStr,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                fontSize: 18,
                              ),
                        ),
                          AppSpacing.w6,
                          Text(
                            originalPriceStr,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.strikethrough,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11.5,
                                ),
                          ),
                        AppSpacing.w6,
                        Container(
                          padding: AppSpacing.paddingSymmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius4,
                            ),
                          ),
                          child: Text(
                            '$discountPercent% ${AppStrings.off}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h2,

                  Text(
                    AppStrings.inclusiveOfAllTaxes,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  AppSpacing.h8,

                  const ProductHeroFeaturesBox(),
                  AppSpacing.h8,

                  Text(
                    AppStrings.quantity,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                  AppSpacing.h4,

                  Row(
                    children: [
                      QuantitySelector(
                        quantity: controller.quantity.value,
                        onIncrement: controller.incrementQuantity,
                        onDecrement: controller.decrementQuantity,
                        style: QuantitySelectorStyle.bordered,
                      ),
                      AppSpacing.w8,

                      Expanded(
                        child: InkWell(
                          onTap: () {
                            final details = controller.productDetails.value;
                            final itemMap =
                                details?.toMap() ??
                                Map<String, dynamic>.from(productData);
                            cartController.addToCart(
                              itemMap,
                              qty: controller.quantity.value,
                            );
                            AnimationOverlayHelper.showRocketAddToCart(
                              context,
                              onComplete: () {},
                            );
                          },
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius6,
                          ),
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius6,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    AppSpacing.w4,
                                    Text(
                                      AppStrings.addToCart,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
