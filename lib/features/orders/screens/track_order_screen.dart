//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_tracking_status_card.dart';
import '../widgets/order_driver_card.dart';
import 'order_details_screen.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.04),
        child: Column(
          children: [
            const OrderTrackingStatusCard(),
            AppSpacing.responsiveHeight(0.02),
            //   const OrderDriverCard(),
            AppSpacing.responsiveHeight(0.02),

            CustomButton(
              text: AppStrings.viewOrderDetails,
              onPressed: () => Get.to(() => const OrderDetailsScreen()),
            ),
            AppSpacing.responsiveHeight(0.02),

            CustomButton(
              text: AppStrings.cancelOrder,
              isOutlined: true,
              textColor: AppColors.error,
              onPressed: () {
                final id = ordersController.selectedOrder.value?.id;
                if (id != null) {
                  ordersController.cancelOrder(id);
                }
                Get.back();
              },
            ),
            AppSpacing.responsiveHeight(0.04),
          ],
        ),
      ),
    );
  }
}
