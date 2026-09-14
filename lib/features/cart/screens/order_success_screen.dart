//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            Get.offAllNamed('/dashboard');
            Get.find<DashboardController>().changeTabIndex(0);
          },
        ),
        title: Text(
          AppStrings.veggoFresh,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingSymmetric(
          horizontal: AppSpacing.screenWidth * 0.04,
          vertical: AppSpacing.screenHeight * 0.02,
        ),
        child: Column(
          children: [
            _buildSuccessCard(context),
            AppSpacing.responsiveHeight(0.02),

            _buildDeliveryCard(context),
            AppSpacing.responsiveHeight(0.02),

            _buildOrderDetailsCard(context),
            AppSpacing.responsiveHeight(0.02),

            _buildFarmersBanner(context),
            AppSpacing.responsiveHeight(0.04),

            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.06),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.06),
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingResponsiveAll(0.04),
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: AppColors.primary,
              size: AppSpacing.screenWidth * 0.08,
            ),
          ),
          AppSpacing.responsiveHeight(0.02),
          Text(
            AppStrings.orderSuccess,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.responsiveHeight(0.01),
          Text(
            AppStrings.orderSuccessSub1,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            AppStrings.orderSuccessSub2,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.responsiveHeight(0.03),
          CustomButton(
            text: AppStrings.trackMyOrder,
            icon: Icons.local_shipping_outlined,
            onPressed: () {
              Get.offAllNamed('/dashboard');
              Get.find<DashboardController>().changeTabIndex(2);
            },
          ),
          AppSpacing.responsiveHeight(0.015),
          CustomButton(
            text: AppStrings.continueShopping,
            isOutlined: true,
            onPressed: () {
              Get.offAllNamed('/dashboard');
              Get.find<DashboardController>().changeTabIndex(0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context) {
    final checkoutCtrl = Get.isRegistered<CheckoutController>()
        ? Get.find<CheckoutController>()
        : null;
    final addressText = checkoutCtrl?.selectedAddress.value?.address ??
        'Delivering to your selected address';

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingResponsiveAll(0.02),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.textPrimary,
                  size: AppSpacing.screenWidth * 0.05,
                ),
              ),
              AppSpacing.responsiveWidth(0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.estimatedDeliveryCaps,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'In 15-20 mins',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.responsiveHeight(0.02),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: AppSpacing.screenWidth * 0.05,
              ),
              AppSpacing.responsiveWidth(0.03),
              Expanded(
                child: Text(
                  addressText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          AppSpacing.responsiveHeight(0.01),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context) {
    final checkoutCtrl = Get.isRegistered<CheckoutController>()
        ? Get.find<CheckoutController>()
        : null;
    final placedData = checkoutCtrl?.placedOrderResult.value?.data;
    final order = placedData?.orders?.isNotEmpty == true
        ? placedData!.orders!.first
        : null;

    final orderNumber = order?.orderNumber ??
        placedData?.paymentHold?.razorpayOrderId ??
        'Confirmed';
    final totalAmount = order?.totalAmount ??
        placedData?.paymentHold?.totalAmount ??
        0.0;
    final deliveryFee = order?.deliveryFee ?? 0.0;
    final items = order?.items ?? [];

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.05),
      decoration: BoxDecoration(
        color: AppColors.goldBackground,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderDetailsCaps,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          AppSpacing.responsiveHeight(0.005),
          Text(
            'Order #$orderNumber',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.responsiveHeight(0.02),
          if (items.isNotEmpty)
            ...items.map((it) {
              return Padding(
                padding: AppSpacing.paddingVertical4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${it.productName ?? it.productTitle ?? ''} x${it.quantity ?? 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${AppStrings.currencySymbol}${(it.price ?? 0.0).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.orderSuccess,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  '${AppStrings.currencySymbol}${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          AppSpacing.responsiveHeight(0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.deliveryFee,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                deliveryFee > 0
                    ? '${AppStrings.currencySymbol}${deliveryFee.toStringAsFixed(2)}'
                    : AppStrings.free,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.responsiveHeight(0.02),
          Container(
            height: 1,
            color: AppColors.borderLight.withValues(alpha: 0.3),
          ),
          AppSpacing.responsiveHeight(0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalPaid,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${AppStrings.currencySymbol}${totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmersBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      child: Container(
        height: AppSpacing.screenHeight * 0.15,
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Stack(
          children: [
            CustomImageView(
              imageUrl: AppImages.orderSuccessBg,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(color: AppColors.overlayDark),
            Padding(
              padding: AppSpacing.paddingResponsiveAll(0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.supportingLocalFarmers,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                  AppSpacing.responsiveHeight(0.005),
                  Text(
                    AppStrings.supportingLocalFarmersDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.footerStandard,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.responsiveHeight(0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              AppStrings.returnPolicy,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppStrings.contactUs,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppStrings.termsOfService,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
