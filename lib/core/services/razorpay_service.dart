import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vegon_user/core/constants/app_colors.dart';

/// Reusable service that manages Razorpay SDK integration and event handling.
class RazorpayService {
  Razorpay? _razorpay;

  /// Initialize Razorpay instance with event callbacks.
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    dispose();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  /// Opens the native Razorpay checkout sheet.
  /// Returns `true` if sheet was successfully triggered, `false` otherwise.
  bool openCheckout({
    required String key,
    String? orderId,
    required double amount,
    String currency = 'INR',
    String name = 'VegGo Fresh',
    String description = 'Order Payment',
    String? contact,
    String? email,
  }) {
    if (_razorpay == null) {
      debugPrint('RazorpayService is not initialized.');
      return false;
    }

    if (key.trim().isEmpty) {
      debugPrint('Razorpay key is empty.');
      return false;
    }

    final int amountInPaise = (amount * 100).round();
    if (amountInPaise <= 0) {
      debugPrint('Invalid payment amount: $amount');
      return false;
    }

    final options = <String, dynamic>{
      'key': key.trim(),
      'amount': amountInPaise,
      'name': name,
      'description': description,
      if (orderId != null && orderId.trim().isNotEmpty)
        'order_id': orderId.trim(),
      'currency': currency,
      'timeout': 300,
      'prefill': <String, String>{
        if (contact != null && contact.trim().isNotEmpty)
          'contact': contact.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      },
      'theme': <String, String>{
        'color': AppColors.primaryHex,
      },
    };

    try {
      _razorpay!.open(options);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error opening Razorpay checkout: $e\n$stackTrace');
      return false;
    }
  }

  /// Cleans up listeners and disposes the Razorpay instance.
  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
