//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/auth/screens/login_screen.dart';
//import 'package:vegon_user/features/auth/screens/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CustomImageView(
                  imageUrl: AppImages.onboardingBg,
                  height: AppSpacing.screenHeight * 0.42,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: AppSpacing.screenHeight * 0.15,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.transparent, AppColors.background],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: AppSpacing.paddingResponsiveHorizontal(0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.responsiveHeight(0.01),

                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingResponsiveAll(0.015),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: AppColors.surface,
                          size: AppSpacing.screenWidth * 0.05,
                        ),
                      ),
                      AppSpacing.responsiveWidth(0.025),
                      Text(
                        '${AppStrings.appName} Fresh',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  AppSpacing.responsiveHeight(0.025),

                  Text.rich(
                    TextSpan(
                      text: AppStrings.onboardingTitle1,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                      children: [
                        TextSpan(
                          text: AppStrings.onboardingTitle2,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.responsiveHeight(0.02),

                  Text(
                    AppStrings.onboardingSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // CustomButton(
                  //   text: AppStrings.login,
                  //   isOutlined: true,
                  //   onPressed: () {
                  //     Get.to(
                  //       () => const LoginScreen(),
                  //       transition: Transition.rightToLeft,
                  //     );
                  //   },
                  // ),
                  AppSpacing.responsiveHeight(0.04),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: AppSpacing.paddingSymmetric(
                            vertical: AppSpacing.screenHeight * 0.02,
                            horizontal: AppSpacing.screenWidth * 0.03,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                color: AppColors.primary,
                                size: AppSpacing.screenWidth * 0.055,
                              ),
                              AppSpacing.responsiveHeight(0.01),
                              Text(
                                AppStrings.sameDay,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.responsiveWidth(0.04),
                      Expanded(
                        child: Container(
                          padding: AppSpacing.paddingSymmetric(
                            vertical: AppSpacing.screenHeight * 0.02,
                            horizontal: AppSpacing.screenWidth * 0.03,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                color: AppColors.warning,
                                size: AppSpacing.screenWidth * 0.055,
                              ),
                              AppSpacing.responsiveHeight(0.01),
                              Text(
                                AppStrings.pesticideFree,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.responsiveHeight(0.04),

                  CustomButton(
                    text: AppStrings.getStarted,
                    icon: Icons.arrow_forward,
                    // onPressed: () {
                    //   Get.to(
                    //     () => const RegisterScreen(),
                    //     transition: Transition.rightToLeft,
                    //   );
                    // },
                    onPressed: () {
                      Get.to(
                        () => const LoginScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  AppSpacing.responsiveHeight(0.02),
                  const Divider(color: AppColors.borderLight, height: 1),
                  AppSpacing.responsiveHeight(0.03),

                  // RichText(
                  //   text: TextSpan(
                  //     text: AppStrings.joinFamiliesPrefix,
                  //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  //       color: AppColors.textSecondary,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //     children: [
                  //       TextSpan(
                  //         text: AppStrings.joinFamiliesHighlight,
                  //         style: Theme.of(context).textTheme.labelSmall
                  //             ?.copyWith(
                  //               color: AppColors.primary,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //       ),
                  //       TextSpan(text: AppStrings.joinFamiliesSuffix),
                  //     ],
                  //   ),
                  // ),
                  // AppSpacing.responsiveHeight(0.015),

                  // Row(
                  //   children: [
                  //     _buildAvatar(AppImages.avatar1, 0, AppColors.background),
                  //     _buildAvatar(AppImages.avatar2, 1, AppColors.background),
                  //     _buildAvatar(AppImages.avatar3, 2, AppColors.background),
                  //     Transform.translate(
                  //       offset: Offset(AppSpacing.screenWidth * -0.09, 0),
                  //       child: Container(
                  //         width: AppSpacing.screenWidth * 0.08,
                  //         height: AppSpacing.screenWidth * 0.08,
                  //         decoration: BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: AppColors.secondary,
                  //           border: Border.all(
                  //             color: AppColors.background,
                  //             width: 2,
                  //           ),
                  //         ),
                  //         alignment: Alignment.center,
                  //         child: Text(
                  //           AppStrings.eightKPlus,
                  //           style: Theme.of(context).textTheme.labelSmall
                  //               ?.copyWith(
                  //                 fontWeight: FontWeight.bold,
                  //                 color: AppColors.surface,
                  //               ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // AppSpacing.responsiveHeight(0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAvatar(String url, int index, Color borderColor) {
  //   return Transform.translate(
  //     offset: Offset((AppSpacing.screenWidth * -0.03) * index, 0),
  //     child: Container(
  //       width: AppSpacing.screenWidth * 0.08,
  //       height: AppSpacing.screenWidth * 0.08,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         border: Border.all(color: borderColor, width: 2),
  //       ),
  //       child: ClipOval(
  //         child: CustomImageView(
  //           imageUrl: url,
  //           width: AppSpacing.screenWidth * 0.08,
  //           height: AppSpacing.screenWidth * 0.08,
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
