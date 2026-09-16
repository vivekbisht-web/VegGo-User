//
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/cart/models/cart_models.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';
import '../models/cart_item.dart';
import '../services/cart_repository.dart';
import 'package:vegon_user/core/utils/snackbar_helper.dart';

class CartValidationResult {
  final bool isValid;
  final String? errorMessage;

  const CartValidationResult.success() : isValid = true, errorMessage = null;

  const CartValidationResult.failure(this.errorMessage) : isValid = false;
}

class CartController extends GetxController {
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final Rxn<CartModel> currentCart = Rxn<CartModel>();
  final RxString appliedPromo = ''.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxBool isFreeShipping = false.obs;
  final RxBool isProcessingOperation = false.obs;
  final RxInt badgeCount = 0.obs;
  final CartRepository _cartRepo = CartRepository();

  @override
  void onInit() {
    super.onInit();
    loadCart();
    ever(cartItems, (_) {
      badgeCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    });
  }

  Future<void> fetchCartBadgeCount() async {
    try {
      final count = await _cartRepo.getCartBadgeCount();
      badgeCount.value = count;
    } catch (e) {
      debugPrint("Error fetching cart badge count: $e");
    }
  }

  Future<void> loadCart() async {
    print("😀😀😀😀");
    try {
      isProcessingOperation.value = true;
      double? lat;
      double? lng;
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        lat = locCtrl.latitude;
        lng = locCtrl.longitude;
      }

      final cartData = await _cartRepo.getCart(latitude: lat, longitude: lng);
      if (cartData != null) {
        currentCart.value = cartData;
        cartItems.value = cartData.items;
      } else {
        cartItems.clear();
      }
    } catch (e, stackTrace) {
      debugPrint("Error loading cart: $e\n$stackTrace");
    } finally {
      isProcessingOperation.value = false;
    }
  }

  CartValidationResult _validateProduct(dynamic product) {
    if (product == null) {
      return const CartValidationResult.failure(AppStrings.invalidProductData);
    }
    if (product is Map) {
      final id = product['id']?.toString() ?? product['name']?.toString() ?? '';
      if (id.trim().isEmpty) {
        return const CartValidationResult.failure(
          AppStrings.invalidProductData,
        );
      }
      final isAvailable = product['isAvailable'] as bool? ?? true;
      if (!isAvailable) {
        return const CartValidationResult.failure(
          AppStrings.productUnavailable,
        );
      }
      final status = product['status']?.toString();
      if (status != null && status.toLowerCase() == 'inactive') {
        return const CartValidationResult.failure(
          AppStrings.productUnavailable,
        );
      }
    }
    return const CartValidationResult.success();
  }

  Future<bool> addToCart(
    dynamic product, {
    int qty = 1,
    bool showSnackbarOnError = true,
  }) async {
    if (isProcessingOperation.value) return false;
    isProcessingOperation.value = true;

    try {
      final productValidation = _validateProduct(product);
      if (!productValidation.isValid) {
        if (showSnackbarOnError && productValidation.errorMessage != null) {
          _showErrorSnackbar(productValidation.errorMessage!);
        }
        return false;
      }

      final id = product['id']?.toString() ?? product['name']?.toString() ?? '';
      final shopId =
          product['shopId']?.toString() ?? product['vendorId']?.toString();

      if (qty <= 0) {
        if (showSnackbarOnError) _showErrorSnackbar(AppStrings.invalidQuantity);
        return false;
      }

      double? lat;
      double? lng;
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        lat = locCtrl.latitude;
        lng = locCtrl.longitude;
      }

      final cartData = await _cartRepo.addToCart(
        id,
        qty,
        latitude: lat,
        longitude: lng,
        shopId: shopId,
      );
      if (cartData is CartModel) {
        currentCart.value = cartData;
        cartItems.value = cartData.items;
        badgeCount.value = cartItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );
        cartItems.refresh();
        return true;
      } else if (cartData == true) {
        // Successfully added, but no cart data returned. Fetch it.
        await loadCart();
        badgeCount.value = cartItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );
        cartItems.refresh();
        return true;
      }

      if (showSnackbarOnError) {
        _showErrorSnackbar(AppStrings.unableToAddProduct);
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint("AddToCart Error: $e\n$stackTrace");
      if (showSnackbarOnError) {
        final rawMsg = e.toString().replaceAll('Exception: ', '').trim();
        final cleanMsg = rawMsg.isNotEmpty
            ? rawMsg.split('\n')[0]
            : AppStrings.unableToAddProduct;
        _showErrorSnackbar(cleanMsg);
      }
      return false;
    } finally {
      isProcessingOperation.value = false;
    }
  }

  Future<void> removeSingleItem(String id) async {
    if (isProcessingOperation.value) return;
    isProcessingOperation.value = true;

    try {
      final index = cartItems.indexWhere(
        (item) => item.id == id || item.cartKey == id || item.productId == id,
      );
      if (index >= 0) {
        final item = cartItems[index];
        if (item.quantity > 1) {
          final cartData = await _cartRepo.updateCartItemQuantity(
            item.id,
            item.quantity - 1,
          );
          if (cartData != null) {
            currentCart.value = cartData;
            cartItems.value = cartData.items;
          }
        } else {
          final success = await _cartRepo.removeCartItem(item.id);
          if (success != null) {
            cartItems.removeAt(index);
            if (cartItems.isEmpty) {
              currentCart.value = null;
              appliedPromo.value = '';
              discountAmount.value = 0.0;
              isFreeShipping.value = false;
            }
          }
        }
        badgeCount.value = cartItems.fold(0, (sum, i) => sum + i.quantity);
        cartItems.refresh();
      }
    } catch (e) {
      _showErrorSnackbar(AppStrings.failedToUpdateQuantity);
    } finally {
      isProcessingOperation.value = false;
    }
  }

  Future<void> incrementQuantity(String id) async {
    if (isProcessingOperation.value) return;
    isProcessingOperation.value = true;

    try {
      final index = cartItems.indexWhere(
        (item) => item.id == id || item.cartKey == id || item.productId == id,
      );
      if (index >= 0) {
        final item = cartItems[index];
        final cartData = await _cartRepo.updateCartItemQuantity(
          item.id,
          item.quantity + 1,
        );
        if (cartData != null) {
          currentCart.value = cartData;
          cartItems.value = cartData.items;
        } else {
          item.quantity++;
        }
        badgeCount.value = cartItems.fold(0, (sum, i) => sum + i.quantity);
        cartItems.refresh();
      }
    } catch (e) {
      _showErrorSnackbar(AppStrings.failedToUpdateQuantity);
    } finally {
      isProcessingOperation.value = false;
    }
  }

  void decrementQuantity(String id) {
    removeSingleItem(id);
  }

  void incrementItem(String id) => incrementQuantity(id);
  void decrementItem(String id) => decrementQuantity(id);

  Future<void> removeItem(String id) async {
    if (isProcessingOperation.value) return;
    isProcessingOperation.value = true;

    try {
      final index = cartItems.indexWhere(
        (item) => item.id == id || item.cartKey == id || item.productId == id,
      );
      if (index >= 0) {
        final item = cartItems[index];
        final success = await _cartRepo.removeCartItem(item.id);
        if (success != null) {
          cartItems.removeAt(index);
          if (cartItems.isEmpty) {
            currentCart.value = null;
            appliedPromo.value = '';
            discountAmount.value = 0.0;
            isFreeShipping.value = false;
          }
          badgeCount.value = cartItems.fold(0, (sum, i) => sum + i.quantity);
          cartItems.refresh();
        }
      }
    } catch (e) {
      _showErrorSnackbar(AppStrings.failedToRemoveItem);
    } finally {
      isProcessingOperation.value = false;
    }
  }

  Future<void> clearCart() async {
    if (isProcessingOperation.value) return;
    isProcessingOperation.value = true;

    try {
      await _cartRepo.clearCart();
    } catch (_) {
      // Backend may throw 500 if cart was already cleared or converted on order placement
    } finally {
      currentCart.value = null;
      cartItems.clear();
      badgeCount.value = 0;
      appliedPromo.value = '';
      discountAmount.value = 0.0;
      isFreeShipping.value = false;
      cartItems.refresh();
      isProcessingOperation.value = false;
    }
  }

  bool applyPromoCode(String promoCode) {
    if (promoCode.trim().isEmpty) {
      _showErrorSnackbar(AppStrings.pleaseEnterPromo);
      return false;
    }

    final code = promoCode.trim().toUpperCase();

    if (code == 'FRESH20') {
      if (subtotal < 150.0) {
        _showErrorSnackbar(
          "${AppStrings.minimumOrderValue} FRESH20: ${AppStrings.rupeeSymbol}150",
        );
        return false;
      }
      appliedPromo.value = code;
      discountAmount.value = (subtotal * 0.20) > 50.0
          ? 50.0
          : (subtotal * 0.20);
      isFreeShipping.value = false;
      return true;
    } else if (code == 'FREESHIP') {
      if (subtotal < 99.0) {
        _showErrorSnackbar(
          "${AppStrings.minimumOrderValue} FREESHIP: ${AppStrings.rupeeSymbol}99",
        );
        return false;
      }
      appliedPromo.value = code;
      discountAmount.value = 0.0;
      isFreeShipping.value = true;
      return true;
    } else if (code == 'VEGON5' || code == 'PROMO10') {
      appliedPromo.value = code;
      discountAmount.value = 10.0;
      isFreeShipping.value = false;
      return true;
    } else {
      _showErrorSnackbar(AppStrings.invalidCouponCode);
      return false;
    }
  }

  void removePromoCode() {
    appliedPromo.value = '';
    discountAmount.value = 0.0;
    isFreeShipping.value = false;
  }

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get deliveryFee {
    if (subtotal <= 0) return 0.0;
    if (isFreeShipping.value || subtotal >= 299.0) return 0.0;
    return 30.0;
  }

  double get estimatedTaxes {
    if (subtotal <= 0) return 0.0;
    return subtotal * 0.05;
  }

  double get total {
    if (cartItems.isEmpty || subtotal <= 0) return 0.0;
    double computedTotal =
        (subtotal - discountAmount.value) + deliveryFee + estimatedTaxes;
    return computedTotal < 0 ? 0.0 : computedTotal;
  }

  double get totalAmount => total;

  int get totalItems => badgeCount.value;

  bool isInCart(String id) {
    return cartItems.any((item) => item.id == id || item.cartKey == id);
  }

  int getItemQuantity(String id) {
    final item = cartItems.firstWhereOrNull(
      (item) => item.id == id || item.cartKey == id,
    );
    return item?.quantity ?? 0;
  }

  void _showErrorSnackbar(String message) {
    SnackbarHelper.showGetError(message);
  }
}
