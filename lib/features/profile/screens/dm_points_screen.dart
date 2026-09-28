import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';

class DmPointsScreen extends StatelessWidget {
  const DmPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.paddingResponsiveAll(0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPointsCard(context),
              AppSpacing.responsiveHeight(0.03),
              _buildHowToEarnSection(context),
              AppSpacing.responsiveHeight(0.03),
              _buildHistorySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.06),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.availableDmPoints,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.surface,
                ),
              ),
              Container(
                padding: AppSpacing.paddingResponsiveSymmetric(
                  horizontal: 0.025,
                  vertical: 0.006,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(50),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.03,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.surface,
                      size: AppSpacing.screenWidth * 0.04,
                    ),
                    AppSpacing.w4,
                    Text(
                      AppStrings.goldMember,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppStrings.totalPointsBalance,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.w6,
              Text(
                AppStrings.pts,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.surface.withAlpha(220),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.h4,
          Text(
            AppStrings.pointsValueSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.surface.withAlpha(220),
            ),
          ),
          AppSpacing.responsiveHeight(0.02),
          CustomButton(
            text: AppStrings.redeemPoints,
            icon: Icons.card_giftcard_outlined,
            backgroundColor: AppColors.surface,
            textColor: AppColors.primary,
            onPressed: () {
              Get.snackbar(
                AppStrings.dmPoints,
                AppStrings.pointsRedeemSuccess,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: AppColors.surface,
                margin: AppSpacing.paddingResponsiveAll(0.04),
                borderRadius: AppSpacing.screenWidth * 0.03,
                duration: const Duration(seconds: 3),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.howToEarnPoints,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.responsiveHeight(0.015),
        Container(
          padding: AppSpacing.paddingResponsiveAll(0.04),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
            border: Border.all(
              color: AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              _buildEarnRuleRow(
                context,
                icon: Icons.shopping_basket_outlined,
                title: AppStrings.earnPointsShopTitle,
                description: AppStrings.earnPointsShopDesc,
              ),
              _buildDivider(),
              _buildEarnRuleRow(
                context,
                icon: Icons.rate_review_outlined,
                title: AppStrings.earnPointsReviewTitle,
                description: AppStrings.earnPointsReviewDesc,
              ),
              _buildDivider(),
              _buildEarnRuleRow(
                context,
                icon: Icons.group_add_outlined,
                title: AppStrings.earnPointsReferTitle,
                description: AppStrings.earnPointsReferDesc,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarnRuleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.paddingResponsiveAll(0.025),
          decoration: BoxDecoration(
            color: AppColors.successBackground,
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.025),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.screenWidth * 0.055,
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.h4,
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.pointsHistory,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.responsiveHeight(0.015),
        _buildHistoryTile(
          context,
          title: AppStrings.orderReward,
          subtitle: AppStrings.pointsDate1,
          pointsText: AppStrings.pointsPlus25,
          isCredit: true,
        ),
        _buildHistoryTile(
          context,
          title: AppStrings.welcomeBonus,
          subtitle: AppStrings.pointsDate2,
          pointsText: AppStrings.pointsPlus100,
          isCredit: true,
        ),
        _buildHistoryTile(
          context,
          title: AppStrings.redeemedOnOrder,
          subtitle: AppStrings.pointsDate3,
          pointsText: AppStrings.pointsMinus50,
          isCredit: false,
        ),
        _buildHistoryTile(
          context,
          title: AppStrings.bonusCampaign,
          subtitle: AppStrings.pointsDate4,
          pointsText: AppStrings.pointsPlus175,
          isCredit: true,
        ),
      ],
    );
  }

  Widget _buildHistoryTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String pointsText,
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
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: AppSpacing.paddingResponsiveAll(0.02),
                  decoration: BoxDecoration(
                    color: isCredit
                        ? AppColors.successBackground
                        : AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.screenWidth * 0.02,
                    ),
                  ),
                  child: Icon(
                    isCredit ? Icons.stars_rounded : Icons.shopping_cart_outlined,
                    color: isCredit ? AppColors.primary : AppColors.error,
                    size: AppSpacing.screenWidth * 0.05,
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.h2,
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.w12,
          Text(
            pointsText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: AppSpacing.paddingResponsiveSymmetric(vertical: 0.015),
      child: Divider(
        height: 1,
        color: AppColors.borderLight,
      ),
    );
  }
}
