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

/// Manages the user's cart. A user can hold one cart per vendor at a time
/// (e.g. adding items from two different shops creates two separate
/// vendor carts), so [carts] is the source of truth and everything else
/// on this controller is derived from it.
class CartController extends GetxController {
  /// One entry per vendor/shop cart, exactly as returned by the backend.
  final RxList<CartModel> carts = <CartModel>[].obs;

  /// Every item across every vendor cart, flattened. Kept in sync with
  /// [carts] automatically. Existing screens that only care "is this
  /// product in the cart" / "what's in the badge" can keep reading this
  /// without knowing multiple vendor carts exist underneath.
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  /// Vendor carts the user has expanded in the cart screen. A single
  /// vendor cart is always shown expanded; this only matters once there
  /// is more than one.
  final RxSet<String> expandedCartIds = <String>{}.obs;

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

  /// Number of distinct vendor carts currently held.
  int get cartCount => carts.length;

  /// Whether the user has items from more than one vendor at once — the
  /// cart screen only needs to show vendor grouping/chrome when this is
  /// true.
  bool get hasMultipleCarts => carts.length > 1;

  bool isExpanded(String cartId) =>
      carts.length <= 1 || expandedCartIds.contains(cartId);

  void toggleCartExpanded(String cartId) {
    if (expandedCartIds.contains(cartId)) {
      expandedCartIds.remove(cartId);
    } else {
      expandedCartIds.add(cartId);
    }
  }

  double cartSubtotal(CartModel cart) =>
      cart.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  /// Replaces the whole cart set (e.g. after a fetch/add/update call
  /// returns the fresh state) and keeps every derived Rx value in sync in
  /// one place.
  void _syncCarts(List<CartModel> updated) {
    carts.value = updated;
    cartItems.value = updated.expand((c) => c.items).toList();
    for (final c in updated) {
      // Newly-seen vendor carts default to expanded.
      expandedCartIds.add(c.id);
    }
    cartItems.refresh();
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
    try {
      isProcessingOperation.value = true;
      double? lat;
      double? lng;
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        lat = locCtrl.latitude;
        lng = locCtrl.longitude;
      }

      final result = await _cartRepo.getCarts(latitude: lat, longitude: lng);
      _syncCarts(result);
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

      final result = await _cartRepo.addToCart(
        id,
        qty,
        latitude: lat,
        longitude: lng,
        shopId: shopId,
      );
      if (result is List<CartModel>) {
        _syncCarts(result);
        return true;
      } else if (result == true) {
        // Successfully added, but no cart data returned. Fetch it.
        await loadCart();
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

  /// Locates the (cartIndex, itemIndex) pair for an item id/cartKey,
  /// searching across every vendor cart. Item ids are unique globally, so
  /// no vendor context is needed from the caller.
  ({int cartIndex, int itemIndex})? _locate(String id) {
    for (var c = 0; c < carts.length; c++) {
      final i = carts[c].items.indexWhere(
        (item) => item.id == id || item.cartKey == id || item.productId == id,
      );
      if (i >= 0) return (cartIndex: c, itemIndex: i);
    }
    return null;
  }

  /// Removes one item from its vendor cart locally. If that was the last
  /// item in that vendor's cart, the whole vendor cart is dropped.
  void _removeItemLocally(int cartIndex, int itemIndex) {
    final cart = carts[cartIndex];
    final newItems = List<CartItem>.from(cart.items)..removeAt(itemIndex);

    final newCarts = List<CartModel>.from(carts);
    if (newItems.isEmpty) {
      newCarts.removeAt(cartIndex);
    } else {
      newCarts[cartIndex] = CartModel(
        id: cart.id,
        userId: cart.userId,
        cartLabel: cart.cartLabel,
        items: newItems,
        totalAmount: newItems.fold(0.0, (s, i) => s + i.price * i.quantity),
        itemCount: newItems.fold(0, (s, i) => s + i.quantity),
        deliveryFee: cart.deliveryFee,
        estimatedTax: cart.estimatedTax,
        promoDiscount: cart.promoDiscount,
      );
    }
    _syncCarts(newCarts);

    if (newCarts.isEmpty) {
      appliedPromo.value = '';
      discountAmount.value = 0.0;
      isFreeShipping.value = false;
    }
  }

  Future<void> removeSingleItem(String id) async {
    if (isProcessingOperation.value) return;
    isProcessingOperation.value = true;

    try {
      final loc = _locate(id);
      if (loc == null) return;
      final item = carts[loc.cartIndex].items[loc.itemIndex];

      if (item.quantity > 1) {
        final updated = await _cartRepo.updateCartItemQuantity(
          item.id,
          item.quantity - 1,
        );
        if (updated != null) {
          _syncCarts(updated);
        }
      } else {
        final success = await _cartRepo.removeCartItem(item.id);
        if (success != null) {
          _removeItemLocally(loc.cartIndex, loc.itemIndex);
        }
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
      final loc = _locate(id);
      if (loc == null) return;
      final item = carts[loc.cartIndex].items[loc.itemIndex];

      final updated = await _cartRepo.updateCartItemQuantity(
        item.id,
        item.quantity + 1,
      );
      if (updated != null) {
        _syncCarts(updated);
      } else {
        item.quantity++;
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
      final loc = _locate(id);
      if (loc == null) return;
      final item = carts[loc.cartIndex].items[loc.itemIndex];

      final success = await _cartRepo.removeCartItem(item.id);
      if (success != null) {
        _removeItemLocally(loc.cartIndex, loc.itemIndex);
      }
    } catch (e) {
      _showErrorSnackbar(AppStrings.failedToRemoveItem);
    } finally {
      isProcessingOperation.value = false;
    }
  }

  /// Removes an entire vendor cart in one action — e.g. a "clear this
  /// vendor's items" button on the cart-group header.
  Future<void> removeCartGroup(String cartId) async {
    if (isProcessingOperation.value) return;
    final cart = carts.firstWhereOrNull((c) => c.id == cartId);
    if (cart == null) return;

    isProcessingOperation.value = true;
    try {
      for (final item in List<CartItem>.from(cart.items)) {
        await _cartRepo.removeCartItem(item.id);
      }
      final newCarts = carts.where((c) => c.id != cartId).toList();
      _syncCarts(newCarts);
      if (newCarts.isEmpty) {
        appliedPromo.value = '';
        discountAmount.value = 0.0;
        isFreeShipping.value = false;
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
      carts.clear();
      cartItems.clear();
      expandedCartIds.clear();
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

  /// Combined subtotal across every vendor cart.
  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  /// Combined delivery fee across every vendor cart. Each vendor ships
  /// separately, so normally this sums each vendor's own fee — unless a
  /// free-shipping promo is active or the combined order clears the
  /// free-delivery threshold.
  double get deliveryFee {
    if (subtotal <= 0) return 0.0;
    if (isFreeShipping.value || subtotal >= 299.0) return 0.0;
    if (carts.isNotEmpty) {
      return carts.fold(0.0, (sum, c) => sum + c.deliveryFee);
    }
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
      (item) => item.id == id || item.cartKey == id || item.productId == id,
    );
    return item?.quantity ?? 0;
  }

  void _showErrorSnackbar(String message) {
    SnackbarHelper.showGetError(message);
  }
}
