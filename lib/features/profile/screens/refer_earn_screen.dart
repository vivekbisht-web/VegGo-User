import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(context),
            AppSpacing.responsiveHeight(0.025),
            _buildReferralCodeCard(context),
            AppSpacing.responsiveHeight(0.025),
            _buildStatsCard(context),
            AppSpacing.responsiveHeight(0.03),
            _buildHowItWorksSection(context),
            AppSpacing.responsiveHeight(0.025),
            _buildShareButton(context),
            AppSpacing.responsiveHeight(0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
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
        children: [
          Container(
            padding: AppSpacing.paddingResponsiveAll(0.035),
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.surface,
              size: AppSpacing.screenWidth * 0.12,
            ),
          ),
          AppSpacing.h12,
          Text(
            AppStrings.referAndEarnTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.h8,
          Text(
            AppStrings.referAndEarnSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.surface.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.yourReferralCode,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: AppSpacing.paddingResponsiveSymmetric(
                  horizontal: 0.04,
                  vertical: 0.012,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.02,
                  ),
                ),
                child: Text(
                  AppStrings.defaultReferralCode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              CustomButton(
                text: AppStrings.copyCode,
                icon: Icons.copy_rounded,
                width: AppSpacing.screenWidth * 0.28,
                backgroundColor: AppColors.primary,
                textColor: AppColors.surface,
                onPressed: () {
                  Clipboard.setData(
                    const ClipboardData(text: AppStrings.defaultReferralCode),
                  );
                  Get.snackbar(
                    AppStrings.referEarn,
                    AppStrings.codeCopied,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: AppColors.surface,
                    margin: AppSpacing.paddingResponsiveAll(0.04),
                    borderRadius: AppSpacing.screenWidth * 0.03,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.yourReferralStats,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.responsiveHeight(0.015),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.people_alt_outlined,
                  label: AppStrings.successfulInvites,
                  value: AppStrings.invitesCount,
                ),
              ),
              Container(
                height: AppSpacing.screenWidth * 0.12,
                width: 1,
                color: AppColors.borderLight,
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: AppStrings.totalRewardsEarned,
                  value: AppStrings.rewardsEarnedValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: AppSpacing.screenWidth * 0.06,
        ),
        AppSpacing.h4,
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.h2,
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.howItWorks,
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
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              _buildStepRow(
                context,
                stepNumber: AppStrings.step1Number,
                title: AppStrings.referStep1Title,
                description: AppStrings.referStep1Desc,
              ),
              _buildStepDivider(),
              _buildStepRow(
                context,
                stepNumber: AppStrings.step2Number,
                title: AppStrings.referStep2Title,
                description: AppStrings.referStep2Desc,
              ),
              _buildStepDivider(),
              _buildStepRow(
                context,
                stepNumber: AppStrings.step3Number,
                title: AppStrings.referStep3Title,
                description: AppStrings.referStep3Desc,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSpacing.screenWidth * 0.08,
          height: AppSpacing.screenWidth * 0.08,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Padding(
      padding: AppSpacing.paddingResponsiveSymmetric(vertical: 0.015),
      child: Divider(height: 1, color: AppColors.borderLight),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return CustomButton(
      text: AppStrings.shareReferralLink,
      icon: Icons.share_rounded,
      backgroundColor: AppColors.primary,
      textColor: AppColors.surface,
      onPressed: () {
        Clipboard.setData(
          const ClipboardData(text: AppStrings.referralShareText),
        );
        Get.snackbar(
          AppStrings.referEarn,
          AppStrings.inviteSharedSuccess,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: AppColors.surface,
          margin: AppSpacing.paddingResponsiveAll(0.04),
          borderRadius: AppSpacing.screenWidth * 0.03,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }
}
