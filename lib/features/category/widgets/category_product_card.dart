//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/product/controllers/wishlist_controller.dart';
import 'package:vegon_user/features/product/screens/product_details_screen.dart';
import '../models/category_product_model.dart';

class CategoryProductCard extends StatelessWidget {
  final dynamic product;

  const CategoryProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final WishlistController wishlistController = WishlistController.to;

    final CategoryProductItem item = product is CategoryProductItem
        ? (product as CategoryProductItem)
        : (product is Map<String, dynamic>
              ? CategoryProductItem.fromJson(product as Map<String, dynamic>)
              : CategoryProductItem.fromJson({}));

    final productMap = item.toMap();
    final priceStr =
        '${AppStrings.rupeeSymbol}${item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2)}';
    final originalPriceStr = item.originalPrice != null
        ? '${AppStrings.rupeeSymbol}${item.originalPrice!.toStringAsFixed(item.originalPrice! % 1 == 0 ? 0 : 2)}'
        : null;

    return InkWell(
      onTap: () {
        Get.to(
          () => ProductDetailsScreen(productData: productMap),
          transition: Transition.cupertino,
        );
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(color: AppColors.categoryBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 48,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomImageView(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (item.discountPercent > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius4,
                          ),
                        ),
                        child: Text(
                          '${item.discountPercent}% OFF',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 8.5,
                              ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Obx(() {
                      final isFav = wishlistController.isWishlisted(item.id);
                      return InkWell(
                        onTap: () => wishlistController.toggleWishlist(
                          item.id,
                          productMap: item.toMap(),
                        ),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: isFav
                                ? AppColors.error
                                : AppColors.borderLight,
                            size: 16,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 52,
              child: Padding(
                padding: AppSpacing.paddingFromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 12,
                              ),
                        ),
                        AppSpacing.h2,
                        Text(
                          item.unit.isNotEmpty ? item.unit : AppStrings.kg1,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                priceStr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                              ),
                              if (originalPriceStr != null)
                                Text(
                                  originalPriceStr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.strikethrough,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 9,
                                      ),
                                ),
                            ],
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            cartController.addToCart(productMap);
                            AnimationOverlayHelper.showRocketAddToCart(
                              context,
                              onComplete: () {},
                            );
                          },
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius8,
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius8,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
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
