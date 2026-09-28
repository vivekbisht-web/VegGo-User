import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../../features/home/controllers/location_controller.dart';
import '../../features/profile/controllers/address_controller.dart';
import '../../features/profile/screens/add_address_screen.dart';
import '../../features/cart/controllers/checkout_controller.dart';

class AddressSelectionBottomSheet extends StatelessWidget {
  const AddressSelectionBottomSheet({super.key});

  static void show(BuildContext context) {
    final addressController = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());
    addressController.fetchAddresses();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => const AddressSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());
    final addressController = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

    return Container(
      constraints: BoxConstraints(maxHeight: AppSpacing.screenHeight * 0.75),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpacing.h10,
          Container(
            width: AppSpacing.radius40,
            height: AppSpacing.radius4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSpacing.radius2),
            ),
          ),
          AppSpacing.h12,
          Padding(
            padding: AppSpacing.paddingHorizontal16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.selectDeliveryLocation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(AppSpacing.radius20),
                  child: const Padding(
                    padding: AppSpacing.paddingAll4,
                    child: Icon(
                      Icons.close_rounded,
                      size: AppSpacing.radius20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h12,
          const Divider(height: 1, color: AppColors.borderLight),
          Flexible(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingAll16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGpsOption(context, locationController),
                  AppSpacing.h12,
                  _buildAddNewAddressOption(context),
                  AppSpacing.h16,
                  Text(
                    AppStrings.savedAddressesTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.h8,
                  _buildSavedAddressesList(
                    context,
                    addressController,
                    locationController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsOption(
    BuildContext context,
    LocationController locationController,
  ) {
    return InkWell(
      onTap: () async {
        final nav = Navigator.of(context);
        await locationController.fetchAndSaveUserLocation(showFeedback: true);
        if (nav.mounted && nav.canPop()) {
          nav.pop();
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        padding: AppSpacing.paddingAll12,
        decoration: BoxDecoration(
          color: AppColors.mintLight,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(color: AppColors.mintBadge),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Obx(
                () => locationController.isFetchingLocation.value
                    ? const SizedBox(
                        width: AppSpacing.radius16,
                        height: AppSpacing.radius16,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSpacing.radius2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.primary,
                        size: AppSpacing.radius20,
                      ),
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.useCurrentLocation,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.h2,
                  Text(
                    AppStrings.usingGpsSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: AppSpacing.radius20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddressOption(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        Get.to(() => const AddAddressScreen());
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        padding: AppSpacing.paddingAll12,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.paddingAll8,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_location_alt_outlined,
                color: AppColors.primary,
                size: AppSpacing.radius20,
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Text(
                AppStrings.addNewAddress,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: AppSpacing.radius20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedAddressesList(
    BuildContext context,
    AddressController addressController,
    LocationController locationController,
  ) {
    return Obx(() {
      if (addressController.isFetching.value) {
        return const Center(
          child: Padding(
            padding: AppSpacing.paddingAll16,
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (addressController.addresses.isEmpty) {
        return Padding(
          padding: AppSpacing.paddingAll16,
          child: Center(
            child: Text(
              AppStrings.noAddressesSaved,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        );
      }

      final activeLocation = locationController.currentLocationName.value;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: addressController.addresses.length,
        separatorBuilder: (_, index) => AppSpacing.h8,
        itemBuilder: (context, index) {
          final address = addressController.addresses[index];
          final isSelected =
              activeLocation.isNotEmpty &&
              (activeLocation.contains(address.title) ||
                  activeLocation.contains(address.address));

          return InkWell(
            onTap: () {
              final lat = address.rawAddressData?.latitude ?? 0.0;
              final lng = address.rawAddressData?.longitude ?? 0.0;

              locationController.setCustomLocation(
                latitude: lat != 0.0
                    ? lat
                    : (locationController.latitude ?? 0.0),
                longitude: lng != 0.0
                    ? lng
                    : (locationController.longitude ?? 0.0),
                locationName: address.address,
              );

              if (Get.isRegistered<CheckoutController>()) {
                Get.find<CheckoutController>().selectAddress(address);
              }

              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              Get.snackbar(
                AppStrings.deliveryLocationUpdated,
                address.title,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: AppColors.surface,
                duration: const Duration(seconds: 2),
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            child: Container(
              padding: AppSpacing.paddingAll12,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mintLight : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    address.icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: AppSpacing.radius20,
                  ),
                  AppSpacing.w10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            if (address.isDefault) ...[
                              AppSpacing.w6,
                              Container(
                                padding: AppSpacing.paddingHorizontal6,
                                decoration: BoxDecoration(
                                  color: AppColors.mintBadge,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radius4,
                                  ),
                                ),
                                child: Text(
                                  AppStrings.defaultLabel,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        AppSpacing.h4,
                        Text(
                          address.address,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: AppSpacing.radius20,
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
