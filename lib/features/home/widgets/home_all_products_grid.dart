import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';
import 'package:vegon_user/features/product/controllers/wishlist_controller.dart';
import 'package:vegon_user/features/product/screens/product_details_screen.dart';

class HomeAllProductsGrid extends StatelessWidget {
  const HomeAllProductsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final wishlistController = WishlistController.to;

    final cardRadius = BorderRadius.circular(AppSpacing.radius16);
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      if (homeController.isLoading.value &&
          homeController.allProducts.isEmpty) {
        return _buildShimmerGrid();
      }

      final products = homeController.allProducts;
      if (products.isEmpty) {
        return const SizedBox.shrink();
      }

      return GridView.builder(
        shrinkWrap: true,
        padding: AppSpacing.paddingZero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.radius12,
          mainAxisSpacing: AppSpacing.radius12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final item = products[index];
          final productMap = item.toMap();
          final price = item.price.toInt();
          final original = (item.originalPrice ?? (item.price * 1.25)).toInt();
          final name = item.name;
          final unit = item.unit;
          final discount = item.discountPercent > 0
              ? '${item.discountPercent}% OFF'
              : null;

          return Material(
            color: AppColors.surface,
            borderRadius: cardRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: cardRadius,
              onTap: () => Get.to(
                () => ProductDetailsScreen(productData: productMap),
                transition: Transition.cupertino,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: cardRadius,
                  border: Border.all(color: AppColors.chipBorder, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.overlayLight.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: CustomImageView(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: AppSpacing.paddingFromLTRB(10, 8, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              AppSpacing.h2,
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      unit,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.ratingStar,
                                    size: 13,
                                  ),
                                  AppSpacing.w2,
                                  Text(
                                    '4.7',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h6,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${AppStrings.rupeeSymbol}$price',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: AppColors.bannerDarkGreen,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      AppSpacing.w4,
                                      Text(
                                        '${AppStrings.rupeeSymbol}$original',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.strikethrough,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Material(
                                    color: AppColors.bannerDarkGreen,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        cartController.addToCart(productMap);
                                        AnimationOverlayHelper
                                            .showRocketAddToCart(
                                          context,
                                          onComplete: () {},
                                        );
                                      },
                                      child: const SizedBox(
                                        width: AppSpacing.addCircleButtonSize,
                                        height: AppSpacing.addCircleButtonSize,
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 18,
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

                    if (discount != null)
                      Positioned(
                        top: AppSpacing.radius8,
                        left: AppSpacing.radius8,
                        child: Container(
                          padding: AppSpacing.paddingSymmetric(
                            horizontal: AppSpacing.radius8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bannerDarkGreen,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius12,
                            ),
                          ),
                          child: Text(
                            discount,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: AppSpacing.radius6,
                      right: AppSpacing.radius6,
                      child: Obx(() {
                        final isFav = wishlistController.isWishlisted(item.id);
                        return InkWell(
                          onTap: () => wishlistController.toggleWishlist(
                            item.id,
                            productMap: productMap,
                          ),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              color: isFav
                                  ? AppColors.error
                                  : AppColors.borderLight,
                              size: 15,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.chipBackground,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.radius12,
          mainAxisSpacing: AppSpacing.radius12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
            ),
          );
        },
      ),
    );
  }
}
