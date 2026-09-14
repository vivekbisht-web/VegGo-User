import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/product/models/product_details_model.dart';
import 'package:vegon_user/features/product/services/wishlist_repository.dart';

class WishlistController extends GetxController {
  static WishlistController get to {
    if (Get.isRegistered<WishlistController>()) {
      return Get.find<WishlistController>();
    }
    return Get.put(WishlistController(), permanent: true);
  }

  final WishlistRepository _wishlistRepo = WishlistRepository();

  final RxSet<String> wishlistIds = <String>{}.obs;
  final RxList<ProductDetailsData> wishlistProducts = <ProductDetailsData>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  bool isWishlisted(String productId) {
    if (productId.isEmpty) return false;
    return wishlistIds.contains(productId);
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await _wishlistRepo.getWishlist();
      if (response != null && response.data != null) {
        wishlistProducts.assignAll(response.data!);
        wishlistIds.assignAll(
          response.data!
              .where((item) => item.id.isNotEmpty)
              .map((item) => item.id),
        );
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleWishlist(
    String productId, {
    ProductDetailsData? product,
    Map<String, dynamic>? productMap,
  }) async {
    if (productId.isEmpty) return;

    final wasWishlisted = wishlistIds.contains(productId);

    // Optimistic UI update
    if (wasWishlisted) {
      wishlistIds.remove(productId);
      wishlistProducts.removeWhere((item) => item.id == productId);
    } else {
      wishlistIds.add(productId);
      if (product != null) {
        if (!wishlistProducts.any((item) => item.id == productId)) {
          wishlistProducts.add(product);
        }
      } else if (productMap != null) {
        if (!wishlistProducts.any((item) => item.id == productId)) {
          wishlistProducts.add(ProductDetailsData.fromJson(productMap));
        }
      }
    }

    try {
      if (wasWishlisted) {
        final response = await _wishlistRepo.removeFromWishlist(productId);
        if (response == null || response.success != true) {
          // Revert rollback
          wishlistIds.add(productId);
          if (product != null &&
              !wishlistProducts.any((item) => item.id == productId)) {
            wishlistProducts.add(product);
          }
          Get.snackbar(
            AppStrings.error,
            response?.message ?? AppStrings.failedToUpdateWishlist,
            backgroundColor: AppColors.error,
            colorText: AppColors.surface,
          );
        } else {
          Get.snackbar(
            AppStrings.wishlist,
            AppStrings.removedFromWishlist,
            backgroundColor: AppColors.primary,
            colorText: AppColors.surface,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        final response = await _wishlistRepo.addToWishlist(productId);
        if (response == null || response.success != true) {
          // Revert rollback
          wishlistIds.remove(productId);
          wishlistProducts.removeWhere((item) => item.id == productId);
          Get.snackbar(
            AppStrings.error,
            response?.message ?? AppStrings.failedToUpdateWishlist,
            backgroundColor: AppColors.error,
            colorText: AppColors.surface,
          );
        } else {
          Get.snackbar(
            AppStrings.wishlist,
            AppStrings.addedToWishlist,
            backgroundColor: AppColors.primary,
            colorText: AppColors.surface,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      // Revert on exception
      if (wasWishlisted) {
        wishlistIds.add(productId);
        if (product != null &&
            !wishlistProducts.any((item) => item.id == productId)) {
          wishlistProducts.add(product);
        }
      } else {
        wishlistIds.remove(productId);
        wishlistProducts.removeWhere((item) => item.id == productId);
      }
      Get.snackbar(
        AppStrings.error,
        AppStrings.unexpectedError,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
    }
  }
}
