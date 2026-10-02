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
    final ctrl = Get.find<CheckoutController>();

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
          Obx(() => _buildDeliveryToggle(context, ctrl)),
          Obx(() {
            if (ctrl.isInstantDelivery.value) return const SizedBox.shrink();
            return _buildScheduleSection(context, ctrl);
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryToggle(BuildContext context, CheckoutController ctrl) {
    return Row(
      children: [
        Expanded(
          child: _DeliveryOption(
            icon: Icons.bolt_rounded,
            title: AppStrings.deliverNow,
            subtitle: AppStrings.deliverNowSubtitle,
            isSelected: ctrl.isInstantDelivery.value,
            onTap: () => ctrl.isInstantDelivery.value = true,
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: _DeliveryOption(
            icon: Icons.calendar_today_outlined,
            title: AppStrings.scheduleForLater,
            subtitle: AppStrings.scheduleForLaterSubtitle,
            isSelected: !ctrl.isInstantDelivery.value,
            onTap: () => ctrl.isInstantDelivery.value = false,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context, CheckoutController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.responsiveHeight(0.02),
        if (ctrl.isLoadingSlots.value)
          const Center(child: CircularProgressIndicator())
        else if (ctrl.deliveryDates.isEmpty)
          Text(
            AppStrings.noDeliverySlots,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          )
        else ...[
          SizedBox(
            height: AppSpacing.screenHeight * 0.085,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ctrl.deliveryDates.length,
              separatorBuilder: (_, _) => AppSpacing.responsiveWidth(0.03),
              itemBuilder: (context, index) {
                final dateItem = ctrl.deliveryDates[index];
                return Obx(() {
                  final isSelected = ctrl.selectedDateIndex.value == index;
                  return _DateChip(
                    label: dateItem['label']!,
                    date: dateItem['date']!,
                    isSelected: isSelected,
                    onTap: () => ctrl.selectedDateIndex.value = index,
                  );
                });
              },
            ),
          ),
          if (ctrl.timeSlots.isNotEmpty) ...[
            AppSpacing.responsiveHeight(0.02),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.screenWidth * 0.03,
                mainAxisSpacing: AppSpacing.screenWidth * 0.03,
                childAspectRatio: 2.8,
              ),
              itemCount: ctrl.timeSlots.length,
              itemBuilder: (context, index) {
                final slot = ctrl.timeSlots[index];
                return Obx(() {
                  final isSelected = ctrl.selectedTimeIndex.value == index;
                  return _TimeSlotChip(
                    slot: slot,
                    isSelected: isSelected,
                    onTap: () => ctrl.selectedTimeIndex.value = index,
                  );
                });
              },
            ),
          ],
        ],
      ],
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

class _DeliveryOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingAll12,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            AppSpacing.h6,
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            AppSpacing.h2,
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
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
          borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            AppSpacing.h4,
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.02),
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
          borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.02),
        ),
        child: Text(
          slot,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
