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
        if (allProducts.isNotEmpty) {
          _filterFreshProduce(allProducts);
        }
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
      final realDeals = deals
          .where((p) =>
              p.discountPercent > 0 ||
              (p.originalPrice != null && p.originalPrice! > p.price) ||
              p.bestSeller)
          .toList();

      if (realDeals.isNotEmpty) {
        realDeals.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        bestDeals.assignAll(realDeals.take(6));
      } else {
        _populateDealsFromProducts(allProducts);
      }
    } catch (e) {
      debugPrint("Error fetching daily deals: $e");
      _populateDealsFromProducts(allProducts);
    } finally {
      isDealsLoading.value = false;
    }
  }

  void _populateDealsFromProducts(List<CategoryProductItem> products) {
    if (products.isEmpty) {
      bestDeals.clear();
      return;
    }
    final withDiscount = products
        .where((p) =>
            p.discountPercent > 0 ||
            (p.originalPrice != null && p.originalPrice! > p.price) ||
            p.bestSeller)
        .toList();

    withDiscount.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));

    if (withDiscount.isNotEmpty) {
      bestDeals.assignAll(withDiscount.take(6));
    } else {
      bestDeals.clear();
    }
  }

  void _filterFreshProduce(List<CategoryProductItem> products) {
    if (products.isEmpty) {
      freshProduce.clear();
      return;
    }

    final vegCategoryNames = <String>{};
    final vegCategoryIds = <String>{};

    for (final cat in categories) {
      final name = cat.name.toLowerCase();
      if (name.contains('veg') && !name.contains('non-veg')) {
        vegCategoryNames.add(name);
        vegCategoryIds.add(cat.id.toLowerCase());
      }
    }

    final filtered = products.where((p) {
      final pCat = p.category.toLowerCase().trim();
      final pName = p.name.toLowerCase().trim();

      // Skip fruits explicitly
      if (pCat.contains('fruit') ||
          pName.contains('apple') ||
          pName.contains('banana') ||
          pName.contains('mango') ||
          pName.contains('orange')) {
        return false;
      }

      if (vegCategoryIds.contains(pCat) || vegCategoryNames.contains(pCat)) {
        return true;
      }

      if (pCat.contains('vegetable') || pCat.contains('veggie')) {
        return true;
      }

      if (pCat.contains('veg') && !pCat.contains('non-veg')) {
        return true;
      }

      const commonVegWords = [
        'potato', 'onion', 'tomato', 'carrot', 'cabbage', 'cauliflower',
        'spinach', 'broccoli', 'cucumber', 'capsicum', 'pepper', 'peas',
        'beans', 'garlic', 'ginger', 'chilli', 'chili', 'radish', 'beetroot',
        'gourd', 'brinjal', 'eggplant', 'lady finger', 'okra', 'coriander',
        'palak', 'methi', 'pudina', 'mushroom', 'corn', 'lettuce'
      ];
      for (final word in commonVegWords) {
        if (pName.contains(word)) return true;
      }

      return false;
    }).toList();

    if (filtered.isNotEmpty) {
      freshProduce.assignAll(filtered.take(4));
    } else {
      final dealIds = bestDeals.map((d) => d.id).toSet();
      final nonDealProducts =
          products.where((p) => !dealIds.contains(p.id)).toList();
      freshProduce.assignAll(
        (nonDealProducts.isNotEmpty ? nonDealProducts : products).take(4),
      );
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
          _populateDealsFromProducts(products);
        }

        _filterFreshProduce(products);
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
