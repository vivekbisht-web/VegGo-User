//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
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

    return Container(
      padding: AppSpacing.paddingFromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.chipBorder.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 46,
              child: InkWell(
                onTap: () => Get.to(() => CartScreen()),
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
                child: Container(
                  height: 48,
                  padding: AppSpacing.paddingHorizontal8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                  ),
                  child: Obx(() {
                    final int count = cartController.totalItems;
                    final double total = cartController.total;
                    final totalStr =
                        '${AppStrings.rupeeSymbol}${total.toStringAsFixed(total % 1 == 0 ? 0 : 2)}';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            AppSpacing.w4,
                            Text(
                              '${AppStrings.viewCart} ($count)',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                        AppSpacing.h2,
                        Text(
                          totalStr,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            AppSpacing.w10,

            Expanded(
              flex: 54,
              child: InkWell(
                onTap: () {
                  final details = productController.productDetails.value;
                  final itemMap =
                      details?.toMap() ??
                      Map<String, dynamic>.from(productData);
                  cartController.addToCart(
                    itemMap,
                    qty: productController.quantity.value,
                  );
                  Get.to(() => CartScreen());
                },
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.buyNow,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                          ),
                          AppSpacing.w4,
                          const Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: AppColors.saleYellow,
                          ),
                        ],
                      ),
                      AppSpacing.h2,
                      Text(
                        AppStrings.fastAndSafeCheckout,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
