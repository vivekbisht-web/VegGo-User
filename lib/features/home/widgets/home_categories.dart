import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';

import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/category/controller/category_controller.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final categoryController = Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController());
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      final fetchedCategories = homeController.categories;

      if (homeController.isCategoriesLoading.value &&
          fetchedCategories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final int maxCategories = (fetchedCategories.length <= 4) ? 3 : 7;
      final int categoryCount = fetchedCategories.length.clamp(
        0,
        maxCategories,
      );
      final int totalCount = categoryCount + 1;

      return GridView.builder(
        shrinkWrap: true,
        padding: AppSpacing.paddingZero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: AppSpacing.categoryGridCrossAxisSpacing,
          mainAxisSpacing: AppSpacing.categoryGridMainAxisSpacing,
          childAspectRatio: AppSpacing.categoryCardAspectRatio,
        ),
        itemBuilder: (context, index) {
          final bool isLast = (index == totalCount - 1);

          if (isLast) {
            return _CategoryCard(
              name: AppStrings.more,
              imageUrl: '',
              isMore: true,
              onTap: () {
                dashboardController.changeTabIndex(1);
              },
            );
          }

          final category = fetchedCategories[index];
          final String name = category.name;
          final String imageUrl = category.image ?? '';

          return _CategoryCard(
            name: name,
            imageUrl: imageUrl,
            isMore: false,
            onTap: () {
              categoryController.selectCategoryById(category.id);
              dashboardController.changeTabIndex(1);
            },
          );
        },
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isMore;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.imageUrl,
    required this.isMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageRadius = BorderRadius.circular(AppSpacing.radius14);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: imageRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.categoryCardImageHeight,
              height: AppSpacing.categoryCardImageHeight,
              decoration: BoxDecoration(
                borderRadius: imageRadius,
                color: AppColors.chipBackground,
              ),
              child: ClipRRect(
                borderRadius: imageRadius,
                child: isMore
                    ? const _MoreCategoryIcon()
                    : CustomImageView(
                        imageUrl: imageUrl,
                        width: AppSpacing.categoryCardImageHeight,
                        height: AppSpacing.categoryCardImageHeight,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            AppSpacing.h6,
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: AppSpacing.categoryFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoryIcon extends StatelessWidget {
  const _MoreCategoryIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppSpacing.categoryMoreSquareSize,
                height: AppSpacing.categoryMoreSquareSize,
                decoration: BoxDecoration(
                  color: AppColors.moreIconSlateLight,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.categoryMoreSquareRadius,
                  ),
                ),
              ),
              AppSpacing.w4,
              Container(
                width: AppSpacing.categoryMoreSquareSize,
                height: AppSpacing.categoryMoreSquareSize,
                decoration: BoxDecoration(
                  color: AppColors.moreIconSlateDark,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.categoryMoreSquareRadius,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h4,
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppSpacing.categoryMoreSquareSize,
                height: AppSpacing.categoryMoreSquareSize,
                decoration: BoxDecoration(
                  color: AppColors.moreIconLavender,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.categoryMoreSquareRadius,
                  ),
                ),
              ),
              AppSpacing.w4,
              Transform.rotate(
                angle: AppSpacing.moreIconRotationAngle,
                child: Container(
                  width: AppSpacing.categoryMoreSquareSize,
                  height: AppSpacing.categoryMoreSquareSize,
                  decoration: BoxDecoration(
                    color: AppColors.moreIconGreen,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.categoryMoreSquareRadius,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
