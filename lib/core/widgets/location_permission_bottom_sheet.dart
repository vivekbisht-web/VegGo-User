import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import 'address_selection_bottom_sheet.dart';
import 'custom_button.dart';
import '../../features/home/controllers/location_controller.dart';

class LocationPermissionBottomSheet extends StatelessWidget {
  final bool isServiceDisabled;
  final bool isPermissionDenied;

  const LocationPermissionBottomSheet({
    super.key,
    this.isServiceDisabled = false,
    this.isPermissionDenied = false,
  });

  static Future<void> show(
    BuildContext context, {
    bool isServiceDisabled = false,
    bool isPermissionDenied = false,
  }) async {
    final locCtrl = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());

    if (locCtrl.isLocationPromptVisible.value) return;
    locCtrl.isLocationPromptVisible.value = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => LocationPermissionBottomSheet(
        isServiceDisabled: isServiceDisabled,
        isPermissionDenied: isPermissionDenied,
      ),
    );

    locCtrl.isLocationPromptVisible.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final locCtrl = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius24),
        ),
      ),
      padding: AppSpacing.paddingHorizontal20,
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
          AppSpacing.h8,
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
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
          ),
          AppSpacing.h4,
          Container(
            width: AppSpacing.screenWidth * 0.22,
            height: AppSpacing.screenWidth * 0.22,
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.mintBadge.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: AppSpacing.screenWidth * 0.15,
                height: AppSpacing.screenWidth * 0.15,
                decoration: const BoxDecoration(
                  color: AppColors.mintIcon,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isServiceDisabled
                      ? Icons.location_off_rounded
                      : Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: AppSpacing.screenWidth * 0.08,
                ),
              ),
            ),
          ),
          AppSpacing.h16,
          Text(
            isServiceDisabled
                ? AppStrings.deviceLocationOff
                : AppStrings.enableLocationTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h8,
          Text(
            AppStrings.enableLocationSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          AppSpacing.h20,
          Container(
            padding: AppSpacing.paddingAll16,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _buildBenefitRow(
                  context,
                  icon: Icons.storefront_rounded,
                  text: AppStrings.locationBenefit1,
                ),
                AppSpacing.h12,
                _buildBenefitRow(
                  context,
                  icon: Icons.bolt_rounded,
                  text: AppStrings.locationBenefit2,
                ),
              ],
            ),
          ),
          AppSpacing.h20,
          Obx(() {
            final isFetching = locCtrl.isFetchingLocation.value;
            return CustomButton(
              text: isServiceDisabled
                  ? AppStrings.enableDeviceLocationButton
                  : AppStrings.grantLocationPermissionButton,
              icon: Icons.near_me_rounded,
              isLoading: isFetching,
              onPressed: () async {
                final success = await locCtrl.handleLocationPromptAction();
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            );
          }),
          AppSpacing.h8,
          CustomButton(
            text: AppStrings.selectLocationManually,
            isTextButton: true,
            textColor: AppColors.textSecondary,
            onPressed: () {
              Navigator.of(context).pop();
              AddressSelectionBottomSheet.show(context);
            },
          ),
          AppSpacing.h12,
          const SafeArea(top: false, child: AppSpacing.h4),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.paddingAll4,
          decoration: const BoxDecoration(
            color: AppColors.mintBadge,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: AppSpacing.radius16,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
