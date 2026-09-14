//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';

import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';
import 'package:vegon_user/features/category/screens/category_screen.dart';

class HomeNearbyStores extends StatelessWidget {
  const HomeNearbyStores({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    final cardRadius = BorderRadius.circular(AppSpacing.radius16);

    return SizedBox(
      height: AppSpacing.storeCardHeight,
      child: Obx(() {
        final fetchedShops = controller.shops;

        if (controller.isShopsLoading.value && fetchedShops.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: fetchedShops.length,
          separatorBuilder: (_, _) => AppSpacing.w10,
          itemBuilder: (context, index) {
            final shop = fetchedShops[index];
            final String name = shop.name;
            final String distance =
                '${shop.distanceInKm.toStringAsFixed(1)} km';

            final rating = AppStrings.rating4_3;
            final deliveryTime = AppStrings.mins20;
            final deliveryBadge = AppStrings.freeDelivery;
            final imageUrl = shop.image ?? '';

            final textTheme = Theme.of(context).textTheme;

            return SizedBox(
              width: AppSpacing.storeCardWidth,
              child: Material(
                color: AppColors.surface,
                borderRadius: cardRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.to(() => const CategoryScreen()),
                  borderRadius: cardRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: cardRadius,
                      border: Border.all(
                        color: AppColors.chipBorder,
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.overlayLight.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 82,
                          width: double.infinity,
                          child: CustomImageView(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: AppSpacing.paddingFromLTRB(8, 6, 8, 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              AppSpacing.h4,
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      distance,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  AppSpacing.w4,
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.ratingStar,
                                    size: 13,
                                  ),
                                  AppSpacing.w2,
                                  Text(
                                    rating,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h4,
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.primary,
                                    size: 12,
                                  ),
                                  AppSpacing.w4,
                                  Expanded(
                                    child: Text(
                                      deliveryTime,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h4,
                              Container(
                                padding: AppSpacing.paddingSymmetric(
                                  horizontal: AppSpacing.radius6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bannerPastelGreen,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radius4,
                                  ),
                                ),
                                child: Text(
                                  deliveryBadge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.bannerDarkGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
