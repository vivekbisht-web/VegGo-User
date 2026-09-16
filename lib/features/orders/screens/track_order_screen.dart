//
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_live_tracking_map.dart';
import '../widgets/order_tracking_status_card.dart';
import 'order_details_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  final String? orderId;

  const TrackOrderScreen({super.key, this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  void _initTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLatest();
      // Periodically refresh tracking info and driver location every 10 seconds
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _fetchLatest();
      });
    });
  }

  void _fetchLatest() {
    if (Get.isRegistered<OrdersController>()) {
      final ordersController = Get.find<OrdersController>();
      final id = widget.orderId ?? ordersController.selectedOrder.value?.id;
      if (id != null && id.isNotEmpty) {
        ordersController.fetchOrderTrack(id);
      }
    }
  }

  Future<void> _onRefresh() async {
    _fetchLatest();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.paddingResponsiveAll(0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Live Tracking Map with Polyline and Delivery Partner
              Obx(() {
                final trackData = ordersController.orderTrackingData.value;
                return OrderLiveTrackingMap(
                  trackData: trackData,
                );
              }),
              AppSpacing.responsiveHeight(0.02),

              // Order Status Stepper & Details
              const OrderTrackingStatusCard(),
              AppSpacing.responsiveHeight(0.02),

              CustomButton(
                text: AppStrings.viewOrderDetails,
                onPressed: () => Get.to(() => const OrderDetailsScreen()),
              ),
              AppSpacing.responsiveHeight(0.02),

              Obx(() {
                final status = ordersController
                    .orderTrackingData.value?.status
                    ?.toUpperCase();
                final isDelivered = status == 'DELIVERED';
                final isCancelled = status == 'CANCELLED';
                if (isDelivered || isCancelled) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    CustomButton(
                      text: AppStrings.cancelOrder,
                      isOutlined: true,
                      textColor: AppColors.error,
                      onPressed: () {
                        final id =
                            widget.orderId ??
                            ordersController.selectedOrder.value?.id;
                        if (id != null) {
                          ordersController.cancelOrder(id);
                        }
                        Get.back();
                      },
                    ),
                    AppSpacing.responsiveHeight(0.02),
                  ],
                );
              }),
              AppSpacing.responsiveHeight(0.02),
            ],
          ),
        ),
      ),
    );
  }
}
