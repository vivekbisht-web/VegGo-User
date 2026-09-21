import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/category/models/category_product_model.dart';
import 'package:vegon_user/features/product/controllers/wishlist_controller.dart';
import 'package:vegon_user/features/product/screens/product_details_screen.dart';

class HomeProductSection extends StatelessWidget {
  final List<dynamic> products;
  final int? maxItems;

  const HomeProductSection({
    super.key,
    required this.products,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final displayList = maxItems != null
        ? products.take(maxItems!).toList()
        : products;

    if (displayList.isEmpty) return const SizedBox.shrink();

    final cardRadius = BorderRadius.circular(AppSpacing.radius16);
    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final wishlistController = WishlistController.to;

    return GridView.builder(
      shrinkWrap: true,
      padding: AppSpacing.paddingZero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.radius12,
        mainAxisSpacing: AppSpacing.radius12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final raw = displayList[index];
        final Map<String, dynamic> productMap = raw is CategoryProductItem
            ? raw.toMap()
            : (raw is Map<String, dynamic> ? raw : {});

        final String id = productMap['id']?.toString() ??
            productMap['_id']?.toString() ??
            productMap['productId']?.toString() ??
            '';
        final price = (productMap['price'] as num?)?.toInt() ?? 0;
        final original =
            (productMap['originalPrice'] as num?)?.toInt() ??
            ((price * 1.25).toInt());
        final name = productMap['name'] as String? ?? '';
        final unit = productMap['unit'] as String? ?? AppStrings.kg1;
        final discount =
            productMap['discount'] as String? ??
            (productMap['tag'] as String? ??
                (productMap['discountPercent'] != null &&
                        (productMap['discountPercent'] as num) > 0
                    ? '${productMap['discountPercent']}% OFF'
                    : null));
        final rating = (productMap['rating'] as num?)?.toDouble() ?? 4.5;
        final imageUrl =
            (productMap['image'] ?? productMap['imageUrl']) as String? ?? '';

        final textTheme = Theme.of(context).textTheme;

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
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppSpacing.paddingFromLTRB(8, 6, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontSize: 12,
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
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.ratingStar,
                                  size: 12,
                                ),
                                AppSpacing.w2,
                                Text(
                                  '$rating',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.h6,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${AppStrings.rupeeSymbol}$price',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: AppColors.bannerDarkGreen,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    AppSpacing.w4,
                                    Text(
                                      '${AppStrings.rupeeSymbol}$original',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.strikethrough,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 10,
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
                          horizontal: AppSpacing.radius6,
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
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),

                  if (id.isNotEmpty)
                    Positioned(
                      top: AppSpacing.radius6,
                      right: AppSpacing.radius6,
                      child: Obx(() {
                        final isFav = wishlistController.isWishlisted(id);
                        return InkWell(
                          onTap: () => wishlistController.toggleWishlist(
                            id,
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
  }
}
