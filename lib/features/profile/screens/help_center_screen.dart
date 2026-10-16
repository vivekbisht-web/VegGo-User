//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/features/chat/utils/chat_access_state.dart';
import 'package:vegon_user/routes/app_routes.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.helpCenterDesc,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.h24,
            if (ChatAccessState.isCustomer)
              Card(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: AppSpacing.paddingAll16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.chatHelpEntry,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      AppSpacing.h8,
                      Text(
                        AppStrings.chatHelpDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      AppSpacing.h12,
                      CustomButton(
                        text: AppStrings.chatHelpEntry,
                        onPressed: () => Get.toNamed(AppRoutes.chat),
                      ),
                    ],
                  ),
                ),
              ),
            AppSpacing.h16,
            // Complaints Section
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: AppSpacing.paddingAll16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: AppSpacing.paddingAll10,
                          decoration: const BoxDecoration(
                            color: AppColors.mintLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.complaintSupportEntry,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              AppSpacing.h2,
                              Text(
                                AppStrings.complaintSupportDesc,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h16,
                    Row(
                      children: [
                        Expanded(
                          child: _HelpActionCard(
                            title: AppStrings.myComplaints,
                            subtitle: AppStrings.complaintTrackStatus,
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.complaintReopenedText,
                            iconBgColor: AppColors.complaintReopenedBg,
                            borderColor: AppColors.borderLight,
                            onTap: () => Get.toNamed(AppRoutes.myComplaints),
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: _HelpActionCard(
                            title: AppStrings.fileComplaint,
                            subtitle: AppStrings.complaintFileNewDesc,
                            icon: Icons.add_circle_outline_rounded,
                            iconColor: AppColors.primary,
                            iconBgColor: AppColors.mintLight,
                            borderColor:
                                AppColors.primary.withValues(alpha: 0.3),
                            onTap: () => Get.toNamed(AppRoutes.fileComplaint),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.h24,
            _buildFaqItem(context, AppStrings.faq1, AppStrings.faq1Desc),
            AppSpacing.h16,
            _buildFaqItem(context, AppStrings.faq2, AppStrings.faq2Desc),
            AppSpacing.h16,
            _buildFaqItem(context, AppStrings.faq3, AppStrings.faq3Desc),
          ],
        ),
      ),
    );
  }


  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        childrenPadding: AppSpacing.paddingOnly(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        children: [
          Text(
            answer,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _HelpActionCard extends StatelessWidget {
  const _HelpActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.borderColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        child: Padding(
          padding: AppSpacing.paddingAll12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: AppSpacing.paddingAll6,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              AppSpacing.h10,
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

