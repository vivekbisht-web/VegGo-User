//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import '../controller/category_controller.dart';

import 'category_shimmer_loading.dart';

class CategorySidebar extends StatelessWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();

    return Container(
      width: AppSpacing.screenWidth * 0.25,
      color: AppColors.background,
      child: Obx(() {
        if (controller.isCategoriesLoading.value &&
            controller.categories.isEmpty) {
          return const CategorySidebarShimmer();
        }

        if (controller.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedIdx = controller.selectedCategoryIndex.value;

        return ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: AppSpacing.paddingVertical8,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = selectedIdx == index;

            return InkWell(
              onTap: () => controller.selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: AppSpacing.paddingFromLTRB(4, 2, 4, 4),
                padding: AppSpacing.paddingSymmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.sidebarSelected
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: AppSpacing.paddingAll4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: ClipOval(
                        child: CustomImageView(
                          imageUrl: category.iconUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
