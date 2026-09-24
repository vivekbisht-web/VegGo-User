import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/features/home/controllers/home_search_controller.dart';
import 'package:vegon_user/features/home/widgets/home_header_sliver.dart';
import 'package:vegon_user/features/home/widgets/home_live_search_results.dart';
import '../controller/category_controller.dart';
import '../widgets/category_product_card.dart';
import '../widgets/category_shimmer_loading.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/category_sort_filter_bar.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController());
    final HomeSearchController searchController =
        Get.isRegistered<HomeSearchController>()
        ? Get.find<HomeSearchController>()
        : Get.put(HomeSearchController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Column(
              children: [
                const HomeHeader(showBackButton: true),

                Expanded(
                  child: Obx(() {
                    if (searchController.searchQuery.value.isNotEmpty) {
                      return const SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: HomeLiveSearchResults(),
                      );
                    }

                    return const _CategoryScreenContent();
                  }),
                ),
              ],
            ),

            // const AiAssistantFab(bottom: 16, right: 12),
          ],
        ),
      ),
    );
  }
}

class _CategoryScreenContent extends StatelessWidget {
  const _CategoryScreenContent();

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.categories.isEmpty) {
        controller.fetchCategories();
      }
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CategorySidebar(),

        Expanded(
          child: Column(
            children: [
              const CategorySortFilterBar(),
              Expanded(child: _buildProductsArea(context, controller)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsArea(
    BuildContext context,
    CategoryController controller,
  ) {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty &&
          controller.categories.isEmpty &&
          !controller.isCategoriesLoading.value) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshAll(),
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: AppSpacing.screenHeight * 0.5,
                child: Center(
                  child: Padding(
                    padding: AppSpacing.paddingAll16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 44,
                        ),
                        AppSpacing.h12,
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        AppSpacing.h16,
                        CustomButton(
                          text: AppStrings.retry,
                          onPressed: () => controller.fetchCategories(),
                          backgroundColor: AppColors.primary,
                          width: 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if ((controller.isProductsLoading.value ||
              controller.isCategoriesLoading.value) &&
          controller.products.isEmpty) {
        return const CategoryProductsShimmerGrid();
      }

      final products = controller.currentProducts;
      if (products.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshAll(),
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              AppSpacing.h48,
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    AppSpacing.h8,
                    Text(
                      AppStrings.noProductsFound,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        color: AppColors.primary,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: AppSpacing.paddingFromLTRB(8, 4, 8, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return CategoryProductCard(
              key: ValueKey('${p.id}_${controller.selectedSortOption.value}'),
              product: p,
            );
          },
        ),
      );
    });
  }
}
