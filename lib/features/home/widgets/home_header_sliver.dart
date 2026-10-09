import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
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
    final topInset = MediaQuery.paddingOf(context).top;
    final textTheme = Theme.of(context).textTheme;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: AppColors.surface,
        padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showBackButton)
                  _HeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else if (Get.isRegistered<DashboardController>()) {
                        Get.find<DashboardController>().changeTabIndex(0);
                      }
                    },
                  )
                else if (showMenuButton)
                  GestureDetector(
                    onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (showBackButton || showMenuButton) AppSpacing.w8,
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Obx(() {
                          final hasAddress =
                              addressController.addresses.isNotEmpty;
                          final locName =
                              locationController.currentLocationName.value;

                          if (!hasAddress) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius12,
                              ),
                              onTap: () =>
                                  Get.to(() => const AddAddressScreen()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add_location_alt_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    AppSpacing.w6,
                                    Flexible(
                                      child: Text(
                                        AppStrings.addAddressButton,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius12,
                            ),
                            onTap: () =>
                                AddressSelectionBottomSheet.show(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  AppSpacing.w6,
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.deliverTo,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            height: 1.1,
                                          ),
                                        ),
                                        AppSpacing.h2,
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                locName.isNotEmpty
                                                    ? locName
                                                    : addressController
                                                          .addresses
                                                          .first
                                                          .address,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                      height: 1.1,
                                                    ),
                                              ),
                                            ),
                                            AppSpacing.w2,
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 18,
                                              color: AppColors.textPrimary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      // InkWell(
                      //   customBorder: const CircleBorder(),
                      //   onTap: () =>
                      //       locationController.fetchAndSaveUserLocation(
                      //         showFeedback: true,
                      //         saveToApi: true,
                      //       ),
                      //   child: Padding(
                      //     padding: AppSpacing.paddingAll6,
                      //     child: Obx(
                      //       () => locationController.isFetchingLocation.value
                      //           ? const SizedBox(
                      //               width: 18,
                      //               height: 18,
                      //               child: CircularProgressIndicator(
                      //                 color: AppColors.primary,
                      //                 strokeWidth: 2,
                      //               ),
                      //             )
                      //           : const Icon(
                      //               Icons.my_location_rounded,
                      //               color: AppColors.primary,
                      //               size: 18,
                      //             ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Obx(() {
                  final count =
                      Get.find<NotificationController>().unreadCount.value;
                  return _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    badge: count > 0 ? '$count' : null,
                    onTap: () => Get.toNamed(AppRoutes.notifications),
                  );
                }),
                AppSpacing.w4,
                Obx(() {
                  final count = cartController.totalItems;
                  return _HeaderIconButton(
                    icon: Icons.shopping_cart_outlined,
                    badge: count > 0 ? '$count' : null,
                    badgeColor: AppColors.primary,
                    onTap: () => Get.to(() => CartScreen()),
                  );
                }),
                // AppSpacing.w4,
                // _HeaderIconButton(
                //   icon: Icons.account_balance_wallet_outlined,
                //   onTap: () => Get.toNamed(AppRoutes.wallet),
                // ),
              ],
            ),
            AppSpacing.h12,
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 16, right: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.chipBorder.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24,
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
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: AppSpacing.paddingVertical8,
                        hintText: AppStrings.searchVegPlaceholder,
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
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
                    if (searchController.searchQuery.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
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
                      padding: AppSpacing.paddingAll8,
                      child: Icon(
                        Icons.mic_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  final Color badgeColor;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
    this.badgeColor = AppColors.error,
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
          width: 36,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 26),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
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
