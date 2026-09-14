//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/custom_icon_button.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class ProductDetailsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const ProductDetailsHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: AppSpacing.paddingResponsiveAll(0.02),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: CustomIconButton(
            icon: Icons.arrow_back,
            color: AppColors.primary,
            onPressed: () => Get.back(),
            size: 26.0,
            padding: AppSpacing.paddingAll8,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: AppSpacing.paddingResponsiveAll(0.02),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Obx(() {
              final count = cartController.totalItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomIconButton(
                    icon: Icons.shopping_cart_outlined,
                    color: AppColors.primary,
                    size: 26.0,
                    onPressed: () {
                      if (Get.isRegistered<DashboardController>()) {
                        Get.find<DashboardController>().changeTabIndex(2);
                      }
                      Get.back();
                    },
                    padding: AppSpacing.paddingAll8,
                  ),
                  if (count > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IgnorePointer(
                        child: Container(
                          padding: AppSpacing.paddingAll4,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.surface,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
