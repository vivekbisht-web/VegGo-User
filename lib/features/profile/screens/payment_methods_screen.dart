import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_icon_button.dart';
import 'package:vegon_user/core/widgets/section_header.dart';
import 'package:vegon_user/features/profile/screens/add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: Padding(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: AppStrings.yourSavedWallets),
            AppSpacing.h8,
            Text(
              AppStrings.yourSavedWalletsDesc,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.h24,
            _buildPaymentCard(
              context,
              icon: Icons.credit_card,
              title: AppStrings.visaEnding,
              isDefault: true,
            ),
            AppSpacing.h16,
            _buildPaymentCard(
              context,
              icon: Icons.apple,
              title: AppStrings.applePay,
              isDefault: false,
            ),
            AppSpacing.h16,
            _buildPaymentCard(
              context,
              icon: Icons.g_mobiledata,
              title: AppStrings.googlePay,
              isDefault: false,
            ),
            const Spacer(),
            CustomButton(
              text: AppStrings.addNewPayment,
              onPressed: () => Get.to(() => const AddPaymentMethodScreen()),
            ),
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDefault,
  }) {
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingAll8,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (isDefault) ...[
                  AppSpacing.h4,
                  Container(
                    padding: AppSpacing.paddingSymmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppStrings.defaultText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          CustomIconButton(
            icon: Icons.edit_outlined,
            color: AppColors.textSecondary,
            onPressed: () => Get.to(() => const AddPaymentMethodScreen()),
          ),
          CustomIconButton(
            icon: Icons.delete_outline,
            color: AppColors.error,
            onPressed: () {
              Get.snackbar(
                title,
                AppStrings.success,
                backgroundColor: AppColors.surface,
                colorText: AppColors.textPrimary,
              );
            },
          ),
        ],
      ),
    );
  }
}
