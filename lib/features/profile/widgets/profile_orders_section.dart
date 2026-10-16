//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/orders/controllers/orders_controller.dart';
import 'package:vegon_user/features/orders/screens/my_orders_screen.dart';

class ProfileOrdersSection extends StatelessWidget {
  const ProfileOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.myOrders,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const MyOrdersScreen(initialTabIndex: 0)),
              child: Row(
                children: [
                  Text(
                    AppStrings.viewAllOrders,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.w2,
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: AppSpacing.screenWidth * 0.045,
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.h12,

        Obx(() {
          final total = ordersController.totalOrdersCount.value;
          final allCount = '${total > 0 ? total : ordersController.orders.length}';
          final inProgressCount = '${ordersController.activeOrders.length}';
          final deliveredCount = '${ordersController.deliveredOrders.length}';

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildOrderStatusChip(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: AppStrings.allOrders,
                  count: allCount,
                  onTap: () => Get.to(() => const MyOrdersScreen(initialTabIndex: 0)),
                ),
                AppSpacing.w10,
                _buildOrderStatusChip(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: AppStrings.inProgress,
                  count: inProgressCount,
                  onTap: () => Get.to(() => const MyOrdersScreen(initialTabIndex: 1)),
                ),
                AppSpacing.w10,
                _buildOrderStatusChip(
                  context,
                  icon: Icons.check_circle_outline,
                  title: AppStrings.delivered,
                  count: deliveredCount,
                  onTap: () => Get.to(() => const MyOrdersScreen(initialTabIndex: 2)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOrderStatusChip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.screenWidth * 0.26,
        padding: AppSpacing.paddingSymmetric(
          horizontal: AppSpacing.screenWidth * 0.02,
          vertical: AppSpacing.screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
          border: Border.all(color: AppColors.borderLight.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayLight.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: AppSpacing.paddingAll4,
              decoration: const BoxDecoration(
                color: AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.screenWidth * 0.05,
              ),
            ),
            AppSpacing.h6,
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.h2,
            Text(
              count,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
