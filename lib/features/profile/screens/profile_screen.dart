//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
    );
  }
}
