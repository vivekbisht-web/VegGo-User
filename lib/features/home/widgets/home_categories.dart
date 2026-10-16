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

      final int columns = MediaQuery.sizeOf(context).width >= 600 ? 6 : 4;
      final int maxCategories = columns == 6
          ? 11
          : (fetchedCategories.length <= 4)
          ? 3
          : 7;
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
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
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
              tint: _tints[index % _tints.length],
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
            tint: _tints[index % _tints.length],
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

const List<Color> _tints = [
  Color(0xFFE8F5E9),
  Color(0xFFF1F8E4),
  Color(0xFFE6F2FB),
  Color(0xFFFFF1DB),
  Color(0xFFF3F6EC),
  Color(0xFFFFF3E0),
  Color(0xFFFFF6D9),
  Color(0xFFFCE8EC),
];

class _CategoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isMore;
  final Color tint;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.imageUrl,
    required this.isMore,
    required this.tint,
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
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.categoryCardImageHeight,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: imageRadius,
                    color: tint,
                  ),
                  child: ClipRRect(
                    borderRadius: imageRadius,
                    child: isMore
                        ? const _MoreCategoryIcon()
                        : Padding(
                            padding: const EdgeInsets.all(6),
                            child: CustomImageView(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
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
                height: 1.1,
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
