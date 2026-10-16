//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/network/api_client.dart';
import 'package:vegon_user/features/cart/models/cart_models.dart';
import 'package:vegon_user/features/cart/models/checkout_summary_model.dart';
import 'package:vegon_user/features/cart/models/delivery_slots_response_model.dart';
import 'package:vegon_user/features/cart/models/place_order_response_model.dart';
import 'package:vegon_user/features/cart/models/remove_cart_item_response_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  /// Parses the `data` field of a cart-bearing API response into one
  /// [CartModel] per vendor. The backend groups items by vendor/shop and
  /// returns an array (one cart per vendor) even when there's only one;
  /// this stays defensive in case a single cart object is ever returned
  /// on its own.
  List<CartModel> _parseCarts(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => CartModel.fromJson(e))
          .toList();
    } else if (data is Map<String, dynamic>) {
      return [CartModel.fromJson(data)];
    }
    return [];
  }

  /// Fetches every active vendor cart for the current user.
  Future<List<CartModel>> getCarts({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null && latitude != 0.0) {
        queryParams['latitude'] = latitude;
      }
      if (longitude != null && longitude != 0.0) {
        queryParams['longitude'] = longitude;
      }

      final response = await _apiClient.get(
        ApiEndpoints.viewCart,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final dataMap = response.data is String
          ? <String, dynamic>{} // Fallback if it's strangely a string
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return _parseCarts(dataMap[AppStrings.apiData]);
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching carts: $e");
      return [];
    }
  }

  Future<CheckoutSummaryModel?> getCheckoutSummary(String addressId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.checkoutSummary,
        queryParameters: {'addressId': addressId},
      );
      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return CheckoutSummaryModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<DeliverySlotsResponseModel?> getDeliverySlots() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.deliverySlots);
      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        return DeliverySlotsResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<PlaceOrderResponseModel?> placeOrder({
    required String addressId,
    List<String>? cartIds,
    String? paymentMethodId,
    String? deliverySlotId,
    String? scheduledDate,
  }) async {
    try {
      final Map<String, dynamic> body = {'addressId': addressId};
      if (cartIds != null && cartIds.isNotEmpty) {
        body['cartIds'] = cartIds;
      }
      if (paymentMethodId != null && paymentMethodId.isNotEmpty) {
        body['paymentMethodId'] = paymentMethodId;
      }
      if (deliverySlotId != null && deliverySlotId.isNotEmpty) {
        body['deliverySlotId'] = deliverySlotId;
      }
      if (scheduledDate != null && scheduledDate.isNotEmpty) {
        body['scheduledDate'] = scheduledDate;
      }

      final response = await _apiClient.post(
        ApiEndpoints.placeOrder,
        data: body,
      );
      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null) {
        return PlaceOrderResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getCartBadgeCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cartBadgeCount);
      final dataMap = response.data as Map<String, dynamic>?;
      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        final data = dataMap[AppStrings.apiData] as Map<String, dynamic>?;
        if (data != null && data[AppStrings.apiCount] != null) {
          return (data[AppStrings.apiCount] as num).toInt();
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<dynamic> addToCart(
    String productId,
    int quantity, {
    double? latitude,
    double? longitude,
    String? shopId,
  }) async {
    final qty = quantity < 1 ? 1 : quantity;

    final body = <String, dynamic>{
      AppStrings.apiProductId: productId,
      AppStrings.apiQuantity: qty,
    };
    final queryParams = <String, dynamic>{};

    if (latitude != null && latitude != 0.0) {
      body['latitude'] = latitude;
      queryParams['latitude'] = latitude;
    }
    if (longitude != null && longitude != 0.0) {
      body['longitude'] = longitude;
      queryParams['longitude'] = longitude;
    }
    if (shopId != null && shopId.isNotEmpty) {
      body['shopId'] = shopId;
      body['vendorId'] = shopId;
    }

    final response = await _apiClient.post(
      ApiEndpoints.addToCart,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      data: body,
    );
    final dataMap = response.data is String
        ? <String, dynamic>{} // Fallback
        : response.data as Map<String, dynamic>?;

    if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
      final data = dataMap[AppStrings.apiData];
      final carts = _parseCarts(data);
      if (carts.isNotEmpty) {
        return carts; // List<CartModel> — every vendor cart, up to date
      }
      return true; // Success but no cart data returned
    }
    return false; // Failed
  }

  /// Updates a single cart item's quantity and returns every vendor cart
  /// as it now stands (a quantity change never removes a whole vendor
  /// cart, but other carts are still returned so the UI can stay in sync
  /// without a full refetch).
  Future<List<CartModel>?> updateCartItemQuantity(
    String cartItemId,
    int quantity,
  ) async {
    final qty = quantity < 1 ? 1 : quantity;
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.updateCartItem(cartItemId)}?quantity=$qty',
      );
      final dataMap = response.data as Map<String, dynamic>?;
      if (dataMap != null && dataMap[AppStrings.apiSuccess] == true) {
        final carts = _parseCarts(dataMap[AppStrings.apiData]);
        if (carts.isNotEmpty) return carts;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<RemoveCartItemResponseModel?> removeCartItem(String cartItemId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.deleteCartItem(cartItemId),
      );
      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null) {
        return RemoveCartItemResponseModel.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> clearCart() async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.viewCart);
      final dataMap = response.data as Map<String, dynamic>?;
      return dataMap != null && dataMap[AppStrings.apiSuccess] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    String? paymentOrderId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        AppStrings.apiRazorpayPaymentId: razorpayPaymentId,
        AppStrings.apiRazorpayOrderId: razorpayOrderId,
        AppStrings.apiRazorpaySignature: razorpaySignature,
        if (paymentOrderId != null && paymentOrderId.isNotEmpty)
          'paymentOrderId': paymentOrderId,
      };

      final response = await _apiClient.post(
        ApiEndpoints.verifyPayment,
        data: body,
      );

      final dataMap = response.data is String
          ? <String, dynamic>{}
          : response.data as Map<String, dynamic>?;

      if (dataMap != null) {
        return dataMap[AppStrings.apiSuccess] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
