//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/animation_overlay_helper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/product_details_controller.dart';

class ProductActionBar extends StatelessWidget {
  final Map<String, dynamic> productData;
  const ProductActionBar({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final ProductDetailsController controller =
        Get.find<ProductDetailsController>();
    final isAvailable = productData['isAvailable'] as bool? ?? true;
    final stockCount = productData['stockCount'] is int
        ? productData['stockCount'] as int
        : int.tryParse(productData['stockCount']?.toString() ?? '');
    final maxPerUser = productData['maxQuantityPerUser'] is int
        ? productData['maxQuantityPerUser'] as int
        : int.tryParse(productData['maxQuantityPerUser']?.toString() ?? '');

    return Row(
      children: [
        Container(
          height: AppSpacing.screenHeight * 0.055,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.1),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: AppColors.textSecondary),
                onPressed: controller.decrementQuantity,
                constraints: const BoxConstraints(),
                padding: AppSpacing.paddingSymmetric(
                  horizontal: AppSpacing.screenWidth * 0.03,
                ),
              ),
              Obx(
                () => Text(
                  '${controller.quantity.value}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: isAvailable
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                onPressed: () {
                  controller.incrementQuantity(
                    maxStock: stockCount,
                    maxPerUser: maxPerUser,
                  );
                },
                constraints: const BoxConstraints(),
                padding: AppSpacing.paddingSymmetric(
                  horizontal: AppSpacing.screenWidth * 0.03,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.responsiveWidth(0.04),

        Expanded(
          child: CustomButton(
            text: isAvailable ? AppStrings.addToCart : AppStrings.outOfStock,
            icon: isAvailable ? Icons.shopping_cart_outlined : Icons.block,
            backgroundColor: isAvailable
                ? AppColors.primary
                : AppColors.borderLight,
            textColor: isAvailable ? Colors.white : AppColors.textSecondary,
            onPressed: isAvailable
                ? () async {
                    final CartController cartController =
                        Get.isRegistered<CartController>()
                        ? Get.find<CartController>()
                        : Get.put(CartController());

                    final isSuccess = cartController.addToCart(
                      productData,
                      qty: controller.quantity.value,
                    );

                    if (await isSuccess) {
                      AnimationOverlayHelper.showRocketAddToCart(
                        // ignore: use_build_context_synchronously
                        context,
                        onComplete: () {},
                      );
                    }
                  }
                : () {},
          ),
        ),
      ],
    );
  }
}
