//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/app_dialogs.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/models/cart_item.dart';
import 'package:vegon_user/core/widgets/quantity_selector.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.03),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
            child: CustomImageView(
              imageUrl: item.image,
              width: AppSpacing.screenWidth * 0.18,
              height: AppSpacing.screenWidth * 0.18,
              fit: BoxFit.cover,
            ),
          ),
          AppSpacing.responsiveWidth(0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.responsiveHeight(0.005),
                Text(
                  item.unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.responsiveHeight(0.015),

                QuantitySelector(
                  quantity: item.quantity,
                  onIncrement: () => cartController.incrementItem(item.cartKey),
                  onDecrement: () => cartController.decrementItem(item.cartKey),
                  style: QuantitySelectorStyle.circular,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PriceFormatter.format(item.price * item.quantity),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.responsiveHeight(0.025),
              Material(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    AppDialogs.showConfirmationDialog(
                      context,
                      title: AppStrings.removeItem,
                      message:
                          '${AppStrings.removeItemDescPrefix}${item.name}${AppStrings.removeItemDescSuffix}',
                      confirmText: AppStrings.remove,
                      icon: Icons.delete_outline_rounded,
                      isDestructive: true,
                      onConfirm: () => cartController.removeItem(item.cartKey),
                    );
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
