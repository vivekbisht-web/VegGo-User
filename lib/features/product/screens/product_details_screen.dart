import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/product_details_controller.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_combo_section.dart';
import '../widgets/product_hero_section.dart';
import '../widgets/product_offers_section.dart';
import '../widgets/product_related_section.dart';
import '../widgets/product_top_header.dart';
import '../widgets/product_trust_banner.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? productData;

  const ProductDetailsScreen({super.key, this.productData});

  @override
  Widget build(BuildContext context) {
    final ProductDetailsController controller =
        Get.isRegistered<ProductDetailsController>()
            ? Get.find<ProductDetailsController>()
            : Get.put(ProductDetailsController());
    
    final passedData = productData ?? (Get.arguments as Map<String, dynamic>? ?? {});
    final Map<String, dynamic> mergedProductData = Map<String, dynamic>.from(passedData);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ProductTopHeader(),
            AppSpacing.h12,

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  final id = mergedProductData['id']?.toString() ?? '';
                  if (id.isNotEmpty) {
                    await controller.fetchProductDetails(id);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductHeroSection(productData: mergedProductData),
                    AppSpacing.h16,

                    const ProductTrustBanner(),
                    AppSpacing.h20,

                    Padding(
                      padding: AppSpacing.paddingHorizontal16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.productDetailsTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          AppSpacing.h6,
                          Obx(() {
                            final isExpanded =
                                controller.isDescriptionExpanded.value;
                            final details = controller.productDetails.value;
                            final String description =
                                (details != null &&
                                    details.description.isNotEmpty)
                                ? details.description
                                : (mergedProductData['description']?.toString() ??
                                      'Fresh quality produce harvested at peak freshness from trusted local vendors.');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  maxLines: isExpanded ? 10 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                AppSpacing.h4,
                                InkWell(
                                  onTap: controller.toggleDescription,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isExpanded
                                            ? AppStrings.readLess
                                            : AppStrings.readMore,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                      ),
                                      AppSpacing.w2,
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    AppSpacing.h20,

                    const ProductOffersSection(),
                    AppSpacing.h20,

                    const ProductComboSection(),
                    AppSpacing.h20,

                    const ProductRelatedSection(),
                    AppSpacing.h24,
                  ],
                ),
              ),
            ),
          ),

            ProductBottomBar(productData: mergedProductData),
          ],
        ),
      ),
    );
  }
}
