//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/checkout_screen.dart';

class CartOrderSummaryCard extends StatelessWidget {
  CartOrderSummaryCard({super.key});

  final CartController cartController = Get.find<CartController>();
  final TextEditingController promoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (cartController.appliedPromo.isEmpty &&
        promoController.text.isNotEmpty) {
      promoController.clear();
    }

    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderSummary,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.responsiveHeight(0.02),

          _buildSummaryRow(
            AppStrings.subtotal,
            '${AppStrings.currencySymbol}${cartController.currentCart.value?.totalAmount.toString()}',
            context,
          ),
          AppSpacing.responsiveHeight(0.01),

          _buildSummaryRow(
            AppStrings.deliveryFee,
            '${AppStrings.currencySymbol}${cartController.currentCart.value?.deliveryFee.toString()}',
            context,
            trailingWidget: InkWell(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(AppStrings.deliveryFeeInfo),
                    content: const Text(AppStrings.deliveryFeeDesc),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          AppStrings.gotIt,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: AppSpacing.paddingOnly(
                  left: AppSpacing.screenWidth * 0.01,
                ),
                child: Icon(
                  Icons.help_outline,
                  size: AppSpacing.screenWidth * 0.04,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          AppSpacing.responsiveHeight(0.01),

          _buildSummaryRow(
            AppStrings.estimatedTaxes,
            '${AppStrings.currencySymbol}${cartController.currentCart.value?.estimatedTax.toString()}',
            context,
          ),

          if (cartController.appliedPromo.isNotEmpty) ...[
            AppSpacing.responsiveHeight(0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${AppStrings.promoPrefix}${cartController.appliedPromo.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.responsiveWidth(0.02),
                    InkWell(
                      onTap: () {
                        cartController.removePromoCode();
                        promoController.clear();
                      },
                      child: Text(
                        AppStrings.promoRemove,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.error.withValues(alpha: 0.5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '-${AppStrings.currencySymbol}${cartController.discountAmount.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          AppSpacing.responsiveHeight(0.02),
          _buildDashedLine(context),
          AppSpacing.responsiveHeight(0.02),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: AppStrings.promoCode,
                  controller: promoController,
                ),
              ),
              AppSpacing.responsiveWidth(0.03),
              CustomButton(
                text: AppStrings.apply,
                width: 90,
                backgroundColor: AppColors.borderLight.withValues(alpha: 0.5),
                textColor: AppColors.textPrimary,
                onPressed: () {
                  final code = promoController.text;
                  if (code.isNotEmpty) {
                    cartController.applyPromoCode(code);
                  }
                },
              ),
            ],
          ),

          AppSpacing.responsiveHeight(0.02),
          _buildDashedLine(context),
          AppSpacing.responsiveHeight(0.02),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${AppStrings.currencySymbol}${cartController.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.responsiveHeight(0.03),

          CustomButton(
            text: AppStrings.proceedToCheckout,
            icon: Icons.arrow_forward,
            onPressed: () {
              Get.to(() => CheckoutScreen());
            },
          ),

          AppSpacing.responsiveHeight(0.025),

          Container(
            padding: AppSpacing.paddingResponsiveAll(0.03),
            decoration: BoxDecoration(
              color: AppColors.mintBadge,
              borderRadius: BorderRadius.circular(
                AppSpacing.screenWidth * 0.02,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.responsiveWidth(0.02),
                Expanded(
                  child: Text(
                    AppStrings.carbonNeutralDesc,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    BuildContext context, {
    Widget? trailingWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            ?trailingWidget,
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine(BuildContext context) {
    return Row(
      children: List.generate(
        (AppSpacing.screenWidth / 8).floor(),
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0
                ? AppColors.borderLight.withValues(alpha: 0.5)
                : AppColors.transparent,
            height: 1,
          ),
        ),
      ),
    );
  }
}
