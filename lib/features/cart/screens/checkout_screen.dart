//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';
import 'package:vegon_user/features/cart/widgets/checkout_address_card.dart';
import 'package:vegon_user/features/cart/widgets/checkout_time_card.dart';
import 'package:vegon_user/features/cart/widgets/checkout_payment_card.dart';
import 'package:vegon_user/features/cart/widgets/checkout_summary_card.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final CheckoutController checkoutController = Get.put(CheckoutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingSymmetric(
          horizontal: AppSpacing.screenWidth * 0.04,
          vertical: AppSpacing.screenHeight * 0.02,
        ),
        child: Column(
          children: [
            const CheckoutAddressCard(),
            AppSpacing.responsiveHeight(0.02),

            const CheckoutTimeCard(),
            AppSpacing.responsiveHeight(0.02),

            const CheckoutPaymentCard(),
            AppSpacing.responsiveHeight(0.02),

            const CheckoutSummaryCard(),
            AppSpacing.responsiveHeight(0.04),
          ],
        ),
      ),
    );
  }
}
