import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: Padding(
        padding: AppSpacing.paddingResponsiveAll(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingResponsiveAll(0.06),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  AppSpacing.screenWidth * 0.04,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.walletBalance,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    '${AppStrings.currencySymbol}450.00',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.responsiveHeight(0.02),
                  CustomButton(
                    text: AppStrings.addMoney,
                    icon: Icons.add,
                    backgroundColor: AppColors.surface,
                    textColor: AppColors.primary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            AppSpacing.responsiveHeight(0.04),

            Text(
              AppStrings.recentTransactions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.responsiveHeight(0.02),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildTransactionTile(
                      context,
                      title: 'Cashback Received',
                      subtitle: 'Jul 24, 2026',
                      amount: '+${AppStrings.currencySymbol}50.00',
                      isCredit: true,
                    ),
                    _buildTransactionTile(
                      context,
                      title: 'Paid for Order #DM-2940110',
                      subtitle: 'Jul 22, 2026',
                      amount: '-${AppStrings.currencySymbol}230.00',
                      isCredit: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
  }) {
    return Container(
      margin: AppSpacing.paddingOnly(bottom: AppSpacing.screenWidth * 0.02),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
