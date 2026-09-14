import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';

class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutController =
        Get.find<CheckoutController>();

    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            AppStrings.deliveryAddress,
            Icons.location_on_outlined,
            context,
            trailing: InkWell(
              onTap: () => checkoutController.showChangeAddressDialog(context),
              child: Text(
                AppStrings.change,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          AppSpacing.responsiveHeight(0.02),

          Obx(() {
            final address = checkoutController.selectedAddress.value;
            if (address == null) {
              return Text(
                "No address selected.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.responsiveHeight(0.005),
                Text(
                  address.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            );
          }),
          AppSpacing.responsiveHeight(0.02),

          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
            child: Container(
              height: AppSpacing.screenHeight * 0.16,
              width: double.infinity,
              color: AppColors.borderLight.withValues(alpha: 0.1),
              child: Obx(() {
                  final address = checkoutController.selectedAddress.value;
                  if (address != null) {
                    final lat = address.rawAddressData?.latitude ?? 28.6139;
                    final lng = address.rawAddressData?.longitude ?? 77.2090;
                    final apiKey = ApiEndpoints.googleMapsApiKey;
                    return CustomImageView(
                      imageUrl:
                          'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=400x200&key=$apiKey',
                      fit: BoxFit.cover,
                      width: AppSpacing.screenWidth,
                      height: AppSpacing.screenHeight * 0.16,
                    );
                  }
                  return const SizedBox();
              })
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(
    String title,
    IconData icon,
    BuildContext context, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingResponsiveAll(0.02),
          decoration: const BoxDecoration(
            color: AppColors.mintBadge,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppSpacing.screenWidth * 0.05,
          ),
        ),
        AppSpacing.responsiveWidth(0.03),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing],
      ],
    );
  }
}
