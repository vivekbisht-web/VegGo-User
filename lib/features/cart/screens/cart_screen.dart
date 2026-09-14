//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/empty_state_widget.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/cart/widgets/cart_item_card.dart';
import 'package:vegon_user/features/cart/widgets/cart_pairs_well_section.dart';
import 'package:vegon_user/features/cart/widgets/cart_order_summary_card.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true, showCartButton: false),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: AppStrings.cartEmpty,
              subtitle: AppStrings.cartEmptyDesc,
              buttonText: AppStrings.startShopping,
              onButtonPressed: () {
                if (Get.isRegistered<DashboardController>()) {
                  Get.find<DashboardController>().changeTabIndex(0);
                }
                Get.back();
              },
            ),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: AppSpacing.paddingSymmetric(
                horizontal: AppSpacing.screenWidth * 0.04,
                vertical: AppSpacing.screenHeight * 0.01,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCartHeader(context),
                  AppSpacing.responsiveHeight(0.01),
                ]),
              ),
            ),
            SliverPadding(
              padding: AppSpacing.paddingSymmetric(
                horizontal: AppSpacing.screenWidth * 0.04,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= cartController.cartItems.length) {
                    return const SizedBox.shrink();
                  }
                  final item = cartController.cartItems[index];
                  return CartItemCard(item: item);
                }, childCount: cartController.cartItems.length),
              ),
            ),
            SliverPadding(
              padding: AppSpacing.paddingSymmetric(
                horizontal: AppSpacing.screenWidth * 0.04,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AppSpacing.responsiveHeight(0.015),
                  const CartPairsWellSection(),
                  AppSpacing.responsiveHeight(0.03),
                  CartOrderSummaryCard(),
                  AppSpacing.responsiveHeight(0.05),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.items,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: AppSpacing.paddingSymmetric(
            horizontal: AppSpacing.screenWidth * 0.03,
            vertical: AppSpacing.screenWidth * 0.012,
          ),
          decoration: BoxDecoration(
            color: AppColors.borderLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
          ),
          child: Text(
            '${cartController.totalItems} ${AppStrings.items}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
