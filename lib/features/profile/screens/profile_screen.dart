import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';
import 'package:vegon_user/features/profile/widgets/profile_header_card.dart';
import 'package:vegon_user/features/profile/widgets/profile_menu_list.dart';
import 'package:vegon_user/features/profile/widgets/profile_orders_section.dart';
import 'package:vegon_user/features/profile/widgets/profile_promo_banner.dart';
import 'package:vegon_user/features/profile/widgets/profile_stats_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            final controller = Get.isRegistered<UserProfileController>()
                ? Get.find<UserProfileController>()
                : Get.put(UserProfileController());
            await controller.fetchUserProfile(showLoading: false);
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: AppSpacing.paddingResponsiveSymmetric(
              horizontal: 0.04,
              vertical: 0.02,
            ),
            child: Column(
              children: [
                const ProfileHeaderCard(),
                AppSpacing.h16,
                const ProfileStatsRow(),
                AppSpacing.h20,
                const ProfileOrdersSection(),
                AppSpacing.h20,
                const ProfileMenuList(),
                AppSpacing.h20,
                const ProfilePromoBanner(),
                AppSpacing.h24,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
