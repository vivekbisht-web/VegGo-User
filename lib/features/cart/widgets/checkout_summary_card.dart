import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';
import 'package:vegon_user/features/cart/screens/order_success_screen.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final CheckoutController checkoutController =
        Get.find<CheckoutController>();

    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.borderLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Obx(() {
        // Safely resolve the first cart, or null if data isn't ready yet.
        final cart =
            checkoutController.checkoutSummary.value?.data?.carts?.isNotEmpty ==
                true
            ? checkoutController.checkoutSummary.value!.data!.carts![0]
            : null;

        if (cart == null) {
          // Data not loaded yet (or empty) — show a lightweight placeholder
          // instead of crashing on a null check.
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final subtotal = cart.subtotal?.toString() ?? '0';
        final deliveryFee = cart.deliveryFee;
        final estimatedTax = cart.estimatedTax?.toString() ?? '0';
        final total = cart.total?.toString() ?? '0';

        final subtotalLabel =
            '${AppStrings.subtotal} (${cartController.totalItems} ${AppStrings.items})';

        final isDeliveryFree = (deliveryFee == null || deliveryFee == 0);

        return Column(
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

            _buildSummaryItem(
              subtotalLabel,
              '${AppStrings.currencySymbol}$subtotal',
              context,
            ),
            AppSpacing.responsiveHeight(0.012),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.deliveryFee,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  isDeliveryFree
                      ? AppStrings.free
                      : '${AppStrings.currencySymbol}${deliveryFee.toString()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDeliveryFree
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            AppSpacing.responsiveHeight(0.012),

            _buildSummaryItem(
              AppStrings.estimatedTaxes,
              '${AppStrings.currencySymbol}$estimatedTax',
              context,
            ),

            Obx(() {
              if (cartController.appliedPromo.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  AppSpacing.responsiveHeight(0.012),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppStrings.discount} (${cartController.appliedPromo.value})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
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
              );
            }),

            AppSpacing.responsiveHeight(0.02),
            _buildLineDivider(),
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
                  '${AppStrings.currencySymbol}$total',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.responsiveHeight(0.03),

            Obx(() {
              final isOnline =
                  checkoutController.selectedPaymentIndex.value != 0;
              return CustomButton(
                text: isOnline
                    ? AppStrings.payWithRazorpay
                    : AppStrings.placeOrder,
                icon: isOnline ? Icons.payment_outlined : Icons.lock_outline,
                isLoading: checkoutController.isProcessingOrder.value,
                onPressed: () {
                  checkoutController.placeOrder((response) {
                    cartController.clearCart();
                    Get.off(() => const OrderSuccessScreen());
                  });
                },
              );
            }),
            AppSpacing.responsiveHeight(0.015),

            Center(
              child: Padding(
                padding: AppSpacing.paddingResponsiveHorizontal(0.02),
                child: Text(
                  AppStrings.termsFooter,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryItem(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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

  Widget _buildLineDivider() {
    return Container(
      color: AppColors.borderLight.withValues(alpha: 0.5),
      height: 1.0,
      width: double.infinity,
    );
  }
}
