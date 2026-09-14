//
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';

class CategorySidebarShimmer extends StatelessWidget {
  const CategorySidebarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.chipBackground,
      child: ListView.builder(
        padding: AppSpacing.paddingVertical8,
        itemCount: 8,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: AppSpacing.paddingFromLTRB(8, 6, 8, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.h6,
                Container(
                  width: 48,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radius4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategorySubcategoriesShimmer extends StatelessWidget {
  const CategorySubcategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.chipBackground,
      child: Container(
        height: 34,
        margin: AppSpacing.paddingFromLTRB(8, 0, 8, 4),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => AppSpacing.w6,
          itemBuilder: (context, index) {
            return Container(
              width: 70,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius16),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryProductsShimmerGrid extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CategoryProductsShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.chipBackground,
      child: GridView.builder(
        padding: AppSpacing.paddingFromLTRB(8, 4, 8, 20),
        shrinkWrap: shrinkWrap,
        physics:
            physics ??
            (shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics()),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius12),
              border: Border.all(color: AppColors.categoryBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 48,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radius12),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 52,
                  child: Padding(
                    padding: AppSpacing.paddingAll8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radius4,
                                ),
                              ),
                            ),
                            AppSpacing.h4,
                            Container(
                              width: 60,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radius4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 45,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radius4,
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radius6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
