import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';

enum CartActionButtonStyle { simple, dynamicPill }

class CartActionButton extends StatelessWidget {
  final CartActionButtonStyle style;
  final VoidCallback? onCartTap;
  final CartController cartController;

  const CartActionButton({
    super.key,
    this.style = CartActionButtonStyle.simple,
    this.onCartTap,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    if (style == CartActionButtonStyle.simple) {
      return _buildSimpleCartButton(context);
    }
    return _buildDynamicCartPill(context);
  }

  Widget _buildSimpleCartButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onCartTap != null) {
          onCartTap!();
        } else {
          Get.to(() => CartScreen());
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius20),
      child: Padding(
        padding: AppSpacing.paddingAll4,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 23,
                color: AppColors.textPrimary,
              ),
              Positioned(
                right: -3,
                top: -3,
                child: Obx(() {
                  final count = cartController.totalItems;
                  if (count <= 0) return const SizedBox.shrink();

                  return Container(
                    padding: AppSpacing.paddingAll4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        height: 1,
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
  }

  Widget _buildDynamicCartPill(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onCartTap != null) {
          onCartTap!();
        } else {
          Get.to(() => CartScreen());
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(
            color: AppColors.chipBorder.withValues(alpha: 0.9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.orangeFlame,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(11),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Obx(() {
                      final count = cartController.totalItems;
                      if (count <= 0) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 13,
                          minHeight: 13,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            AppSpacing.h2,
            Padding(
              padding: AppSpacing.paddingSymmetric(horizontal: 8),
              child: Obx(() {
                final total = PriceFormatter.format(cartController.totalAmount);
                return Text(
                  total,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
