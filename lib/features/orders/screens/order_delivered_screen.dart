//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import 'package:vegon_user/features/dashboard/screens/dashboard_screen.dart';
import 'package:vegon_user/features/orders/controllers/orders_controller.dart';

class OrderDeliveredScreen extends StatefulWidget {
  const OrderDeliveredScreen({super.key});

  @override
  State<OrderDeliveredScreen> createState() => _OrderDeliveredScreenState();
}

class _OrderDeliveredScreenState extends State<OrderDeliveredScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    final orderId = ordersController.selectedOrder.value?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingAll24,
              decoration: const BoxDecoration(
                color: AppColors.successBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: AppSpacing.screenWidth * 0.16,
              ),
            ),
            AppSpacing.h24,
            Text(
              AppStrings.delivered,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            AppSpacing.h8,
            Text(
              AppStrings.orderSuccessSub1,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.h32,

            Container(
              padding: AppSpacing.paddingAll24,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius16),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    AppStrings.rateYourDelivery,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.h16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = starIndex;
                          });
                        },
                        child: Padding(
                          padding: AppSpacing.paddingHorizontal4,
                          child: Icon(
                            starIndex <= _rating ? Icons.star : Icons.star_border,
                            color: AppColors.warning,
                            size: AppSpacing.screenWidth * 0.1,
                          ),
                        ),
                      );
                    }),
                  ),
                  AppSpacing.h24,
                  CustomTextField(
                    controller: _commentController,
                    hintText: AppStrings.rateYourDeliveryDesc,
                    maxLines: 3,
                  ),
                  AppSpacing.h16,
                  Obx(() {
                    return CustomButton(
                      text: _hasSubmitted ? AppStrings.success : AppStrings.submitFeedback,
                      isLoading: ordersController.isRating.value,
                      onPressed: (_hasSubmitted || orderId.isEmpty)
                          ? () {}
                          : () async {
                              final ok = await ordersController.rateOrder(
                                orderId,
                                _rating,
                                _commentController.text.trim(),
                              );
                              if (ok) {
                                setState(() {
                                  _hasSubmitted = true;
                                });
                              }
                            },
                    );
                  }),
                ],
              ),
            ),
            AppSpacing.h32,
            _buildOrderSummaryDropdown(context, ordersController),
            AppSpacing.h32,
            CustomButton(
              text: AppStrings.backToHome,
              isOutlined: true,
              onPressed: () {
                Get.offAll(() => DashboardScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryDropdown(
    BuildContext context,
    OrdersController ordersController,
  ) {
    return Obx(() {
      final order = ordersController.selectedOrder.value;
      final items = order?.items ?? [];

      return Container(
        padding: AppSpacing.paddingSymmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius8),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.3),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              AppStrings.orderSummary,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            children: [
              AppSpacing.h8,
              if (items.isEmpty)
                Padding(
                  padding: AppSpacing.paddingVertical8,
                  child: Text(
                    order != null
                        ? 'Total: ${AppStrings.rupeeSymbol}${order.totalAmount.toStringAsFixed(2)}'
                        : 'No items listed',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...items.map((item) {
                  return Padding(
                    padding: AppSpacing.paddingVertical4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.title} x${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          '${AppStrings.rupeeSymbol}${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
              AppSpacing.h16,
            ],
          ),
        ),
      );
    });
  }
}
