//
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/home/controllers/location_controller.dart';
import 'package:vegon_user/features/product/controllers/wishlist_controller.dart';
import '../models/category_model.dart';
import '../models/category_product_model.dart';
import '../models/subcategory_model.dart';
import '../services/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository = CategoryRepository();

  final RxList<CategoryItem> categories = <CategoryItem>[].obs;
  final RxList<SubcategoryItem> subcategories = <SubcategoryItem>[].obs;
  final RxList<CategoryProductItem> products = <CategoryProductItem>[].obs;

  final RxBool isCategoriesLoading = false.obs;
  final RxBool isMoreCategoriesLoading = false.obs;
  final RxBool hasMoreCategories = false.obs;
  final RxInt categoriesPage = 0.obs;
  final RxBool isSubcategoriesLoading = false.obs;
  final RxBool isProductsLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt selectedCategoryIndex = 0.obs;
  final RxString selectedSubcategoryId = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSortOption = AppStrings.sortDefault.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    fetchCategories();
  }

  Future<void> fetchCategories({
    int? initialIndex,
    String? targetCategoryId,
  }) async {
    isCategoriesLoading.value = true;
    errorMessage.value = '';
    categoriesPage.value = 0;

    try {
      final response = await _repository.fetchCategories(page: 0, size: 20);
      if (response.success && response.content.isNotEmpty) {
        categories.assignAll(response.content);
        hasMoreCategories.value = response.page < response.totalPages - 1;

        int targetIndex = 0;
        if (targetCategoryId != null && targetCategoryId.isNotEmpty) {
          final foundIdx = categories.indexWhere(
            (c) => c.id == targetCategoryId,
          );
          if (foundIdx != -1) {
            targetIndex = foundIdx;
          }
        } else {
          final currentIdx = initialIndex ?? selectedCategoryIndex.value;
          targetIndex = currentIdx.clamp(0, categories.length - 1);
        }

        selectedCategoryIndex.value = targetIndex;
        await onCategoryChanged();
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : AppStrings.failedToLoadCategories;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> loadMoreCategories() async {
    if (isMoreCategoriesLoading.value || !hasMoreCategories.value) return;
    isMoreCategoriesLoading.value = true;
    try {
      final nextPage = categoriesPage.value + 1;
      final response = await _repository.fetchCategories(
        page: nextPage,
        size: 20,
      );
      if (response.success && response.content.isNotEmpty) {
        categories.addAll(response.content);
        categoriesPage.value = response.page;
        hasMoreCategories.value = response.page < response.totalPages - 1;
      } else {
        hasMoreCategories.value = false;
      }
    } catch (_) {
      hasMoreCategories.value = false;
    } finally {
      isMoreCategoriesLoading.value = false;
    }
  }

  /// Navigate to a category by its server ID — safe for cross-list navigation
  Future<void> selectCategoryById(
    String categoryId, {
    CategoryItem? fallbackCategory,
  }) async {
    searchQuery.value = '';

    if (categories.isEmpty) {
      await fetchCategories(targetCategoryId: categoryId);
      if (categories.any((c) => c.id == categoryId)) {
        return;
      }
    }

    int idx = categories.indexWhere((c) => c.id == categoryId);
    if (idx == -1 && fallbackCategory != null) {
      categories.add(fallbackCategory);
      idx = categories.length - 1;
    }

    if (idx != -1) {
      selectedCategoryIndex.value = idx;
      selectedSubcategoryId.value = '';
      await onCategoryChanged();
    }
  }

  void selectCategory(int index) {
    if (index >= 0 && index < categories.length) {
      if (selectedCategoryIndex.value == index && products.isNotEmpty) {
        return;
      }
      selectedCategoryIndex.value = index;
      selectedSubcategoryId.value = '';
      onCategoryChanged();
    }
  }

  Future<void> onCategoryChanged() async {
    if (categories.isEmpty) return;
    final currentCategory = categories[selectedCategoryIndex.value];
    selectedSubcategoryId.value = '';
    subcategories.clear();
    products.clear();

    await Future.wait([
      fetchSubcategories(currentCategory.id),
      fetchProducts(categoryId: currentCategory.id),
    ]);
  }

  Future<void> fetchSubcategories(String categoryId) async {
    isSubcategoriesLoading.value = true;
    try {
      final response = await _repository.fetchSubcategories(categoryId);
      if (response.success && isCurrentCategory(categoryId)) {
        subcategories.assignAll(response.content);
      }
    } catch (_) {
    } finally {
      isSubcategoriesLoading.value = false;
    }
  }

  void selectSubcategory(String subcategoryId) {
    if (selectedSubcategoryId.value == subcategoryId) {
      selectedSubcategoryId.value = '';
    } else {
      selectedSubcategoryId.value = subcategoryId;
    }

    if (categories.isNotEmpty) {
      final currentCat = categories[selectedCategoryIndex.value];
      fetchProducts(
        categoryId: currentCat.id,
        subcategoryId: selectedSubcategoryId.value.isNotEmpty
            ? selectedSubcategoryId.value
            : null,
      );
    }
  }

  Future<void> fetchProducts({
    required String categoryId,
    String? subcategoryId,
  }) async {
    isProductsLoading.value = true;

    double? lat;
    double? lng;
    if (Get.isRegistered<LocationController>()) {
      final locController = Get.find<LocationController>();
      lat = locController.latitude;
      lng = locController.longitude;
    }

    try {
      final response = await _repository.fetchProducts(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        latitude: lat,
        longitude: lng,
        minPrice: minPrice.value > 0 ? minPrice.value : null,
        maxPrice: maxPrice.value > 0 ? maxPrice.value : null,
      );

      if (response.success && isCurrentCategory(categoryId)) {
        final activeSub = selectedSubcategoryId.value.isNotEmpty
            ? selectedSubcategoryId.value
            : null;
        if (activeSub == subcategoryId) {
          products.assignAll(response.content);
        }
      }
    } catch (_) {
    } finally {
      isProductsLoading.value = false;
    }
  }

  bool isCurrentCategory(String categoryId) {
    if (selectedCategoryIndex.value < categories.length) {
      return categories[selectedCategoryIndex.value].id == categoryId;
    }
    return false;
  }

  void applyPriceFilter({double? min, double? max}) {
    minPrice.value = min ?? 0.0;
    maxPrice.value = max ?? 0.0;
    if (categories.isNotEmpty) {
      final currentCat = categories[selectedCategoryIndex.value];
      fetchProducts(
        categoryId: currentCat.id,
        subcategoryId: selectedSubcategoryId.value.isNotEmpty
            ? selectedSubcategoryId.value
            : null,
      );
    }
  }

  void clearPriceFilter() {
    minPrice.value = 0.0;
    maxPrice.value = 0.0;
    if (categories.isNotEmpty) {
      final currentCat = categories[selectedCategoryIndex.value];
      fetchProducts(
        categoryId: currentCat.id,
        subcategoryId: selectedSubcategoryId.value.isNotEmpty
            ? selectedSubcategoryId.value
            : null,
      );
    }
  }

  List<CategoryProductItem> get currentProducts {
    final query = searchQuery.value.trim().toLowerCase();
    List<CategoryProductItem> filtered = List<CategoryProductItem>.from(
      products,
    );

    if (query.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = p.name.toLowerCase();
        final desc = p.description.toLowerCase();
        final cat = p.category.toLowerCase();
        return name.contains(query) ||
            desc.contains(query) ||
            cat.contains(query);
      }).toList();
    }

    // Client-side price filter (secondary guard)
    if (minPrice.value > 0 || maxPrice.value > 0) {
      filtered = filtered.where((p) {
        final price = p.price;
        if (minPrice.value > 0 && price < minPrice.value) return false;
        if (maxPrice.value > 0 && price > maxPrice.value) return false;
        return true;
      }).toList();
    }

    if (selectedSortOption.value == AppStrings.sortPriceLowToHigh) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSortOption.value == AppStrings.sortPriceHighToLow) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (selectedSortOption.value == AppStrings.sortByPopular ||
        selectedSortOption.value == AppStrings.bestSeller) {
      filtered.sort(
        (a, b) => (b.bestSeller ? 1 : 0).compareTo(a.bestSeller ? 1 : 0),
      );
    }

    return filtered;
  }

  void setSortOption(String option) {
    selectedSortOption.value = option;
    products.refresh();
  }

  String get currentCategoryName {
    if (selectedCategoryIndex.value < categories.length) {
      return categories[selectedCategoryIndex.value].name;
    }
    return '';
  }

  CategoryItem? get currentCategory {
    if (selectedCategoryIndex.value < categories.length) {
      return categories[selectedCategoryIndex.value];
    }
    return null;
  }

  void toggleWishlist(String id) {
    WishlistController.to.toggleWishlist(id);
  }

  bool isWishlisted(String id) {
    return WishlistController.to.isWishlisted(id);
  }

  Future<void> refreshAll() async {
    final currentTargetId = categories.isNotEmpty &&
            selectedCategoryIndex.value < categories.length
        ? categories[selectedCategoryIndex.value].id
        : null;
    await fetchCategories(targetCategoryId: currentTargetId);
  }
}
