import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/dashboard/controllers/notification_controller.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';
import 'package:vegon_user/routes/app_routes.dart';

import 'package:vegon_user/features/home/controllers/location_controller.dart';
import 'package:vegon_user/features/home/controllers/home_search_controller.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';
import 'package:vegon_user/core/widgets/address_selection_bottom_sheet.dart';
import 'package:vegon_user/core/widgets/voice_search_bottom_sheet.dart';
import 'package:vegon_user/features/profile/screens/add_address_screen.dart';

class HomeHeaderSliver extends StatelessWidget {
  final bool showBackButton;
  final bool showMenuButton;
  const HomeHeaderSliver({
    super.key,
    this.showBackButton = false,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HomeHeader(
        showBackButton: showBackButton,
        showMenuButton: showMenuButton,
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  final bool showBackButton;
  final bool showMenuButton;
  const HomeHeader({
    super.key,
    this.showBackButton = false,
    this.showMenuButton = true,
  });

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
    final AddressController addressController =
        Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

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
                if (showBackButton)
                  Material(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radius12),
                    child: InkWell(
                      onTap: () {
                        final canPop = Navigator.canPop(context);
                        if (canPop) {
                          Get.back();
                        } else if (Get.isRegistered<DashboardController>()) {
                          Get.find<DashboardController>().changeTabIndex(0);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radius12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius12,
                          ),
                          border: Border.all(
                            color: AppColors.chipBorder.withValues(alpha: 0.8),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                else if (showMenuButton)
                  _HeaderIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () {
                      Scaffold.maybeOf(context)?.openDrawer();
                    },
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      final count =
                          Get.find<NotificationController>().unreadCount.value;
                      return _HeaderIconButton(
                        icon: Icons.notifications_none_rounded,
                        badge: count > 0 ? '$count' : null,
                        onTap: () => Get.toNamed(AppRoutes.notifications),
                      );
                    }),
                    AppSpacing.w12,
                    Obx(() {
                      final count = cartController.totalItems;
                      return _HeaderIconButton(
                        icon: Icons.shopping_cart_outlined,
                        badge: count > 0 ? '$count' : null,
                        onTap: () => Get.to(() => CartScreen()),
                      );
                    }),
                    AppSpacing.w12,
                    _HeaderIconButton(
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => Get.toNamed(AppRoutes.wallet),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            left: sidePadding,
            top: heroHeight - 52,
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
              elevation: 3,
              shadowColor: AppColors.overlayLight.withValues(alpha: 0.15),
              child: Container(
                height: locationHeight,
                constraints: BoxConstraints(
                  maxWidth: media.width - (sidePadding * 2),
                ),
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Address Selection Button — shows saved address or "Add Address" prompt
                    Obx(() {
                      final hasAddress = addressController.addresses.isNotEmpty;
                      final locName =
                          locationController.currentLocationName.value;

                      if (!hasAddress) {
                        // No DB address: show "Add Address" prompt
                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius12,
                          ),
                          onTap: () => Get.to(() => const AddAddressScreen()),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_location_alt_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                AppSpacing.w6,
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: media.width * 0.38,
                                  ),
                                  child: Text(
                                    AppStrings.addAddressButton,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          height: 1,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Has DB address: show address picker
                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius12,
                        ),
                        onTap: () => AddressSelectionBottomSheet.show(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              AppSpacing.w6,
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.deliverTo,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 9,
                                      height: 1,
                                    ),
                                  ),
                                  AppSpacing.h4,
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: media.width * 0.36,
                                        ),
                                        child: Text(
                                          locName.isNotEmpty
                                              ? locName
                                              : addressController
                                                    .addresses
                                                    .first
                                                    .address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                      AppSpacing.w2,
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Vertical Divider
                    Container(
                      width: 1,
                      height: 22,
                      margin: AppSpacing.paddingHorizontal4,
                      color: AppColors.borderLight,
                    ),

                    // Dedicated Refresh / GPS Fetch Button
                    Material(
                      color: AppColors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radius16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius16,
                        ),
                        onTap: () =>
                            locationController.fetchAndSaveUserLocation(
                              showFeedback: true,
                              saveToApi: true,
                            ),
                        child: Padding(
                          padding: AppSpacing.paddingAll6,
                          child: Obx(
                            () => locationController.isFetchingLocation.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
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
                      return const SizedBox.shrink();
                    }),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        searchController.clearSearch();
                        VoiceSearchBottomSheet.show(
                          context,
                          onResult: (spokenText) {
                            searchController.searchTextController.value =
                                TextEditingValue(
                              text: spokenText,
                              selection: TextSelection.collapsed(
                                offset: spokenText.length,
                              ),
                            );
                            searchController.onSearchQueryChanged(spokenText);
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radius20),
                      child: const Padding(
                        padding: AppSpacing.paddingAll6,
                        child: Icon(
                          Icons.mic_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
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

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.surface, size: 27),
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
      ),
    );
  }
}
