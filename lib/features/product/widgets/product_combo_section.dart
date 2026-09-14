//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/animation_overlay_helper.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/product/controllers/product_details_controller.dart';

class ProductComboSection extends StatelessWidget {
  const ProductComboSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final ProductDetailsController productController =
        Get.find<ProductDetailsController>();

    return Obx(() {
      final relatedProducts = productController.relatedProducts;
      if (relatedProducts.length < 2) {
        return const SizedBox.shrink(); // Need at least 2 items for a combo
      }
      
      final comboItems = relatedProducts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHorizontal16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.frequentlyBoughtTogether,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: AppSpacing.paddingSymmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.comboPurpleBadge,
                  borderRadius: BorderRadius.circular(AppSpacing.radius6),
                ),
                child: Text(
                  AppStrings.comboOffer,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.comboPurpleText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.h10,

        SizedBox(
          height: 160,
          child: ListView(
            padding: AppSpacing.paddingHorizontal16,
            scrollDirection: Axis.horizontal,
            children: [
              _buildComboItemCard(context, comboItems[0], cartController),
              _buildOperator(context, '+'),

              if (comboItems.length > 1) ...[
                _buildComboItemCard(context, comboItems[1], cartController),
                _buildOperator(context, comboItems.length > 2 ? '+' : '='),
              ],
              
              if (comboItems.length > 2) ...[
                _buildComboItemCard(context, comboItems[2], cartController),
                _buildOperator(context, '='),
              ],

              _buildComboSummaryCard(context, comboItems, cartController),
            ],
          ),
        ),
      ],
    );
    });
  }

    Widget _buildOperator(BuildContext context, String symbol) {
      return Container(
        alignment: Alignment.center,
        padding: AppSpacing.paddingSymmetric(horizontal: 6),
        child: Text(
          symbol,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

  Widget _buildComboItemCard(
    BuildContext context,
    dynamic itemData,
    CartController cartController,
  ) {
    final item = itemData.toJson();
    final String name = item['name']?.toString() ?? 'Product';
    final String unit = item['unit']?.toString() ?? '1 unit';
    final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final double originalPrice = (item['originalPrice'] as num?)?.toDouble() ?? (item['mrp'] as num?)?.toDouble() ?? price;
    final String image = item['image']?.toString() ?? item['imageUrl']?.toString() ?? '';

    return Container(
      width: 105,
      padding: AppSpacing.paddingAll8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(color: AppColors.chipBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: CustomImageView(
                imageUrl: image,
                height: 55,
                width: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),
          AppSpacing.h4,

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),

          Text(
            unit,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9.5,
            ),
          ),
          AppSpacing.h4,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.rupeeSymbol}${price.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${AppStrings.rupeeSymbol}${originalPrice.toInt()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.strikethrough,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  cartController.addToCart(item);
                  AnimationOverlayHelper.showRocketAddToCart(
                    context,
                    onComplete: () {},
                  );
                },
                borderRadius: BorderRadius.circular(AppSpacing.radius4),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radius4),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComboSummaryCard(
    BuildContext context,
    List<dynamic> comboItemsData,
    CartController cartController,
  ) {
    final comboItems = comboItemsData.map((e) => e.toJson()).toList();
    
    double totalPrice = 0.0;
    double originalTotalPrice = 0.0;
    
    for (final item in comboItems) {
      totalPrice += (item['price'] as num?)?.toDouble() ?? 0.0;
      originalTotalPrice += (item['originalPrice'] as num?)?.toDouble() ?? (item['mrp'] as num?)?.toDouble() ?? 0.0;
    }
    
    final discount = originalTotalPrice - totalPrice;
    return Container(
      width: 120,
      padding: AppSpacing.paddingAll10,
      decoration: BoxDecoration(
        color: AppColors.comboPurpleBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(color: AppColors.comboPurpleBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.totalPrice,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              AppSpacing.h2,
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${AppStrings.currencySymbol}${totalPrice.toInt()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  AppSpacing.w4,
                  Text(
                    '${AppStrings.currencySymbol}${originalTotalPrice.toInt()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.strikethrough,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              AppSpacing.h2,
              Text(
                'Save ${AppStrings.currencySymbol}${discount.toInt()}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.comboPurpleText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          InkWell(
            onTap: () {
              for (final item in comboItems) {
                cartController.addToCart(item, showSnackbarOnError: false);
              }
              AnimationOverlayHelper.showRocketAddToCart(
                context,
                onComplete: () {},
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radius6),
            child: Container(
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.comboPurpleButton,
                borderRadius: BorderRadius.circular(AppSpacing.radius6),
              ),
              child: Text(
                AppStrings.addCombo,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
