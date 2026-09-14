import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/services/razorpay_service.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/models/checkout_summary_model.dart';
import 'package:vegon_user/features/cart/models/place_order_response_model.dart';
import 'package:vegon_user/features/cart/services/cart_repository.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';
import 'package:vegon_user/features/profile/controllers/user_profile_controller.dart';
import 'package:vegon_user/features/profile/models/address_models.dart';
import 'package:vegon_user/features/profile/screens/saved_addresses_screen.dart';

class CheckoutController extends GetxController {
  final CartRepository _cartRepo = CartRepository();
  final RazorpayService _razorpayService = RazorpayService();
  void Function(PlaceOrderResponseModel response)? _onOrderPlacedSuccess;
  
  var selectedDateIndex = 0.obs;
  var selectedTimeIndex = 0.obs;
  var selectedPaymentIndex = 0.obs;
  
  var isProcessingOrder = false.obs;
  var isLoadingSlots = false.obs;
  var isLoadingSummary = false.obs;

  var selectedAddress = Rxn<AddressModel>();
  var checkoutSummary = Rxn<CheckoutSummaryModel>();
  var placedOrderResult = Rxn<PlaceOrderResponseModel>();
  
  var timeSlots = <String>[].obs;
  var deliveryDates = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initStaticSlots();
    _initRazorpay();
    _initCheckout();
  }

  void _initRazorpay() {
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void onClose() {
    _razorpayService.dispose();
    super.onClose();
  }

  Future<void> _initCheckout() async {
    final addressCtrl = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());
    if (addressCtrl.addresses.isEmpty) {
      await addressCtrl.fetchAddresses();
    }
    _loadDefaultAddress();
    if (selectedAddress.value != null) {
      await fetchCheckoutSummary(selectedAddress.value!.id);
    }
  }

  void _loadDefaultAddress() {
    final addressCtrl = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());
    if (addressCtrl.addresses.isEmpty) return;

    AddressModel? matchedAddress;

    if (Get.isRegistered<LocationController>()) {
      final locCtrl = Get.find<LocationController>();
      final activeLat = locCtrl.latitude;
      final activeLng = locCtrl.longitude;

      if (activeLat != null && activeLng != null) {
        matchedAddress = addressCtrl.addresses.firstWhereOrNull((addr) {
          final lat = addr.rawAddressData?.latitude;
          final lng = addr.rawAddressData?.longitude;
          if (lat != null && lng != null) {
            return (lat - activeLat).abs() < 0.005 && (lng - activeLng).abs() < 0.005;
          }
          return false;
        });
      }
    }

    selectedAddress.value = matchedAddress ??
        addressCtrl.addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => addressCtrl.addresses.first,
        );
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
    fetchCheckoutSummary(address.id);
  }

  Future<void> fetchCheckoutSummary(String addressId) async {
    if (addressId.isEmpty) return;
    isLoadingSummary.value = true;
    try {
      final summary = await _cartRepo.getCheckoutSummary(addressId);
      if (summary != null) {
        checkoutSummary.value = summary;
      }
    } catch (e) {
      debugPrint("Error fetching checkout summary: $e");
    } finally {
      isLoadingSummary.value = false;
    }
  }

  void _initStaticSlots() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final dayAfter = now.add(const Duration(days: 2));

    deliveryDates.assignAll([
      {"label": AppStrings.today, "date": DateFormat('MMM dd').format(now)},
      {"label": AppStrings.tomorrow, "date": DateFormat('MMM dd').format(tomorrow)},
      {
        "label": DateFormat('EEE').format(dayAfter).toUpperCase(),
        "date": DateFormat('MMM dd').format(dayAfter),
      },
    ]);

    timeSlots.assignAll([
      "09:00 - 11:00",
      "11:00 - 13:00",
      "13:00 - 15:00",
      "15:00 - 17:00",
      "17:00 - 19:00",
      "19:00 - 21:00",
    ]);
  }

  String get selectedPaymentMethodId {
    switch (selectedPaymentIndex.value) {
      case 0:
        return "COD";
      case 1:
        return "UPI";
      case 2:
        return "CARD";
      default:
        return "COD";
    }
  }

  Future<void> placeOrder(
    void Function(PlaceOrderResponseModel response) onSuccess,
  ) async {
    if (isProcessingOrder.value) return;

    if (Get.isRegistered<CartController>()) {
      final cartCtrl = Get.find<CartController>();
      if (cartCtrl.cartItems.isEmpty) {
        Get.snackbar(
          AppStrings.error,
          AppStrings.cartEmptyWarning,
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
        );
        return;
      }
    }

    if (selectedAddress.value == null || selectedAddress.value!.id.isEmpty) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.pleaseSelectAddress,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return;
    }

    isProcessingOrder.value = true;
    _onOrderPlacedSuccess = onSuccess;

    try {
      final response = await _cartRepo.placeOrder(
        addressId: selectedAddress.value!.id,
        paymentMethodId: selectedPaymentMethodId,
      );

      if (response != null && response.success == true) {
        placedOrderResult.value = response;

        // COD completes immediately
        if (selectedPaymentIndex.value == 0) {
          isProcessingOrder.value = false;
          _onOrderPlacedSuccess = null;
          onSuccess(response);
          return;
        }

        // Online payment via Razorpay
        final paymentHold = response.data?.paymentHold;
        final razorpayOrderId = paymentHold?.razorpayOrderId;
        final razorpayKeyId = (paymentHold?.razorpayKeyId != null &&
                paymentHold!.razorpayKeyId!.isNotEmpty)
            ? paymentHold.razorpayKeyId!
            : ApiEndpoints.razorpayKey;

        final amount = paymentHold?.totalAmount ??
            (response.data?.orders?.isNotEmpty == true
                ? response.data!.orders!.first.totalAmount ?? 0.0
                : (Get.isRegistered<CartController>()
                    ? Get.find<CartController>().total
                    : 0.0));

        if (amount <= 0) {
          isProcessingOrder.value = false;
          _onOrderPlacedSuccess = null;
          onSuccess(response);
          return;
        }

        String? contact;
        String? email;
        if (Get.isRegistered<UserProfileController>()) {
          final profileCtrl = Get.find<UserProfileController>();
          contact = profileCtrl.phone;
          email = profileCtrl.email;
        }

        final didOpen = _razorpayService.openCheckout(
          key: razorpayKeyId,
          orderId: razorpayOrderId,
          amount: amount,
          currency: paymentHold?.currency ?? 'INR',
          contact: contact,
          email: email,
        );

        if (!didOpen) {
          isProcessingOrder.value = false;
          _onOrderPlacedSuccess = null;
          Get.snackbar(
            AppStrings.error,
            AppStrings.razorpayFailedToOpen,
            backgroundColor: AppColors.error,
            colorText: AppColors.surface,
          );
        }
      } else {
        isProcessingOrder.value = false;
        _onOrderPlacedSuccess = null;
        Get.snackbar(
          AppStrings.error,
          response?.message ?? AppStrings.failedToPlaceOrder,
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
        );
      }
    } catch (e) {
      isProcessingOrder.value = false;
      _onOrderPlacedSuccess = null;
      final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
      Get.snackbar(
        AppStrings.error,
        errorMsg.isNotEmpty ? errorMsg : AppStrings.unexpectedError,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isProcessingOrder.value = true;
    final paymentId = response.paymentId ?? '';
    final orderId = response.orderId ?? '';
    final signature = response.signature ?? '';
    final paymentOrderId =
        placedOrderResult.value?.data?.paymentHold?.paymentOrderId;

    final isVerified = await _cartRepo.verifyPayment(
      razorpayPaymentId: paymentId,
      razorpayOrderId: orderId,
      razorpaySignature: signature,
      paymentOrderId: paymentOrderId,
    );

    isProcessingOrder.value = false;

    if (isVerified) {
      Get.snackbar(
        AppStrings.paymentSuccess,
        paymentId.isNotEmpty
            ? AppStrings.paymentSuccessDesc(paymentId)
            : AppStrings.purchaseSuccessDesc,
        backgroundColor: AppColors.success,
        colorText: AppColors.surface,
      );

      if (_onOrderPlacedSuccess != null && placedOrderResult.value != null) {
        final callback = _onOrderPlacedSuccess!;
        _onOrderPlacedSuccess = null;
        callback(placedOrderResult.value!);
      }
    } else {
      _onOrderPlacedSuccess = null;
      Get.snackbar(
        AppStrings.error,
        AppStrings.paymentVerificationFailed,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessingOrder.value = false;
    final message = response.message != null && response.message!.isNotEmpty
        ? response.message!
        : AppStrings.paymentCancelled;

    Get.snackbar(
      AppStrings.paymentFailed,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.surface,
    );
    _onOrderPlacedSuccess = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessingOrder.value = false;
    if (_onOrderPlacedSuccess != null && placedOrderResult.value != null) {
      final callback = _onOrderPlacedSuccess!;
      _onOrderPlacedSuccess = null;
      callback(placedOrderResult.value!);
    }
  }

  void showChangeAddressDialog(BuildContext context) {
    Get.to(() => SavedAddressesScreen());
  }
}

