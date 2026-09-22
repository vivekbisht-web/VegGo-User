//
import 'package:get/get.dart';
import 'app_routes.dart';

import '../features/splash/splash_screen.dart';
import '../features/splash/splash_controller.dart';
import '../features/splash/onboarding_screen.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/basic_info_screen.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/dashboard/controllers/notification_controller.dart';
import '../features/dashboard/screens/notification_screen.dart';
import '../features/home/screens/home_screen.dart';

import '../features/category/screens/category_screen.dart';
import '../features/category/controller/category_controller.dart';
import '../features/product/screens/product_details_screen.dart';
import '../features/product/controllers/product_details_controller.dart';
import '../features/product/controllers/wishlist_controller.dart';
import '../features/product/screens/product_reviews_screen.dart';
import '../features/product/screens/related_items_screen.dart';

import '../features/cart/screens/cart_screen.dart';
import '../features/cart/controllers/cart_controller.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/cart/controllers/checkout_controller.dart';
import '../features/cart/screens/order_success_screen.dart';
import '../features/cart/screens/coupons_screen.dart';

import '../features/orders/screens/my_orders_screen.dart';
import '../features/orders/screens/order_details_screen.dart';
import '../features/orders/screens/order_delivered_screen.dart';
import '../features/orders/screens/track_order_screen.dart';
import '../features/orders/controllers/orders_controller.dart';

import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/account_settings_screen.dart';
import '../features/profile/screens/saved_addresses_screen.dart';
import '../features/profile/screens/add_address_screen.dart';
import '../features/profile/controllers/address_controller.dart';
import '../features/profile/screens/payment_methods_screen.dart';
import '../features/profile/screens/add_payment_method_screen.dart';
import '../features/profile/screens/wallet_screen.dart';
import '../features/profile/screens/favorites_screen.dart';
import '../features/profile/screens/language_screen.dart';
import '../features/profile/screens/notifications_settings_screen.dart';
import '../features/profile/screens/help_center_screen.dart';
import '../features/profile/screens/contact_support_screen.dart';
import '../features/profile/screens/terms_privacy_screen.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OTPVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.basicInfo,
      page: () => const BasicInfoScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(CartController());
        Get.put(WishlistController());
        Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
        Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
        Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
        Get.lazyPut<NotificationController>(
          () => NotificationController(),
          fenix: true,
        );
      }),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryScreen(),
      binding: BindingsBuilder(() {
        Get.put(CategoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => ProductDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProductDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.productReviews,
      page: () => const ProductReviewsScreen(),
    ),
    GetPage(
      name: AppRoutes.relatedItems,
      page: () => const RelatedItemsScreen(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(),
      binding: BindingsBuilder(() {
        Get.put(CartController());
      }),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => CheckoutScreen(),
      binding: BindingsBuilder(() {
        Get.put(CheckoutController());
      }),
    ),
    GetPage(name: AppRoutes.orderSuccess, page: () => OrderSuccessScreen()),
    GetPage(name: AppRoutes.coupons, page: () => const CouponsScreen()),
    GetPage(
      name: AppRoutes.myOrders,
      page: () => const MyOrdersScreen(),
      binding: BindingsBuilder(() {
        Get.put(OrdersController());
      }),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.put(OrdersController());
      }),
    ),
    GetPage(
      name: AppRoutes.orderDelivered,
      page: () => const OrderDeliveredScreen(),
    ),
    GetPage(
      name: AppRoutes.trackOrder,
      page: () => TrackOrderScreen(),
      binding: BindingsBuilder(() {
        Get.put(OrdersController());
      }),
    ),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
    GetPage(
      name: AppRoutes.accountSettings,
      page: () => const AccountSettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.savedAddresses,
      page: () => SavedAddressesScreen(),
      binding: BindingsBuilder(() {
        Get.put(AddressController());
      }),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const AddAddressScreen(),
      binding: BindingsBuilder(() {
        Get.put(AddressController());
      }),
    ),
    GetPage(
      name: AppRoutes.paymentMethods,
      page: () => const PaymentMethodsScreen(),
    ),
    GetPage(
      name: AppRoutes.addPaymentMethod,
      page: () => const AddPaymentMethodScreen(),
    ),
    GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
    GetPage(name: AppRoutes.language, page: () => const LanguageScreen()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationsSettingsScreen(),
    ),
    GetPage(name: AppRoutes.wallet, page: () => const WalletScreen()),
    GetPage(name: AppRoutes.helpCenter, page: () => const HelpCenterScreen()),
    GetPage(
      name: AppRoutes.contactSupport,
      page: () => const ContactSupportScreen(),
    ),
    GetPage(
      name: AppRoutes.termsPrivacy,
      page: () => const TermsPrivacyScreen(),
    ),
  ];
}
