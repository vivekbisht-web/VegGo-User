//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_image_view.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_invoice_bottom_sheet.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: Obx(() {
        final order =
            controller.selectedOrder.value ??
            (controller.orders.isNotEmpty ? controller.orders.first : null);
        if (order == null) {
          return const Center(child: Text(AppStrings.cartEmpty));
        }

        return SingleChildScrollView(
          padding: AppSpacing.paddingResponsiveAll(0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.paddingResponsiveAll(0.04),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.03,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        AppSpacing.h4,
                        Text(
                          order.orderDate.toString().split('.')[0],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: AppSpacing.paddingSymmetric(
                        horizontal: AppSpacing.screenWidth * 0.03,
                        vertical: AppSpacing.screenWidth * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.screenWidth * 0.02,
                        ),
                      ),
                      child: Text(
                        order.status.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.responsiveHeight(0.02),

              Container(
                padding: AppSpacing.paddingResponsiveAll(0.04),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.03,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.itemSummary,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.h8,
                    ...order.items.map(
                      (item) => Padding(
                        padding: AppSpacing.paddingResponsiveVertical(0.02),
                        child: Row(
                          children: [
                            CustomImageView(
                              imageUrl: item.imagePath,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                            AppSpacing.responsiveWidth(0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${item.weight} x ${item.quantity}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${AppStrings.currencySymbol}${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.responsiveHeight(0.02),

              Container(
                padding: AppSpacing.paddingResponsiveAll(0.04),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.screenWidth * 0.03,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      context,
                      AppStrings.subtotal,
                      '${AppStrings.currencySymbol}${order.subtotal.toStringAsFixed(2)}',
                    ),
                    AppSpacing.h8,
                    _buildRow(
                      context,
                      AppStrings.deliveryFee,
                      '${AppStrings.currencySymbol}${order.deliveryFee.toStringAsFixed(2)}',
                    ),
                    AppSpacing.h8,
                    _buildRow(
                      context,
                      AppStrings.estimatedTaxes,
                      '${AppStrings.currencySymbol}${order.tax.toStringAsFixed(2)}',
                    ),
                    const Divider(color: AppColors.borderLight, height: 24),
                    _buildRow(
                      context,
                      AppStrings.total,
                      '${AppStrings.currencySymbol}${order.totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              AppSpacing.responsiveHeight(0.03),

              CustomButton(
                text: AppStrings.reorder,
                icon: Icons.refresh,
                isLoading: controller.isReordering.value,
                onPressed: () {
                  if (order.id.isNotEmpty) {
                    controller.reorder(order.id);
                  }
                },
              ),
              AppSpacing.h8,
              CustomButton(
                text: AppStrings.downloadInvoice,
                icon: Icons.file_download_outlined,
                isLoading: controller.isInvoiceLoading.value,
                isOutlined: true,
                onPressed: () async {
                  if (order.id.isNotEmpty) {
                    await controller.fetchOrderInvoice(order.id);
                    final invoice = controller.orderInvoiceData.value;
                    if (invoice != null) {
                      final invoiceUrl = invoice.invoiceUrl;
                      if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
                        Get.snackbar(
                          AppStrings.downloadInvoice,
                          invoiceUrl,
                          backgroundColor: AppColors.primary,
                          colorText: AppColors.surface,
                        );
                      } else {
                        if (!context.mounted) return;
                        OrderInvoiceBottomSheet.show(context, invoice);
                      }
                    } else {
                      Get.snackbar(
                        AppStrings.downloadInvoice,
                        controller.errorMessage.value.isNotEmpty
                            ? controller.errorMessage.value
                            : AppStrings.invoiceUnavailable,
                        backgroundColor: AppColors.error,
                        colorText: AppColors.surface,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title,
    String val, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          val,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isBold ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
