import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/orders_controller.dart';
import '../models/order_track_response_model.dart';
import 'order_tracking_animated_stepper.dart';

class OrderTrackingStatusCard extends StatelessWidget {
  const OrderTrackingStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Obx(() {
      final trackData = ordersController.orderTrackingData.value;

      if (ordersController.isTrackingLoading.value && trackData == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      if (trackData == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              AppStrings.noTrackingData,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      final timeline = trackData.statusTimeline ?? [];
      final isDelivered = (trackData.status ?? '').toUpperCase() == 'DELIVERED';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Status header ----------
          Container(
            padding: AppSpacing.paddingResponsiveAll(0.05),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppSpacing.screenWidth * 0.04,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusLabel(trackData.status),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppSpacing.h4,
                          if (trackData.orderNumber != null)
                            Text(
                              trackData.orderNumber!,
                              style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    if (trackData.estimatedDeliveryWindow != null &&
                        !isDelivered)
                      Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: AppSpacing.screenWidth * 0.03,
                          vertical: AppSpacing.screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.screenWidth * 0.05,
                          ),
                        ),
                        child: Text(
                          trackData.estimatedDeliveryWindow!,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.responsiveHeight(0.04),
                if (timeline.isNotEmpty)
                  OrderTrackingAnimatedStepper(timeline: timeline),
              ],
            ),
          ),

          AppSpacing.responsiveHeight(0.02),

          // ---------- Drop OTP ----------
          if (trackData.dropOtp != null && !isDelivered)
            _buildOtpCard(context, trackData.dropOtp!),

          // ---------- Delivery agent ----------
          if (trackData.deliveryAgentName != null)
            _buildDeliveryAgentCard(context, trackData),

          // ---------- Shop info ----------
          if (trackData.shopName != null)
            _buildInfoTile(
              context,
              icon: Icons.storefront_outlined,
              title: trackData.shopName!,
              subtitle: trackData.shopBusinessPhone,
              onCallTap: trackData.shopBusinessPhone != null
                  ? () => _launchCall(trackData.shopBusinessPhone!)
                  : null,
            ),

          // ---------- Delivery address ----------
          if (trackData.deliveryAddress != null)
            _buildInfoTile(
              context,
              icon: Icons.location_on_outlined,
              title: AppStrings.deliveryAddress,
              subtitle: trackData.deliveryAddress,
            ),

          // ---------- Items ----------
          if (trackData.items != null && trackData.items!.isNotEmpty)
            _buildItemsCard(context, trackData),
        ],
      );
    });
  }

  // ---------------- Helpers ----------------

  String _statusLabel(String? status) {
    switch (status) {
      case 'PLACED':
        return AppStrings.orderPlaced;
      case 'PREPARED':
        return AppStrings.orderPrepared;
      case 'OUT_FOR_DELIVERY':
        return AppStrings.outForDeliveryStatus;
      case 'DELIVERED':
        return AppStrings.delivered;
      default:
        return status ?? AppStrings.trackingOrder;
    }
  }

  Widget _buildOtpCard(BuildContext context, String otp) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.screenWidth * 0.03),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.otpPrefix,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            otp,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAgentCard(
    BuildContext context,
    OrderTrackData trackData,
  ) {
    return _buildInfoTile(
      context,
      icon: Icons.delivery_dining_outlined,
      title: trackData.deliveryAgentName ?? 'Delivery Agent',
      subtitle: trackData.deliveryAgentPhone,
      onCallTap: trackData.deliveryAgentPhone != null
          ? () => _launchCall(trackData.deliveryAgentPhone!)
          : null,
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onCallTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.screenWidth * 0.03),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.screenWidth * 0.025),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onCallTap != null)
            IconButton(
              onPressed: onCallTap,
              icon: const Icon(Icons.call_outlined),
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderTrackData trackData) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.screenWidth * 0.03),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderItems,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h8,
          ...trackData.items!.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.screenWidth * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName ?? ''} x${item.quantity ?? 0}'
                      '${item.unit != null ? ' (${item.unit})' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${AppStrings.currencySymbol}${(item.subTotal ?? 0).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 20,
            color: AppColors.borderLight.withValues(alpha: 0.8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${AppStrings.currencySymbol}${(trackData.total ?? 0).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    // Requires the `url_launcher` package in pubspec.yaml.
    // final uri = Uri(scheme: 'tel', path: phone);
    // if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
