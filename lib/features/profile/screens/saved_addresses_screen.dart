import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';

import 'package:get/get.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';
import 'package:vegon_user/features/profile/screens/add_address_screen.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart'
    as vegon_location;

class SavedAddressesScreen extends StatelessWidget {
  SavedAddressesScreen({super.key});

  final AddressController controller = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: Padding(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.fetchAddresses(),
                child: Obx(() {
                  if (controller.isFetching.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (controller.addresses.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: AppSpacing.screenHeight * 0.5,
                          child: Center(
                            child: Text(
                              AppStrings.noAddressesSaved,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      ...controller.addresses.asMap().entries.map((entry) {
                        int index = entry.key;
                        var address = entry.value;
                        return Padding(
                          padding: AppSpacing.paddingOnly(
                            bottom: AppSpacing.screenWidth * 0.04,
                          ),
                          child: _buildAddressCard(
                            context,
                            index: index,
                            title: address.title,
                            address: address.address,
                            icon: address.icon,
                            isDefault: address.isDefault,
                          ),
                        );
                      }),
                      AppSpacing.h24,
                      Text(
                        AppStrings.addAddressDesc,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            CustomButton(
              text: AppStrings.addNewAddress,
              onPressed: () => Get.to(() => const AddAddressScreen()),
            ),
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required int index,
    required String title,
    required String address,
    required IconData icon,
    bool isDefault = false,
  }) {
    return InkWell(
      onTap: () {
        final addr = controller.addresses[index];
        if (Get.isRegistered<vegon_location.LocationController>()) {
          final locCtrl = Get.find<vegon_location.LocationController>();
          final lat = addr.rawAddressData?.latitude ?? 0.0;
          final lng = addr.rawAddressData?.longitude ?? 0.0;

          locCtrl.setCustomLocation(
            latitude: lat != 0.0 ? lat : (locCtrl.latitude ?? 0.0),
            longitude: lng != 0.0 ? lng : (locCtrl.longitude ?? 0.0),
            locationName: address,
          );
        }
        if (Get.isRegistered<CheckoutController>()) {
          final checkoutCtrl = Get.find<CheckoutController>();
          checkoutCtrl.selectAddress(addr);
        }
        Get.back();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                AppSpacing.w8,
                Text(
                  "title",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isDefault)
                  Container(
                    padding: AppSpacing.paddingHorizontal8.copyWith(
                      top: 4,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.defaultLabel,

                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.h12,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h12,
            Divider(color: AppColors.borderLight.withAlpha(80)),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () {
                        Get.to(
                          () => AddAddressScreen(
                            initialAddress: controller.addresses[index],
                          ),
                        );
                      },
                      icon: Icons.edit_outlined,
                      text: AppStrings.edit,
                      isTextButton: true,
                    ),
                  ),
                  VerticalDivider(color: AppColors.borderLight.withAlpha(80)),
                  Expanded(
                    child: CustomButton(
                      onPressed: () {
                        _confirmDelete(context, index);
                      },
                      icon: Icons.delete_outline,
                      iconColor: AppColors.error,
                      text: AppStrings.delete,
                      textColor: AppColors.error,
                      isTextButton: true,
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

  void _confirmDelete(BuildContext context, int index) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
        ),
        title: Text(
          AppStrings.delete,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          AppStrings.deleteAddressConfirmation,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(index);
            },
            child: Text(
              AppStrings.delete,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
