//
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/features/category/models/category_model.dart';
import 'package:vegon_user/features/category/models/category_product_model.dart';
import 'package:vegon_user/features/category/services/category_repository.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';

class HomeSearchController extends GetxController {
  final CategoryRepository _repository = CategoryRepository();

  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<CategoryProductItem> searchResults = <CategoryProductItem>[].obs;
  final RxList<CategoryItem> searchCategories = <CategoryItem>[].obs;

  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 0.0.obs;

  Timer? _debounceTimer;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  void onSearchQueryChanged(String query) {
    final trimmed = query.trim();
    searchQuery.value = trimmed;

    _debounceTimer?.cancel();

    if (trimmed.isEmpty) {
      searchResults.clear();
      searchCategories.clear();
      isSearching.value = false;
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      executeLiveSearch(trimmed);
    });
  }

  Future<void> executeLiveSearch(String query) async {
    if (query.isEmpty) return;

    isSearching.value = true;

    double? lat;
    double? lng;
    if (Get.isRegistered<LocationController>()) {
      final locController = Get.find<LocationController>();
      lat = locController.latitude;
      lng = locController.longitude;
    }

    try {
      final results = await Future.wait([
        _repository.fetchProducts(
          query: query,
          minPrice: minPrice.value > 0 ? minPrice.value : null,
          maxPrice: maxPrice.value > 0 ? maxPrice.value : null,
          latitude: lat,
          longitude: lng,
          size: 20,
        ),

        _repository.fetchCategories(search: query, size: 10),
      ]);

      final productsResponse = results[0] as ProductsPageResponse;
      final categoriesResponse = results[1] as CategoriesPageResponse;

      if (searchQuery.value == query) {
        if (productsResponse.success) {
          searchResults.assignAll(productsResponse.content);
        } else {
          searchResults.clear();
        }

        if (categoriesResponse.success) {
          searchCategories.assignAll(categoriesResponse.content);
        } else {
          searchCategories.clear();
        }
      }
    } catch (_) {
    } finally {
      if (searchQuery.value == query) {
        isSearching.value = false;
      }
    }
  }

  void applyPriceFilter({double? min, double? max}) {
    minPrice.value = min ?? 0.0;
    maxPrice.value = max ?? 0.0;
    if (searchQuery.value.isNotEmpty) {
      executeLiveSearch(searchQuery.value);
    }
  }

  void clearPriceFilter() {
    minPrice.value = 0.0;
    maxPrice.value = 0.0;
    if (searchQuery.value.isNotEmpty) {
      executeLiveSearch(searchQuery.value);
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.clear();
    searchCategories.clear();
    isSearching.value = false;
    minPrice.value = 0.0;
    maxPrice.value = 0.0;
  }
}
