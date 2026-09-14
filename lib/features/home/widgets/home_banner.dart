//
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';

import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';
import 'package:vegon_user/features/home/models/banner_models.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  final HomeController _homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  static const Duration _autoScrollInterval = Duration(seconds: 4);
  static const Duration _animationDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScrollTimer();
  }

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;
      final banners = _homeController.banners;
      if (banners.isEmpty) return;

      final nextIndex = (_currentIndex + 1) % banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banners = _homeController.banners;

      if (_homeController.isBannersLoading.value && banners.isEmpty) {
        return SizedBox(
          height: (AppSpacing.screenHeight * AppSpacing.bannerHeightRatio)
              .clamp(AppSpacing.bannerHeightMin, AppSpacing.bannerHeightMax),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (banners.isEmpty) return const SizedBox.shrink();

      final width = AppSpacing.screenWidth;
      final bannerHeight =
          (AppSpacing.screenHeight * AppSpacing.bannerHeightRatio).clamp(
            AppSpacing.bannerHeightMin,
            AppSpacing.bannerHeightMax,
          );

      return SizedBox(
        height: bannerHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return _BannerCard(banner: banner, width: width);
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.radius6,
                child: _BannerDots(
                  count: banners.length,
                  activeIndex: _currentIndex,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _BannerCard extends StatelessWidget {
  final BannerDataModel banner;
  final double width;

  const _BannerCard({required this.banner, required this.width});

  @override
  Widget build(BuildContext context) {
    final title = banner.title;
    final subtitle = banner.subtitle;
    final info = AppStrings.freeDeliveryAbove199;
    final imageUrl = banner.imageUrl;
    final buttonText = AppStrings.shopNow;
    final bgColor = AppColors.bannerPastelGreen;
    final textColor = AppColors.bannerDarkGreen;

    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: bgColor),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: width * AppSpacing.bannerImageWidthRatio,
            child: CustomImageView(imageUrl: imageUrl, fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    bgColor,
                    bgColor.withValues(alpha: 0.95),
                    bgColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: AppSpacing.bannerPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: AppSpacing.bannerBadgePadding,
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius4,
                          ),
                        ),
                        child: Text(
                          AppStrings.specialOffer,
                          style: textTheme.labelSmall?.copyWith(
                            color: textColor,
                            fontSize: AppSpacing.bannerFontSizeBadge,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontSize: AppSpacing.bannerFontSizeTitle,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.h2,
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontSize: AppSpacing.bannerFontSizeSubtitle,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.h2,
                      Text(
                        info,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: AppSpacing.bannerFontSizeInfo,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: buttonText,
                  height: AppSpacing.bannerButtonHeight,
                  width: AppSpacing.bannerButtonWidth,
                  borderRadius: AppSpacing.radius16,
                  textStyle: textTheme.labelSmall?.copyWith(
                    color: AppColors.surface,
                    fontSize: AppSpacing.bannerFontSizeButton,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () {
                    Get.find<DashboardController>().changeTabIndex(1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _BannerDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: AppSpacing.paddingHorizontal4,
          width: isActive
              ? AppSpacing.bannerDotActiveWidth
              : AppSpacing.bannerDotInactiveWidth,
          height: AppSpacing.bannerDotHeight,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.bannerDarkGreen
                : AppColors.mintBadge.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppSpacing.radius4),
          ),
        );
      }),
    );
  }
}
