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
                        if (avatarUrl.isNotEmpty) {
                          return CustomImageView(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                          );
                        }
                        return Icon(
                          Icons.person,
                          size: AppSpacing.screenWidth * 0.1,
                          color: AppColors.textSecondary,
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    AppSpacing.h4,
                    Obx(() {
                      final phone = controller.phone;
                      if (phone.isEmpty) return const SizedBox.shrink();
                      return Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: AppColors.surface.withValues(alpha: 0.8),
                            size: AppSpacing.screenWidth * 0.032,
                          ),
                          AppSpacing.w4,
                          Expanded(
                            child: Text(
                              phone,
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
                      );
                    }),
                    AppSpacing.h6,

                    // Verified Badge + Member Since
                    Obx(() {
                      final isVerified = controller.isVerified;
                      final memberSinceYear = controller.memberSinceYear;
                      return Wrap(
                        spacing: AppSpacing.screenWidth * 0.015,
                        runSpacing: AppSpacing.radius4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: AppSpacing.paddingSymmetric(
                              horizontal: AppSpacing.radius6,
                              vertical: AppSpacing.radius2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.verifiedBackground,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius20,
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
                                  size: AppSpacing.radius12,
                                ),
                                AppSpacing.w4,
                                Text(
                                  isVerified
                                      ? AppStrings.verified
                                      : AppStrings.customerRole,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.verifiedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (memberSinceYear != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.surface.withValues(
                                    alpha: 0.8,
                                  ),
                                  size: AppSpacing.radius12,
                                ),
                                AppSpacing.w4,
                                Text(
                                  '${AppStrings.memberSince} $memberSinceYear',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.surface.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              // Edit Profile Button
              Material(
                color: AppColors.surface.withValues(alpha: 0.22),
                shape: CircleBorder(
                  side: BorderSide(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Get.to(() => const EditProfileScreen()),
                  child: Padding(
                    padding: AppSpacing.paddingAll8,
                    child: Icon(
                      Icons.edit_outlined,
                      size: AppSpacing.screenWidth * 0.045,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Gold Member Card Banner
          // AppSpacing.h16,
          // GestureDetector(
          //   onTap: () {},
          //   child: Container(
          //     padding: AppSpacing.paddingResponsiveSymmetric(
          //       horizontal: 0.03,
          //       vertical: 0.025,
          //     ),
          //     decoration: BoxDecoration(
          //       color: AppColors.goldBackground,
          //       borderRadius: BorderRadius.circular(
          //         AppSpacing.screenWidth * 0.03,
          //       ),
          //       border: Border.all(color: AppColors.goldBorder),
          //     ),
          //     child: Row(
          //       children: [
          //         Container(
          //           padding: AppSpacing.paddingAll4,
          //           decoration: const BoxDecoration(
          //             color: AppColors.goldBorder,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Icon(
          //             Icons.star,
          //             color: AppColors.goldText,
          //             size: AppSpacing.screenWidth * 0.045,
          //           ),
          //         ),
          //         AppSpacing.w10,
          //         Expanded(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 AppStrings.dailyMarketClub,
          //                 style: Theme.of(context).textTheme.bodyMedium
          //                     ?.copyWith(
          //                       color: AppColors.textPrimary,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //               ),
          //               Text(
          //                 AppStrings.goldMember,
          //                 style: Theme.of(context).textTheme.bodySmall
          //                     ?.copyWith(color: AppColors.goldText),
          //               ),
          //             ],
          //           ),
          //         ),
          //         Icon(
          //           Icons.chevron_right,
          //           color: AppColors.textSecondary,
          //           size: AppSpacing.screenWidth * 0.05,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
