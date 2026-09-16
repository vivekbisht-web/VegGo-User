//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';

class FloatingCartBar extends StatelessWidget {
  final double bottomPadding;
  final VoidCallback? onTap;

  const FloatingCartBar({
    super.key,
    this.bottomPadding = 8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Obx(() {
      final count = cartController.totalItems;
      if (count <= 0 || cartController.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final total = cartController.total;
      final priceStr = PriceFormatter.format(total);
      final itemLabel = count == 1 ? AppStrings.itemInCart : AppStrings.itemsInCart;

      return Container(
        padding: AppSpacing.paddingFromLTRB(16, 6, 16, bottomPadding),
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radius16),
            onTap: () {
              if (onTap != null) {
                onTap!();
              } else {
                Get.to(() => CartScreen());
              }
            },
            child: Padding(
              padding: AppSpacing.paddingFromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingAll8,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.surface,
                      size: 20,
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count $itemLabel',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.surface,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          priceStr,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.surface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.viewCart.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.surface,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      AppSpacing.w4,
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.surface,
                        size: 13,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
