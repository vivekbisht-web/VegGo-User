//
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
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
      if (banners.length <= 1) return;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : AppSpacing.screenWidth;
        // Natural banner ratio (~3.2:1) matching provided banner artwork
        final double h = (w * 0.31).clamp(135.0, 175.0);
        final double s = h / 145.0;

        return Obx(() {
          final banners = _homeController.banners;
          final int itemCount = banners.isNotEmpty ? banners.length : 1;

          return Container(
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: itemCount,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final banner = banners.isNotEmpty ? banners[index] : null;
                      return _BannerCard(banner: banner, width: w, scale: s);
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8 * s,
                    child: _BannerDots(
                      count: itemCount > 1 ? itemCount : 3,
                      activeIndex: _currentIndex,
                      scale: s,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerDataModel? banner;
  final double width;
  final double scale;

  const _BannerCard({
    required this.banner,
    required this.width,
    required this.scale,
  });

  void _onShopNowTap() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeTabIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = (banner != null && banner!.title.trim().isNotEmpty)
        ? banner!.title.trim()
        : AppStrings.bannerHeadlineFallback;
    final subtitle = (banner != null && banner!.subtitle.trim().isNotEmpty)
        ? banner!.subtitle.trim()
        : AppStrings.bannerSubtitleFallback;

    return Stack(
      children: [
        // 1. Full-width high-resolution artwork background
        Positioned.fill(
          child: Image.asset(
            AppImages.bannerFreshDeals,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // 2. Dynamic API data text overlaid on the left side
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              12 * scale,
              12 * scale,
              12 * scale,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: width * 0.46,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge: FRESH DEALS
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 3 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bannerDarkGreen,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius20,
                        ),
                      ),
                      child: Text(
                        AppStrings.freshDealsBadge,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ),
                    SizedBox(height: 5 * scale),

                    // Headline from API
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.bannerDarkGreen,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4 * scale),

                    // Subtitle from API
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.bannerSubtitleGreen,
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 8 * scale),

                    // Action button: Shop Now ->
                    _ShopNowButton(scale: scale, onTap: _onShopNowTap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopNowButton extends StatelessWidget {
  final VoidCallback onTap;
  final double scale;

  const _ShopNowButton({required this.onTap, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bannerDarkGreen,
      borderRadius: BorderRadius.circular(AppSpacing.radius20),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius20),
        onTap: onTap,
        child: SizedBox(
          height: 28 * scale,
          width: 100 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.shopNow,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 5 * scale),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size: 14 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double scale;

  const _BannerDots({
    required this.count,
    required this.activeIndex,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3.5 * scale),
          width: 7 * scale,
          height: 7 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.bannerDarkGreen
                : AppColors.bannerDotInactive,
          ),
        );
      }),
    );
  }
}
