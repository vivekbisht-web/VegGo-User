//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/dashboard/screens/notification_screen.dart';
import 'package:vegon_user/core/widgets/cart_action_button.dart';
import 'package:vegon_user/features/profile/screens/account_settings_screen.dart';
import 'package:vegon_user/core/widgets/brand_logo_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;
  final bool showCenterLogo;
  final bool showActions;
  final bool showCartButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;

  const CustomAppBar({
    super.key,
    this.showBackButton = true,
    this.title,
    this.showCenterLogo = true,
    this.showActions = true,
    this.showCartButton = true,
    this.onBackTap,
    this.onSearchTap,
    this.onSettingsTap,
    this.onNotificationTap,
    this.onCartTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 68.0,
          padding: AppSpacing.paddingHorizontal16,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.chipBorder.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
          ),
          child: showBackButton
              ? _buildWithBackButton(context, cartController)
              : _buildWithoutBackButton(context, cartController),
        ),
      ),
    );
  }

  Widget _buildWithBackButton(
    BuildContext context,
    CartController cartController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSquircleBackButton(context),

        if (title != null && !showCenterLogo)
          Expanded(
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          const BrandLogoWidget(isCenterAligned: true),

        if (showActions)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (onSearchTap != null) {
                    onSearchTap!();
                  } else if (Get.isRegistered<DashboardController>()) {
                    Get.find<DashboardController>().changeTabIndex(1);
                  }
                },
                borderRadius: BorderRadius.circular(AppSpacing.radius20),
                child: const Padding(
                  padding: AppSpacing.paddingAll4,
                  child: Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppSpacing.w8,

              _buildNotificationButton(context),

              if (showCartButton) ...[
                AppSpacing.w8,
                CartActionButton(
                  style: CartActionButtonStyle.simple,
                  onCartTap: onCartTap,
                  cartController: cartController,
                ),
              ],
            ],
          )
        else
          const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildWithoutBackButton(
    BuildContext context,
    CartController cartController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BrandLogoWidget(isCenterAligned: false),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationButton(context),
            AppSpacing.w8,

            InkWell(
              onTap: () {
                if (onSettingsTap != null) {
                  onSettingsTap!();
                } else {
                  Get.to(() => const AccountSettingsScreen());
                }
              },
              borderRadius: BorderRadius.circular(AppSpacing.radius20),
              child: const Padding(
                padding: AppSpacing.paddingAll4,
                child: Icon(
                  Icons.settings_outlined,
                  size: 23,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (showCartButton) ...[
              AppSpacing.w8,
              CartActionButton(
                style: CartActionButtonStyle.dynamicPill,
                onCartTap: onCartTap,
                cartController: cartController,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSquircleBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onBackTap != null) {
          onBackTap!();
        } else {
          final canPop = Navigator.canPop(context);
          if (canPop) {
            Get.back();
          } else if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().changeTabIndex(0);
          }
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(
            color: AppColors.chipBorder.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onNotificationTap != null) {
          onNotificationTap!();
        } else {
          Get.to(() => const NotificationScreen());
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radius20),
      child: const Padding(
        padding: AppSpacing.paddingAll4,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
