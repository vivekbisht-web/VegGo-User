//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/category/controller/category_controller.dart';
import 'package:vegon_user/features/category/widgets/category_product_card.dart';
import 'package:vegon_user/features/category/widgets/category_shimmer_loading.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import '../controllers/home_search_controller.dart';

class HomeLiveSearchResults extends StatelessWidget {
  const HomeLiveSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.find<HomeSearchController>();

    return Obx(() {
      final query = searchController.searchQuery.value;
      final isSearching = searchController.isSearching.value;
      final products = searchController.searchResults;
      final categories = searchController.searchCategories;

      if (isSearching && products.isEmpty) {
        return const Padding(
          padding: AppSpacing.paddingHorizontal16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryProductsShimmerGrid(itemCount: 4, shrinkWrap: true),
            ],
          ),
        );
      }

      if (products.isEmpty && categories.isEmpty && !isSearching) {
        return Padding(
          padding: AppSpacing.paddingAll32,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.h12,
                Text(
                  '${AppStrings.noProductsFound} ("$query")',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: AppSpacing.paddingHorizontal16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceFilterChips(context, searchController),
            AppSpacing.h12,

            if (categories.isNotEmpty) ...[
              Text(
                AppStrings.matchingCategories,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.h8,
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => AppSpacing.w8,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        searchController.clearSearch();

                        final catCtrl = Get.isRegistered<CategoryController>()
                            ? Get.find<CategoryController>()
                            : Get.put(CategoryController());

                        catCtrl.selectCategoryById(
                          cat.id,
                          fallbackCategory: cat,
                        );

                        if (Get.isRegistered<DashboardController>()) {
                          Get.find<DashboardController>().changeTabIndex(1);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radius20),
                      child: Container(
                        padding: AppSpacing.paddingFromLTRB(8, 4, 12, 4),
                        decoration: BoxDecoration(
                          color: AppColors.mintHeader,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius20,
                          ),
                          border: Border.all(
                            color: AppColors.mintBadge.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cat.iconUrl.isNotEmpty)
                              ClipOval(
                                child: CustomImageView(
                                  imageUrl: cat.iconUrl,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            AppSpacing.w6,
                            Text(
                              cat.name,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.h16,
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.searchResultsTitle} (${products.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isSearching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            AppSpacing.h10,

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return CategoryProductCard(product: products[index]);
              },
            ),
            AppSpacing.h24,
          ],
        ),
      );
    });
  }

  Widget _buildPriceFilterChips(
    BuildContext context,
    HomeSearchController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: AppStrings.all,
            isSelected:
                controller.minPrice.value == 0 &&
                controller.maxPrice.value == 0,
            onTap: () => controller.clearPriceFilter(),
          ),
          AppSpacing.w6,
          _buildFilterChip(
            context,
            label: AppStrings.underRupees30,
            isSelected:
                controller.minPrice.value == 0 &&
                controller.maxPrice.value == 30,
            onTap: () => controller.applyPriceFilter(min: 0, max: 30),
          ),
          AppSpacing.w6,
          _buildFilterChip(
            context,
            label: AppStrings.rupees30To60,
            isSelected:
                controller.minPrice.value == 30 &&
                controller.maxPrice.value == 60,
            onTap: () => controller.applyPriceFilter(min: 30, max: 60),
          ),
          AppSpacing.w6,
          _buildFilterChip(
            context,
            label: AppStrings.aboveRupees60,
            isSelected:
                controller.minPrice.value == 60 &&
                controller.maxPrice.value == 0,
            onTap: () => controller.applyPriceFilter(min: 60, max: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: AppSpacing.paddingSymmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.chipBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
