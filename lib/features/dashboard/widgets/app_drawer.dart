import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/auth/controllers/auth_controller.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';
import 'package:vegon_user/features/cart/screens/coupons_screen.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/dashboard/screens/notification_screen.dart';
import 'package:vegon_user/features/dashboard/widgets/drawer_header_widget.dart';
import 'package:vegon_user/features/dashboard/widgets/drawer_menu_item.dart';
import 'package:vegon_user/features/dashboard/widgets/drawer_quick_actions.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';
import 'package:vegon_user/features/profile/screens/account_settings_screen.dart';
import 'package:vegon_user/features/profile/screens/contact_support_screen.dart';
import 'package:vegon_user/features/profile/screens/help_center_screen.dart';
import 'package:vegon_user/features/profile/screens/payment_methods_screen.dart';
import 'package:vegon_user/features/profile/screens/profile_screen.dart';
import 'package:vegon_user/features/profile/screens/saved_addresses_screen.dart';
import 'package:vegon_user/features/profile/screens/terms_privacy_screen.dart';
import 'package:vegon_user/features/profile/screens/wallet_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final UserProfileController profileController =
        Get.isRegistered<UserProfileController>()
        ? Get.find<UserProfileController>()
        : Get.put(UserProfileController());
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    void navigateTab(int index) {
      Get.back();
      dashboardController.changeTabIndex(index);
    }

    void navigateTo(Widget Function() page) {
      Get.back();
      Get.to(page);
    }

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeaderWidget(
            profileController: profileController,
            onProfileTap: () {
              Get.back();
              if (Get.isRegistered<DashboardController>()) {
                dashboardController.changeTabIndex(4);
              } else {
                Get.to(() => const ProfileScreen());
              }
            },
            onCloseTap: () => Get.back(),
          ),
          AppSpacing.h8,
          DrawerQuickActions(
            onOrdersTap: () => navigateTab(2),
            onWalletTap: () => navigateTo(() => const WalletScreen()),
            onWishlistTap: () => navigateTab(3),
          ),
          AppSpacing.h4,
          Expanded(
            child: Obx(() {
              final selectedTab = dashboardController.selectedIndex.value;
              final cartCount = cartController.totalItems;

              return ListView(
                padding: AppSpacing.paddingZero,
                children: [
                  const DrawerSectionLabel(title: AppStrings.drawerShopping),
                  DrawerMenuItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    title: AppStrings.home,
                    isSelected: selectedTab == 0,
                    onTap: () => navigateTab(0),
                  ),
                  DrawerMenuItem(
                    icon: Icons.grid_view_outlined,
                    selectedIcon: Icons.grid_view_rounded,
                    title: AppStrings.categories,
                    isSelected: selectedTab == 1,
                    onTap: () => navigateTab(1),
                  ),
                  DrawerMenuItem(
                    icon: Icons.shopping_cart_outlined,
                    selectedIcon: Icons.shopping_cart_rounded,
                    title: AppStrings.cart,
                    onTap: () => navigateTo(() => CartScreen()),
                    trailing: cartCount > 0
                        ? Container(
                            padding: AppSpacing.paddingHorizontal8,
                            height: AppSpacing.drawerBadgeSize,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppSpacing.radius10),
                              ),
                            ),
                            child: Text(
                              cartCount.toString(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          )
                        : null,
                  ),
                  DrawerMenuItem(
                    icon: Icons.local_offer_outlined,
                    selectedIcon: Icons.local_offer_rounded,
                    title: AppStrings.specialOffers,
                    onTap: () => navigateTo(() => const CouponsScreen()),
                    trailing: Container(
                      padding: AppSpacing.paddingHorizontal8,
                      height: AppSpacing.drawerBadgeSize,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.saleYellow,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppSpacing.radius10),
                        ),
                      ),
                      child: Text(
                        AppStrings.specialOffer,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: AppColors.borderLight,
                    indent: AppSpacing.drawerDividerIndent,
                    endIndent: AppSpacing.drawerDividerIndent,
                  ),
                  const DrawerSectionLabel(title: AppStrings.drawerAccount),
                  DrawerMenuItem(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    title: AppStrings.myOrders,
                    isSelected: selectedTab == 2,
                    onTap: () => navigateTab(2),
                  ),
                  DrawerMenuItem(
                    icon: Icons.location_on_outlined,
                    selectedIcon: Icons.location_on_rounded,
                    title: AppStrings.deliveryAddresses,
                    onTap: () => navigateTo(() => SavedAddressesScreen()),
                  ),
                  DrawerMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    selectedIcon: Icons.account_balance_wallet_rounded,
                    title: AppStrings.wallet,
                    onTap: () => navigateTo(() => const WalletScreen()),
                  ),
                  DrawerMenuItem(
                    icon: Icons.credit_card_outlined,
                    selectedIcon: Icons.credit_card_rounded,
                    title: AppStrings.paymentMethods,
                    onTap: () => navigateTo(() => const PaymentMethodsScreen()),
                  ),
                  DrawerMenuItem(
                    icon: Icons.notifications_none_rounded,
                    selectedIcon: Icons.notifications_rounded,
                    title: AppStrings.notifications,
                    onTap: () => navigateTo(() => const NotificationScreen()),
                  ),
                  const Divider(
                    color: AppColors.borderLight,
                    indent: AppSpacing.drawerDividerIndent,
                    endIndent: AppSpacing.drawerDividerIndent,
                  ),
                  const DrawerSectionLabel(title: AppStrings.drawerSupport),
                  DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    title: AppStrings.settings,
                    onTap: () => navigateTo(() => const AccountSettingsScreen()),
                  ),
                  DrawerMenuItem(
                    icon: Icons.help_outline_rounded,
                    selectedIcon: Icons.help_rounded,
                    title: AppStrings.helpSupport,
                    onTap: () => navigateTo(() => const HelpCenterScreen()),
                  ),
                  DrawerMenuItem(
                    icon: Icons.headset_mic_outlined,
                    selectedIcon: Icons.headset_mic_rounded,
                    title: AppStrings.contactSupport,
                    onTap: () => navigateTo(() => const ContactSupportScreen()),
                  ),
                  DrawerMenuItem(
                    icon: Icons.shield_outlined,
                    selectedIcon: Icons.shield_rounded,
                    title: AppStrings.termsPrivacy,
                    onTap: () => navigateTo(() => const TermsPrivacyScreen()),
                  ),
                  AppSpacing.h12,
                ],
              );
            }),
          ),
          DrawerFooter(
            onLogoutTap: () {
              Get.back();
              authController.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
