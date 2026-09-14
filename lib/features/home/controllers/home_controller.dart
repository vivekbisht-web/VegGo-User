import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vegon_user/features/category/models/category_product_model.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';
import 'package:vegon_user/features/home/models/banner_models.dart';
import 'package:vegon_user/features/home/models/category_models.dart';
import 'package:vegon_user/features/home/models/shop_models.dart';
import 'package:vegon_user/features/home/services/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository = HomeRepository();

  final RxList<BannerDataModel> banners = <BannerDataModel>[].obs;
  final RxList<CategoryDataModel> categories = <CategoryDataModel>[].obs;
  final RxList<ShopDataModel> shops = <ShopDataModel>[].obs;
  final RxList<CategoryProductItem> bestDeals = <CategoryProductItem>[].obs;
  final RxList<CategoryProductItem> freshProduce = <CategoryProductItem>[].obs;
  final RxList<CategoryProductItem> allProducts = <CategoryProductItem>[].obs;

  final RxBool isBannersLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isShopsLoading = false.obs;
  final RxBool isDealsLoading = false.obs;
  final RxBool isProductsLoading = false.obs;
  RxBool get isLoading => isProductsLoading;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllHomeData();
  }

  Future<void> loadAllHomeData() async {
    double? lat;
    double? lng;
    if (Get.isRegistered<LocationController>()) {
      final locCtrl = Get.find<LocationController>();
      lat = locCtrl.latitude;
      lng = locCtrl.longitude;
    }

    await Future.wait([
      fetchBanners(),
      fetchCategories(),
      fetchNearbyShops(latitude: lat, longitude: lng),
      fetchDailyDeals(latitude: lat, longitude: lng),
      fetchAllProducts(latitude: lat, longitude: lng),
    ]);
  }

  Future<void> fetchBanners() async {
    isBannersLoading.value = true;
    try {
      final response = await _repository.fetchBanners();
      if (response.success) {
        banners.assignAll(response.banners);
      }
    } catch (e) {
      debugPrint("Error fetching banners: $e");
    } finally {
      isBannersLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    try {
      final response = await _repository.fetchCategories();
      if (response.success) {
        categories.assignAll(response.categories);
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchNearbyShops({double? latitude, double? longitude}) async {
    isShopsLoading.value = true;

    double? lat = latitude;
    double? lng = longitude;

    if (lat == null || lng == null) {
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        lat ??= locCtrl.latitude;
        lng ??= locCtrl.longitude;
      }
    }

    try {
      final response = await _repository.fetchNearbyShops(
        latitude: lat,
        longitude: lng,
      );
      if (response.success) {
        shops.assignAll(response.shops);
      }
    } catch (e) {
      debugPrint("Error fetching shops: $e");
    } finally {
      isShopsLoading.value = false;
    }
  }

  Future<void> fetchDailyDeals({double? latitude, double? longitude}) async {
    isDealsLoading.value = true;
    double? lat = latitude;
    double? lng = longitude;

    if (lat == null || lng == null) {
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        lat ??= locCtrl.latitude;
        lng ??= locCtrl.longitude;
      }
    }

    try {
      final deals = await _repository.fetchDailyDeals(
        latitude: lat,
        longitude: lng,
      );
      if (deals.isNotEmpty) {
        bestDeals.assignAll(deals);
      } else if (allProducts.isNotEmpty && bestDeals.isEmpty) {
        final withDiscount = allProducts
            .where((p) => p.bestSeller || p.discountPercent > 0)
            .toList();
        bestDeals.assignAll(
          withDiscount.isNotEmpty ? withDiscount.take(6) : allProducts.take(6),
        );
      }
    } catch (e) {
      debugPrint("Error fetching daily deals: $e");
    } finally {
      isDealsLoading.value = false;
    }
  }

  Future<void> fetchAllProducts({double? latitude, double? longitude}) async {
    isProductsLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    double? lat = latitude;
    double? lng = longitude;

    if (lat == null || lng == null) {
      if (Get.isRegistered<LocationController>()) {
        final locCtrl = Get.find<LocationController>();
        lat ??= locCtrl.latitude;
        lng ??= locCtrl.longitude;
      }
    }

    try {
      final response = await _repository.fetchProducts(
        latitude: lat,
        longitude: lng,
        page: 0,
        size: 30,
      );

      if (response.success) {
        final products = response.content;
        allProducts.assignAll(products);

        if (bestDeals.isEmpty) {
          final withDiscount = products
              .where((p) => p.bestSeller || p.discountPercent > 0)
              .toList();
          bestDeals.assignAll(
            withDiscount.isNotEmpty ? withDiscount.take(6) : products.take(6),
          );
        }

        freshProduce.assignAll(
          products
              .where(
                (p) =>
                    p.category.toLowerCase().contains('veg') ||
                    p.category.toLowerCase().contains('produce') ||
                    p.category.toLowerCase().contains('fruit'),
              )
              .toList(),
        );
      } else {
        hasError.value = true;
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load products';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> refreshHome() async {
    await loadAllHomeData();
  }
}
