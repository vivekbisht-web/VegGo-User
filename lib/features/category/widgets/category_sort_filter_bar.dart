//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import '../controller/category_controller.dart';

import 'category_shimmer_loading.dart';

class CategorySortFilterBar extends StatelessWidget {
  const CategorySortFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingFromLTRB(10, 10, 10, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Text(
                        controller.currentCategoryName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.h2,
                    Obx(() {
                      final count = controller.currentProducts.length;
                      return Text(
                        '$count ${AppStrings.items}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Obx(() {
                final isFilterActive =
                    controller.minPrice.value > 0 ||
                    controller.maxPrice.value > 0;
                final isSortActive =
                    controller.selectedSortOption.value !=
                    AppStrings.sortDefault;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOutlineAction(
                      context,
                      icon: Icons.filter_alt_outlined,
                      label: AppStrings.filter,
                      isActive: isFilterActive,
                      onTap: () => _showFilterDialog(context, controller),
                    ),
                    AppSpacing.w6,
                    _buildOutlineAction(
                      context,
                      icon: Icons.swap_vert_rounded,
                      label: AppStrings.sort,
                      isActive: isSortActive,
                      onTap: () => _showSortDialog(context, controller),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),

        Obx(() {
          if (controller.isSubcategoriesLoading.value &&
              controller.subcategories.isEmpty) {
            return const CategorySubcategoriesShimmer();
          }

          if (controller.subcategories.isEmpty) {
            return const SizedBox.shrink();
          }

          final selectedSubId = controller.selectedSubcategoryId.value;

          return Container(
            height: 34,
            margin: AppSpacing.paddingFromLTRB(8, 0, 8, 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.subcategories.length + 1,
              separatorBuilder: (context, index) => AppSpacing.w6,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAllSelected = selectedSubId.isEmpty;
                  return _buildSubcategoryChip(
                    context,
                    label: AppStrings.all,
                    isSelected: isAllSelected,
                    onTap: () => controller.selectSubcategory(''),
                  );
                }

                final sub = controller.subcategories[index - 1];
                final isSelected = selectedSubId == sub.id;

                return _buildSubcategoryChip(
                  context,
                  label: sub.name,
                  isSelected: isSelected,
                  onTap: () => controller.selectSubcategory(sub.id),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubcategoryChip(
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
        padding: AppSpacing.paddingSymmetric(horizontal: 10, vertical: 4),
        alignment: Alignment.center,
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

  Widget _buildOutlineAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius16),
      child: Container(
        padding: AppSpacing.paddingSymmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.chipBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
            ),
            AppSpacing.w4,
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, CategoryController controller) {
    Get.bottomSheet(
      Material(
        color: AppColors.transparent,
        child: Container(
          padding: AppSpacing.paddingAll16,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radius20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.sortBy,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.h12,
              _buildSortOption(
                context,
                controller,
                label: AppStrings.sortDefault,
                value: AppStrings.sortDefault,
              ),
              _buildSortOption(
                context,
                controller,
                label: AppStrings.sortPriceLowToHigh,
                value: AppStrings.sortPriceLowToHigh,
              ),
              _buildSortOption(
                context,
                controller,
                label: AppStrings.sortPriceHighToLow,
                value: AppStrings.sortPriceHighToLow,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    CategoryController controller, {
    required String label,
    required String value,
  }) {
    return Obx(() {
      final isSelected = controller.selectedSortOption.value == value;
      return ListTile(
        dense: true,
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20,
              )
            : null,
        onTap: () {
          controller.selectedSortOption.value = value;
          Get.back();
        },
      );
    });
  }

  void _showFilterDialog(BuildContext context, CategoryController controller) {
    Get.bottomSheet(
      Material(
        color: AppColors.transparent,
        child: Container(
          padding: AppSpacing.paddingAll16,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radius20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.filter,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearPriceFilter();
                      Get.back();
                    },
                    child: Text(
                      AppStrings.clearFilter,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h8,
              Text(
                AppStrings.priceRange,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.h10,
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterSheetChip(
                      context,
                      label: AppStrings.all,
                      isSelected:
                          controller.minPrice.value == 0 &&
                          controller.maxPrice.value == 0,
                      onTap: () {
                        controller.clearPriceFilter();
                        Get.back();
                      },
                    ),
                    _buildFilterSheetChip(
                      context,
                      label: AppStrings.underRupees30,
                      isSelected:
                          controller.minPrice.value == 0 &&
                          controller.maxPrice.value == 30,
                      onTap: () {
                        controller.applyPriceFilter(min: 0, max: 30);
                        Get.back();
                      },
                    ),
                    _buildFilterSheetChip(
                      context,
                      label: AppStrings.rupees30To60,
                      isSelected:
                          controller.minPrice.value == 30 &&
                          controller.maxPrice.value == 60,
                      onTap: () {
                        controller.applyPriceFilter(min: 30, max: 60);
                        Get.back();
                      },
                    ),
                    _buildFilterSheetChip(
                      context,
                      label: AppStrings.aboveRupees60,
                      isSelected:
                          controller.minPrice.value == 60 &&
                          controller.maxPrice.value == 0,
                      onTap: () {
                        controller.applyPriceFilter(min: 60, max: 0);
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.h16,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSheetChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius16),
      child: Container(
        padding: AppSpacing.paddingSymmetric(horizontal: 12, vertical: 6),
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
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
