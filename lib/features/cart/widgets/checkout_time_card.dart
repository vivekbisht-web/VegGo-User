import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';

class CheckoutTimeCard extends StatelessWidget {
  const CheckoutTimeCard({super.key});

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
            AppStrings.deliveryTime,
            Icons.access_time_outlined,
            context,
          ),
          AppSpacing.responsiveHeight(0.02),

          Obx(() {
            if (checkoutController.isLoadingSlots.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (checkoutController.deliveryDates.isEmpty) {
              return Text(
                AppStrings.noDeliverySlots,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: AppSpacing.screenHeight * 0.085,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: checkoutController.deliveryDates.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.responsiveWidth(0.03),
                    itemBuilder: (context, index) {
                      final dateItem = checkoutController.deliveryDates[index];
                      return Obx(() {
                        final isSelected =
                            checkoutController.selectedDateIndex.value == index;
                        return InkWell(
                          onTap: () =>
                              checkoutController.selectedDateIndex.value = index,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.screenWidth * 0.03,
                          ),
                          child: Container(
                            width: AppSpacing.screenWidth * 0.28,
                            padding: AppSpacing.paddingAll8,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : AppColors.surface,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderLight.withValues(alpha: 0.5),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.screenWidth * 0.03,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dateItem['label']!,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                ),
                                AppSpacing.h4,
                                Text(
                                  dateItem['date']!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                AppSpacing.responsiveHeight(0.02),

                if (checkoutController.timeSlots.isNotEmpty)
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.screenWidth * 0.03,
                      mainAxisSpacing: AppSpacing.screenWidth * 0.03,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: checkoutController.timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = checkoutController.timeSlots[index];
                      return Obx(() {
                        final isSelected =
                            checkoutController.selectedTimeIndex.value == index;
                        return InkWell(
                          onTap: () =>
                              checkoutController.selectedTimeIndex.value = index,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.screenWidth * 0.02,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : AppColors.surface,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderLight.withValues(alpha: 0.5),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.screenWidth * 0.02,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon, BuildContext context) {
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
      ],
    );
  }
}
