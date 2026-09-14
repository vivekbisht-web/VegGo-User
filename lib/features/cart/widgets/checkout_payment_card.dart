//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';

class CheckoutPaymentCard extends StatelessWidget {
  const CheckoutPaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildCardHeader(
            AppStrings.paymentMethod,
            Icons.credit_card_outlined,
            context,
          ),
          AppSpacing.responsiveHeight(0.02),

          _buildPaymentOption(
            0,
            Icons.payments_outlined,
            AppStrings.cod,
            AppStrings.codSubtitle,
            context,
          ),
          AppSpacing.responsiveHeight(0.015),
          _buildPaymentOption(
            1,
            Icons.account_balance_wallet_outlined,
            AppStrings.onlinePayment,
            AppStrings.onlinePaymentSubtitle,
            context,
          ),
          AppSpacing.responsiveHeight(0.015),
          _buildPaymentOption(
            2,
            Icons.credit_card_outlined,
            AppStrings.cardsPayment,
            AppStrings.cardsPaymentSubtitle,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    int index,
    IconData icon,
    String name,
    String? subtitle,
    BuildContext context,
  ) {
    final CheckoutController checkoutController =
        Get.find<CheckoutController>();
    return Obx(() {
      final isSelected = checkoutController.selectedPaymentIndex.value == index;
      return InkWell(
        onTap: () => checkoutController.selectedPaymentIndex.value = index,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
        child: Container(
          padding: AppSpacing.paddingResponsiveAll(0.035),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.borderLight.withValues(alpha: 0.5),
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.radius20,
                height: AppSpacing.radius20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: AppSpacing.radius10,
                          height: AppSpacing.radius10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              AppSpacing.responsiveWidth(0.035),

              Icon(
                icon,
                color: AppColors.textSecondary,
                size: AppSpacing.screenWidth * 0.06,
              ),
              AppSpacing.responsiveWidth(0.03),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.h2,
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: AppSpacing.radius20,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCardHeader(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingResponsiveAll(0.02),
          decoration: const BoxDecoration(
            color: AppColors.mintBadge,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.screenWidth * 0.05,
          ),
        ),
        AppSpacing.responsiveWidth(0.03),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
