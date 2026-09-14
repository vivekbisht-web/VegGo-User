//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/dashboard/screens/notification_screen.dart';
import 'package:vegon_user/features/profile/screens/profile_screen.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';

import 'package:vegon_user/features/home/controllers/location_controller.dart';
import 'package:vegon_user/features/home/controllers/home_search_controller.dart';
import 'package:vegon_user/features/profile/screens/saved_addresses_screen.dart';

class HomeHeaderSliver extends StatelessWidget {
  final bool showBackButton;
  const HomeHeaderSliver({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HomeHeader(showBackButton: showBackButton),
    );
  }
}

class HomeHeader extends StatelessWidget {
  final bool showBackButton;
  const HomeHeader({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;

    final heroHeight = (media.width * 0.49).clamp(225.0, 255.0);
    const locationHeight = 48.0;
    const searchHeight = 48.0;
    const sidePadding = 18.0;

    final LocationController locationController =
        Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final HomeSearchController searchController =
        Get.isRegistered<HomeSearchController>()
        ? Get.find<HomeSearchController>()
        : Get.put(HomeSearchController());

    return SizedBox(
      height: heroHeight + 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: heroHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppSpacing.radius24),
              ),
              child: CustomImageView(
                imageUrl: AppImages.homeHeaderBg,
                isAsset: true,
                height: heroHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            left: sidePadding,
            right: sidePadding,
            top: topInset + 13,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeaderIconButton(
                  icon: showBackButton
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.menu_rounded,
                  onTap: () {
                    if (showBackButton) {
                      final canPop = Navigator.canPop(context);
                      if (canPop) {
                        Get.back();
                      } else if (Get.isRegistered<DashboardController>()) {
                        Get.find<DashboardController>().changeTabIndex(0);
                      }
                    } else {
                      Scaffold.maybeOf(context)?.openDrawer();
                    }
                  },
                ),
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => Get.to(() => const NotificationScreen()),
                    ),
                    AppSpacing.w12,
                    CircleAvatar(
                      backgroundColor: AppColors.surface,
                      radius: 16,
                      child: _HeaderIconButton(
                        icon: Icons.person_outline_rounded,
                        iconColor: AppColors.darkHeaderStart,
                        onTap: () => Get.to(() => const ProfileScreen()),
                      ),
                    ),
                    AppSpacing.w12,
                    Obx(() {
                      final count = cartController.totalItems;
                      return _HeaderIconButton(
                        icon: Icons.shopping_cart_outlined,
                        badge: count > 0 ? '$count' : null,
                        onTap: () => Get.to(() => CartScreen()),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            left: sidePadding,
            top: heroHeight - 52,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
              onTap: () => Get.to(() => SavedAddressesScreen()),
              child: Container(
                height: locationHeight,
                constraints: BoxConstraints(
                  maxWidth: media.width - (sidePadding * 2),
                ),
                padding: AppSpacing.paddingHorizontal12,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.overlayLight.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: -2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    AppSpacing.w6,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.deliverTo,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                height: 1,
                              ),
                        ),
                        AppSpacing.h4,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              final locName =
                                  locationController.currentLocationName.value;
                              return ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: media.width * 0.35,
                                ),
                                child: Text(
                                  locName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        height: 1,
                                      ),
                                ),
                              );
                            }),
                            AppSpacing.w4,
                            GestureDetector(
                              onTap: () =>
                                  locationController.fetchAndSaveUserLocation(),
                              child: Obx(
                                () =>
                                    locationController.isFetchingLocation.value
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh_rounded,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: sidePadding,
            right: sidePadding,
            top: heroHeight - 4,
            child: Material(
              color: AppColors.transparent,
              child: Container(
                height: searchHeight,
                padding: AppSpacing.paddingFromLTRB(12, 0, 8, 0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.overlayLight.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: -2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    AppSpacing.w8,
                    Expanded(
                      child: CustomTextField(
                        hintText: '',
                        controller: searchController.searchTextController,
                        onChanged: searchController.onSearchQueryChanged,
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: AppSpacing.paddingVertical8,
                          hintText: AppStrings.searchVegPlaceholder,
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (searchController.searchQuery.value.isNotEmpty) {
                        return InkWell(
                          onTap: () {
                            searchController.clearSearch();
                            FocusScope.of(context).unfocus();
                          },
                          child: const Padding(
                            padding: AppSpacing.paddingAll4,
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_none_rounded,
                          color: AppColors.surface,
                          size: 17,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  final Color iconColor;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
    this.iconColor = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor, size: 27),
            if (badge != null)
              Positioned(
                right: -4,
                top: -5,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
