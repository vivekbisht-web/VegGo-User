//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';
import '../controllers/product_details_controller.dart';

class ProductBottomBar extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductBottomBar({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final ProductDetailsController productController =
        Get.find<ProductDetailsController>();

    return Obx(() {
      final details = productController.productDetails.value;
      final String resolvedId = details?.id.isNotEmpty == true
          ? details!.id
          : (productData['id']?.toString() ??
              productData['productId']?.toString() ??
              '');

      final Map<String, dynamic> itemMap =
          details?.toMap() ?? Map<String, dynamic>.from(productData);

      final double price = details?.price ??
          ((productData['price'] is num)
              ? (productData['price'] as num).toDouble()
              : 0.0);
      final double originalPrice = details?.originalPrice ??
          ((productData['originalPrice'] is num)
              ? (productData['originalPrice'] as num).toDouble()
              : (productData['mrp'] is num)
              ? (productData['mrp'] as num).toDouble()
              : price);

      final double savings =
          (originalPrice > price) ? (originalPrice - price) : 0.0;
      final priceStr = PriceFormatter.format(price);
      final originalPriceStr = PriceFormatter.format(originalPrice);
      final savingsStr = savings > 0 ? PriceFormatter.format(savings) : '';

      final int itemQty = cartController.getItemQuantity(resolvedId);
      final int cartCount = cartController.totalItems;
      final double cartTotal = cartController.total;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.chipBorder.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black12,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Floating Cart Notification Bar (if cart has items) ───────
              if (cartCount > 0)
                InkWell(
                  onTap: () => Get.to(() => CartScreen()),
                  child: Container(
                    padding: AppSpacing.paddingFromLTRB(16, 7, 16, 7),
                    decoration: const BoxDecoration(
                      color: AppColors.mintLight,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.mintBadge,
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        AppSpacing.w6,
                        Text(
                          '$cartCount ${cartCount == 1 ? AppStrings.item : AppStrings.items} | ${PriceFormatter.format(cartTotal)}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.viewCart,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                            ),
                            AppSpacing.w2,
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Main Action Bar ──────────────────────────────────────────
              Padding(
                padding: AppSpacing.paddingFromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    // Price Details Stack
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                priceStr,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      fontSize: 22,
                                    ),
                              ),
                              if (originalPrice > price) ...[
                                AppSpacing.w6,
                                Text(
                                  originalPriceStr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.strikethrough,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          AppSpacing.h2,
                          if (savingsStr.isNotEmpty)
                            Text(
                              '${AppStrings.savePrefix}$savingsStr',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                            )
                          else
                            Text(
                              AppStrings.inclusiveOfAllTaxes,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    AppSpacing.w16,

                    // Cart Action Button
                    if (itemQty == 0)
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radius12),
                        child: InkWell(
                          onTap: () {
                            cartController.addToCart(itemMap, qty: 1);
                            AnimationOverlayHelper.showRocketAddToCart(
                              context,
                              onComplete: () {},
                            );
                          },
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius12,
                          ),
                          child: Container(
                            height: 46,
                            padding: AppSpacing.paddingHorizontal20,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: AppColors.surface,
                                ),
                                AppSpacing.w8,
                                Text(
                                  AppStrings.addToCart,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.surface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () => cartController
                                    .decrementQuantity(resolvedId),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(AppSpacing.radius12),
                                ),
                                child: const Padding(
                                  padding: AppSpacing.paddingHorizontal12,
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: AppColors.surface,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 30),
                              alignment: Alignment.center,
                              child: Text(
                                '$itemQty',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppColors.surface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                              ),
                            ),
                            Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () {
                                  cartController.incrementQuantity(resolvedId);
                                  AnimationOverlayHelper.showRocketAddToCart(
                                    context,
                                    onComplete: () {},
                                  );
                                },
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(AppSpacing.radius12),
                                ),
                                child: const Padding(
                                  padding: AppSpacing.paddingHorizontal12,
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppColors.surface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
