import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';

class DrawerHeaderWidget extends StatelessWidget {
  final UserProfileController profileController;
  final VoidCallback onProfileTap;
  final VoidCallback onCloseTap;

  const DrawerHeaderWidget({
    super.key,
    required this.profileController,
    required this.onProfileTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingFromLTRB(16, topInset + 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkHeaderStart, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(AppSpacing.radius24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    color: AppColors.secondary,
                    size: AppSpacing.drawerIconSize,
                  ),
                  AppSpacing.w6,
                  Text(
                    AppStrings.veggoFresh,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: AppSpacing.paddingZero,
                constraints: const BoxConstraints(),
                onPressed: onCloseTap,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.surface,
                  size: AppSpacing.drawerCloseIconSize,
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.drawerAvatarSize,
                  height: AppSpacing.drawerAvatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: ClipOval(
                    child: Obx(() {
                      final avatar =
                          profileController.userData.value?.avatar ?? '';
                      return CustomImageView(
                        imageUrl: avatar,
                        height: AppSpacing.drawerAvatarSize,
                        width: AppSpacing.drawerAvatarSize,
                        fit: BoxFit.cover,
                      );
                    }),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final phone = profileController.phone;
                        final name = profileController.userData.value?.name;
                        final displayName = (name != null && name.isNotEmpty)
                            ? name
                            : (phone.isNotEmpty
                                ? AppStrings.customerWithPhone(phone)
                                : AppStrings.customer);
                        return Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      }),
                      AppSpacing.h2,
                      Obx(() {
                        final phone = profileController.phone;
                        final displayPhone = phone.isNotEmpty
                            ? phone
                            : AppStrings.noPhoneLinked;
                        return Text(
                          displayPhone,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mintHeader,
                          ),
                        );
                      }),
                      AppSpacing.h4,
                      Obx(() {
                        final isVerified = profileController.isVerified;
                        return Container(
                          padding: AppSpacing.paddingHorizontal8,
                          decoration: BoxDecoration(
                            color: AppColors.verifiedBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified
                                    ? Icons.check_circle_rounded
                                    : Icons.verified_user_outlined,
                                color: AppColors.verifiedText,
                                size: 12,
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
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.mintHeader,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
