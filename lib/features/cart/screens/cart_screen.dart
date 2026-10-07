import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/empty_state_widget.dart';
import 'package:vegon_user/core/widgets/app_dialogs.dart';
import 'package:vegon_user/core/utils/price_formatter.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/models/cart_models.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/cart/widgets/cart_item_card.dart';
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => cartController.loadCart(),
        child: Obx(() {
          if (cartController.cartItems.isEmpty) {
            return _buildEmptyState(context);
          }

          final carts = cartController.carts;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    if (index >= carts.length) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSpacing.screenHeight * 0.015,
                      ),
                      child: _VendorCartGroup(cart: carts[index]),
                    );
                  }, childCount: carts.length),
                ),
              ),
              SliverPadding(
                padding: AppSpacing.paddingSymmetric(
                  horizontal: AppSpacing.screenWidth * 0.04,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    //  const CartPairsWellSection(),
                    AppSpacing.responsiveHeight(0.03),
                    CartOrderSummaryCard(),
                    AppSpacing.responsiveHeight(0.05),
                  ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: AppSpacing.screenHeight * 0.75,
        child: Center(
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
        ),
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    final vendorCount = cartController.cartCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.items,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (vendorCount > 1)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$vendorCount vendors in this bag',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
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

/// One vendor's cart, shown as a collapsible group when the user has more
/// than one vendor cart, or as a plain list when there's only one (so a
/// single-vendor shopper sees no extra chrome at all).
class _VendorCartGroup extends StatelessWidget {
  final CartModel cart;

  const _VendorCartGroup({required this.cart});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Obx(() {
      final liveCart =
          cartController.carts.firstWhereOrNull((c) => c.id == cart.id) ?? cart;
      final showVendorChrome = cartController.hasMultipleCarts;
      final expanded = cartController.isExpanded(liveCart.id);

      return Container(
        decoration: showVendorChrome
            ? BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppSpacing.screenWidth * 0.04,
                ),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.6),
                ),
              )
            : null,
        padding: showVendorChrome
            ? AppSpacing.paddingResponsiveAll(0.03)
            : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showVendorChrome)
              _buildGroupHeader(context, liveCart, expanded),
            if (expanded || !showVendorChrome) ...[
              if (showVendorChrome) AppSpacing.responsiveHeight(0.015),
              ...liveCart.items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.screenHeight * 0.012,
                  ),
                  child: CartItemCard(item: item),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildGroupHeader(
    BuildContext context,
    CartModel liveCart,
    bool expanded,
  ) {
    final CartController cartController = Get.find<CartController>();

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
      onTap: () => cartController.toggleCartExpanded(liveCart.id),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          AppSpacing.responsiveWidth(0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  liveCart.cartLabel.isNotEmpty
                      ? liveCart.cartLabel
                      : AppStrings.items,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${liveCart.items.length} item${liveCart.items.length == 1 ? '' : 's'}'
                  ' • ${PriceFormatter.format(cartController.cartSubtotal(liveCart))}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AppDialogs.showConfirmationDialog(
                  context,
                  title: AppStrings.removeItem,
                  message: 'Remove all items from "${liveCart.cartLabel}"?',
                  confirmText: AppStrings.remove,
                  icon: Icons.delete_outline_rounded,
                  isDestructive: true,
                  onConfirm: () => cartController.removeCartGroup(liveCart.id),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
            ),
          ),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
