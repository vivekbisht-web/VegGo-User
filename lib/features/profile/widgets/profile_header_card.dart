import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';
import 'package:vegon_user/features/profile/screens/edit_profile_screen.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController controller =
        Get.isRegistered<UserProfileController>()
        ? Get.find<UserProfileController>()
        : Get.put(UserProfileController());

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Camera Icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: AppSpacing.screenWidth * 0.18,
                    height: AppSpacing.screenWidth * 0.18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.screenWidth * 0.18,
                      ),
                      child: Obx(() {
                        final avatarUrl = controller.avatar;
                        return CustomImageView(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                        );
                      }),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const EditProfileScreen()),
                    child: Container(
                      padding: AppSpacing.paddingAll4,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                        size: AppSpacing.screenWidth * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.w12,

              // User Info Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return Text(
                        controller.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    AppSpacing.h4,
                    Obx(() {
                      final email = controller.email;
                      if (email.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: AppSpacing.paddingOnly(bottom: AppSpacing.radius2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: AppColors.surface.withValues(alpha: 0.8),
                              size: AppSpacing.screenWidth * 0.035,
                            ),
                            AppSpacing.w4,
                            Expanded(
                              child: Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.surface.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      final phone = controller.phone;
                      if (phone.isEmpty) return const SizedBox.shrink();
                      return Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: AppColors.surface.withValues(alpha: 0.8),
                            size: AppSpacing.screenWidth * 0.035,
                          ),
                          AppSpacing.w4,
                          Text(
                            phone,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.surface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                          ),
                        ],
                      );
                    }),
                    AppSpacing.h6,

                    // Verified Badge
                    Obx(() {
                      final isVerified = controller.isVerified;
                      return Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: AppSpacing.screenWidth * 0.02,
                          vertical: AppSpacing.radius2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.verifiedBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.screenWidth * 0.03,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified
                                  ? Icons.check_circle
                                  : Icons.verified_user_outlined,
                              color: AppColors.verifiedText,
                              size: AppSpacing.screenWidth * 0.035,
                            ),
                            AppSpacing.w4,
                            Text(
                              isVerified
                                  ? AppStrings.verified
                                  : AppStrings.customerRole,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.verifiedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Edit Profile Button
              InkWell(
                onTap: () => Get.to(() => const EditProfileScreen()),
                borderRadius: BorderRadius.circular(AppSpacing.radius20),
                child: Container(
                  padding: AppSpacing.paddingSymmetric(
                    horizontal: AppSpacing.radius10,
                    vertical: AppSpacing.radius6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppSpacing.radius20),
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: AppSpacing.radius14,
                        color: AppColors.surface,
                      ),
                      AppSpacing.w4,
                      Text(
                        AppStrings.editProfile,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h16,

          // Gold Member Card Banner
          GestureDetector(
            onTap: () {
              // Navigates or displays club details
            },
            child: Container(
              padding: AppSpacing.paddingResponsiveSymmetric(
                horizontal: 0.03,
                vertical: 0.025,
              ),
              decoration: BoxDecoration(
                color: AppColors.goldBackground,
                borderRadius: BorderRadius.circular(
                  AppSpacing.screenWidth * 0.03,
                ),
                border: Border.all(color: AppColors.goldBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingAll4,
                    decoration: const BoxDecoration(
                      color: AppColors.goldBorder,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: AppColors.goldText,
                      size: AppSpacing.screenWidth * 0.045,
                    ),
                  ),
                  AppSpacing.w10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.dailyMarketClub,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          AppStrings.goldMember,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.goldText),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: AppSpacing.screenWidth * 0.05,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
