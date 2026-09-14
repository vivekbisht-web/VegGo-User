//
import 'package:get/get.dart';

import 'package:vegon_user/features/home/controllers/location_controller.dart';
import '../models/product_details_model.dart';
import '../services/product_repository.dart';
import 'wishlist_controller.dart';

class ProductDetailsController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  final Rx<ProductDetailsData?> productDetails = Rx<ProductDetailsData?>(null);
  final RxBool isProductDetailsLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt quantity = 1.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxInt selectedImageIndex = 0.obs;
  final RxList<ProductDetailsData> relatedProducts = <ProductDetailsData>[].obs;
  final RxBool isRelatedLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetState();

    // Automatically fetch details if opened via routing with product data
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final String productId = args['id']?.toString() ?? '';
      if (productId.isNotEmpty) {
        fetchProductDetails(productId);
      }
    }
  }

  void resetState() {
    quantity.value = 1;
    isFavorite.value = false;
    isDescriptionExpanded.value = false;
    selectedImageIndex.value = 0;
    productDetails.value = null;
    relatedProducts.clear();
    isProductDetailsLoading.value = false;
    isRelatedLoading.value = false;
    errorMessage.value = '';
  }

  Future<void> fetchProductDetails(
    String catalogProductId, {
    double? latitude,
    double? longitude,
  }) async {
    if (catalogProductId.trim().isEmpty) return;

    isProductDetailsLoading.value = true;
    errorMessage.value = '';

    double? lat = latitude;
    double? lng = longitude;
    if ((lat == null || lng == null) &&
        Get.isRegistered<LocationController>()) {
      final locController = Get.find<LocationController>();
      lat ??= locController.latitude;
      lng ??= locController.longitude;
    }

    try {
      final response = await _productRepository.fetchProductDetails(
        catalogProductId,
        latitude: lat,
        longitude: lng,
      );

      if (response.success && response.data != null) {
        productDetails.value = response.data;
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isProductDetailsLoading.value = false;
    }

    fetchRelatedProducts(catalogProductId, latitude: lat, longitude: lng);
  }

  Future<void> fetchRelatedProducts(
    String catalogProductId, {
    double? latitude,
    double? longitude,
  }) async {
    if (catalogProductId.trim().isEmpty) return;

    isRelatedLoading.value = true;
    try {
      final response = await _productRepository.fetchRelatedProducts(
        catalogProductId,
        latitude: latitude,
        longitude: longitude,
      );
      if (response.success && response.data.isNotEmpty) {
        relatedProducts.assignAll(response.data);
      }
    } catch (_) {
    } finally {
      isRelatedLoading.value = false;
    }
  }

  void incrementQuantity({int? maxStock, int? maxPerUser}) {
    final limit = (maxStock != null && maxPerUser != null)
        ? (maxStock < maxPerUser ? maxStock : maxPerUser)
        : (maxStock ?? maxPerUser);

    if (limit != null && quantity.value >= limit) {
      return;
    }
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void toggleFavorite() {
    final details = productDetails.value;
    if (details != null && details.id.isNotEmpty) {
      WishlistController.to.toggleWishlist(details.id, product: details);
    }
  }

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
}
