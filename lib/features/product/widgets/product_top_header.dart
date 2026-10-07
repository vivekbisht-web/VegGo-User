import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/core/widgets/address_selection_bottom_sheet.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';
import 'package:vegon_user/features/dashboard/screens/notification_screen.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';
import 'package:vegon_user/features/profile/screens/add_address_screen.dart';

class ProductTopHeader extends StatelessWidget {
  const ProductTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final LocationController locationController =
        Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());
    final AddressController addressController =
        Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: AppSpacing.paddingFromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(AppSpacing.radius20),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.chipBorder, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImageView(
                    imageUrl: AppImages.logo,
                    isAsset: true,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  AppSpacing.w6,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: AppStrings.veg,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            TextSpan(
                              text: AppStrings.go,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.secondary,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppStrings.freshFastTrustedTagline,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 6.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(AppSpacing.radius20),
                    child: Padding(
                      padding: AppSpacing.paddingAll8,
                      child: Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AppSpacing.w8,

                  InkWell(
                    onTap: () => Get.to(() => const NotificationScreen()),
                    borderRadius: BorderRadius.circular(AppSpacing.radius20),
                    child: const Padding(
                      padding: AppSpacing.paddingAll8,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AppSpacing.w8,

                  InkWell(
                    onTap: () => Get.to(() => CartScreen()),
                    borderRadius: BorderRadius.circular(AppSpacing.radius20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: AppSpacing.paddingAll8,
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Obx(() {
                          final count = cartController.totalItems;
                          if (count <= 0) return const SizedBox.shrink();
                          return Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.surface,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Obx(() {
          final hasAddress = addressController.addresses.isNotEmpty;
          if (!hasAddress) {
            return Padding(
              padding: AppSpacing.paddingHorizontal16,
              child: InkWell(
                onTap: () => Get.to(() => const AddAddressScreen()),
                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                child: Container(
                  padding: AppSpacing.paddingSymmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radius12),
                    border: Border.all(color: AppColors.chipBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_location_alt_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      AppSpacing.w8,
                      Expanded(
                        child: Text(
                          AppStrings.addAddressButton,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final locName = locationController.currentLocationName.value;
          final matchedAddr = addressController.addresses.firstWhereOrNull(
            (a) =>
                locName.isNotEmpty &&
                (a.address.toLowerCase().contains(locName.toLowerCase()) ||
                    locName.toLowerCase().contains(a.address.toLowerCase()) ||
                    a.title.toLowerCase() == locName.toLowerCase()),
          );
          final displayAddress = matchedAddr != null
              ? (locName.isNotEmpty ? locName : matchedAddr.address)
              : (addressController.addresses.firstWhereOrNull((a) => a.isDefault)?.address ??
                  addressController.addresses.first.address);

          return Padding(
            padding: AppSpacing.paddingHorizontal16,
            child: InkWell(
              onTap: () => AddressSelectionBottomSheet.show(context),
              borderRadius: BorderRadius.circular(AppSpacing.radius12),
              child: Container(
                padding: AppSpacing.paddingSymmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  border: Border.all(color: AppColors.chipBorder, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    AppSpacing.w8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.deliverTo,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                          AppSpacing.h2,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  displayAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              AppSpacing.w2,
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppStrings.change,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
