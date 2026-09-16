//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/empty_state_widget.dart';
import 'package:vegon_user/core/widgets/floating_cart_bar.dart';
import 'package:vegon_user/features/category/widgets/category_product_card.dart';

class RelatedItemsScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? products;

  const RelatedItemsScreen({super.key, this.products});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> itemList =
        products ?? (Get.arguments as List<Map<String, dynamic>>?) ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: itemList.isEmpty
          ? const Center(
              child: EmptyStateWidget(
                title: AppStrings.noProductsFound,
                subtitle: AppStrings.noRelatedItemsFound,
                icon: Icons.inventory_2_outlined,
              ),
            )
          : GridView.builder(
              padding: AppSpacing.paddingResponsiveAll(0.04),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.screenWidth * 0.03,
                mainAxisSpacing: AppSpacing.screenWidth * 0.03,
                childAspectRatio: 0.65,
              ),
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                final product = itemList[index];
                return CategoryProductCard(product: product);
              },
            ),
      bottomNavigationBar: const FloatingCartBar(bottomPadding: 16),
    );
  }
}
