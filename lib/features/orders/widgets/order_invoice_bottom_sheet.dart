//
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/order_invoice_response_model.dart';

class OrderInvoiceBottomSheet extends StatelessWidget {
  final OrderInvoiceData invoice;

  const OrderInvoiceBottomSheet({
    super.key,
    required this.invoice,
  });

  static void show(BuildContext context, OrderInvoiceData invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => OrderInvoiceBottomSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: AppSpacing.screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.screenWidth * 0.05),
        ),
      ),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AppSpacing.screenWidth * 0.1,
              height: AppSpacing.screenHeight * 0.005,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.01),
              ),
            ),
          ),
          AppSpacing.responsiveHeight(0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.invoiceDetails,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: AppColors.border),
          AppSpacing.responsiveHeight(0.01),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(context),
                  AppSpacing.responsiveHeight(0.02),
                  if (invoice.items != null && invoice.items!.isNotEmpty) ...[
                    Text(
                      AppStrings.items,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    AppSpacing.responsiveHeight(0.01),
                    ...invoice.items!.map((item) => _buildItemRow(context, item)),
                    AppSpacing.responsiveHeight(0.02),
                  ],
                  _buildSummarySection(context),
                  AppSpacing.responsiveHeight(0.02),
                ],
              ),
            ),
          ),
          AppSpacing.responsiveHeight(0.01),
          CustomButton(
            text: AppStrings.close,
            isOutlined: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.03),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (invoice.orderNumber != null)
            _buildInfoRow(
              context,
              AppStrings.invoiceNumber,
              invoice.orderNumber!,
            ),
          if (invoice.orderDate != null)
            _buildInfoRow(
              context,
              AppStrings.date,
              invoice.orderDate!,
            ),
          if (invoice.customerName != null)
            _buildInfoRow(
              context,
              AppStrings.billedTo,
              '${invoice.customerName!} ${invoice.customerPhone ?? ''}'.trim(),
            ),
          if (invoice.deliveryAddress != null)
            _buildInfoRow(
              context,
              AppStrings.deliveryAddress,
              invoice.deliveryAddress!,
            ),
          if (invoice.paymentMethod != null)
            _buildInfoRow(
              context,
              AppStrings.paymentMethod,
              invoice.paymentMethod!,
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, OrderInvoiceItem item) {
    final qty = item.quantity ?? 1;
    final name = item.productName ?? '';
    final subtotal = (item.subTotal ?? ((item.unitPrice ?? 0.0) * qty));

    return Padding(
      padding: AppSpacing.paddingVertical4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$name x$qty',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          Text(
            '${AppStrings.currencySymbol}${subtotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingResponsiveAll(0.03),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
      ),
      child: Column(
        children: [
          if (invoice.subtotal != null)
            _buildPriceRow(
              context,
              AppStrings.subtotal,
              '${AppStrings.currencySymbol}${invoice.subtotal!.toStringAsFixed(2)}',
            ),
          if (invoice.deliveryFee != null)
            _buildPriceRow(
              context,
              AppStrings.deliveryFee,
              invoice.deliveryFee! > 0
                  ? '${AppStrings.currencySymbol}${invoice.deliveryFee!.toStringAsFixed(2)}'
                  : AppStrings.free,
            ),
          if (invoice.estimatedTax != null)
            _buildPriceRow(
              context,
              AppStrings.estimatedTaxes,
              '${AppStrings.currencySymbol}${invoice.estimatedTax!.toStringAsFixed(2)}',
            ),
          if (invoice.promoDiscount != null && invoice.promoDiscount! > 0)
            _buildPriceRow(
              context,
              AppStrings.discount,
              '-${AppStrings.currencySymbol}${invoice.promoDiscount!.toStringAsFixed(2)}',
            ),
          const Divider(color: AppColors.border),
          _buildPriceRow(
            context,
            AppStrings.total,
            '${AppStrings.currencySymbol}${(invoice.total ?? 0.0).toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: AppSpacing.paddingVertical4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.screenWidth * 0.28,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: AppSpacing.paddingVertical4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isBold ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
