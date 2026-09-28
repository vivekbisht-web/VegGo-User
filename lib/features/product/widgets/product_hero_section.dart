//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
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
              : (originalPrice > price && originalPrice > 0)
              ? (((originalPrice - price) / originalPrice) * 100).round()
              : 0);
      final double rating = details?.rating ??
          ((productData['rating'] is num)
              ? (productData['rating'] as num).toDouble()
              : 4.7);
      final String shopName = details?.shopName ??
          (productData['shopName']?.toString() ?? '');
      final String category = details?.category ??
          (productData['category']?.toString() ?? '');
      final double savings = (originalPrice > price) ? (originalPrice - price) : 0.0;
      final String savingsStr = savings > 0 ? PriceFormatter.format(savings) : '';

      final priceStr = PriceFormatter.format(price);
      final originalPriceStr = PriceFormatter.format(originalPrice);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image Card ──────────────────────────────────────
          Padding(
            padding: AppSpacing.paddingHorizontal16,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radius20),
                  border: Border.all(color: AppColors.chipBorder, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black12,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Product image – hero-sized display
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius20,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 28, 14, 28),
                          child: CustomImageView(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Discount badge – top left
                    if (discountPercent > 0)
                      Positioned(
                        top: AppSpacing.radius12,
                        left: AppSpacing.radius12,
                        child: Container(
                          padding: AppSpacing.paddingSymmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius6,
                            ),
                          ),
                          child: Text(
                            '$discountPercent% ${AppStrings.off}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ),

                    // Wishlist – top right
                    Positioned(
                      top: AppSpacing.radius8,
                      right: AppSpacing.radius8,
                      child: Obx(() {
                        final isFav = wishlistController.isWishlisted(
                          resolvedId,
                        );
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
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.chipBorder,
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              color: isFav
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Category / Farm fresh badge – bottom left
                    Positioned(
                      bottom: AppSpacing.radius12,
                      left: AppSpacing.radius12,
                      child: Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: 8,
                          vertical: 4,
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
                              category.trim().isNotEmpty
                                  ? category.trim()
                                  : AppStrings.farmFresh,
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

                    // Rating badge – bottom right
                    Positioned(
                      bottom: AppSpacing.radius12,
                      right: AppSpacing.radius12,
                      child: Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius6,
                          ),
                          border: Border.all(
                            color: AppColors.chipBorder,
                            width: 0.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                            ),
                            AppSpacing.w2,
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AppSpacing.h16,

          // ── Product Info ─────────────────────────────────────────
          Padding(
            padding: AppSpacing.paddingHorizontal16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    AppSpacing.w8,
                    Container(
                      padding: AppSpacing.paddingSymmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mintLight,
                        borderRadius: BorderRadius.circular(AppSpacing.radius6),
                        border: Border.all(
                          color: AppColors.mintBadge,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        unit,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (shopName.isNotEmpty) ...[
                  AppSpacing.h6,
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      AppSpacing.w4,
                      Text(
                        shopName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                AppSpacing.h8,

                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      priceStr,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 24,
                          ),
                    ),
                    if (originalPrice > price) ...[
                      AppSpacing.w8,
                      Text(
                        originalPriceStr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.strikethrough,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 15,
                        ),
                      ),
                      if (savingsStr.isNotEmpty) ...[
                        AppSpacing.w8,
                        Container(
                          padding: AppSpacing.paddingSymmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.discountGreen,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius4,
                            ),
                          ),
                          child: Text(
                            '${AppStrings.savePrefix}$savingsStr',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ],
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
                AppSpacing.h12,

                const ProductHeroFeaturesBox(),
              ],
            ),
          ),
        ],
      );
    });
  }
}
