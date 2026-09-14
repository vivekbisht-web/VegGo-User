//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/empty_state_widget.dart';
import 'package:vegon_user/features/category/widgets/category_product_card.dart';
import 'package:vegon_user/features/product/controllers/wishlist_controller.dart';
import 'package:vegon_user/features/product/models/product_details_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    AppStrings.all,
    AppStrings.fruits,
    AppStrings.vegetables,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WishlistController.to.fetchWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController = WishlistController.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.favorites,
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => wishlistController.fetchWishlist(),
        color: AppColors.primary,
        child: Column(
          children: [
            _buildCategoryFilter(),
            Expanded(
              child: Obx(() {
                if (wishlistController.isLoading.value &&
                    wishlistController.wishlistProducts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                List<ProductDetailsData> items =
                    List<ProductDetailsData>.from(
                      wishlistController.wishlistProducts,
                    );

                if (_selectedCategoryIndex == 1) {
                  items = items
                      .where(
                        (p) =>
                            p.category.toLowerCase().contains('fruit'),
                      )
                      .toList();
                } else if (_selectedCategoryIndex == 2) {
                  items = items
                      .where(
                        (p) =>
                            p.category.toLowerCase().contains('veg'),
                      )
                      .toList();
                }

                if (items.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: AppSpacing.screenHeight * 0.7,
                      child: const Center(
                        child: EmptyStateWidget(
                          title: AppStrings.noFavoritesYet,
                          subtitle: AppStrings.exploreAndAddFavorites,
                          icon: Icons.favorite_border_rounded,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.paddingResponsiveAll(0.04),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return CategoryProductCard(
                      product: items[index].toMap(),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: AppSpacing.paddingVertical8,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontal16,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: AppSpacing.paddingOnly(right: 8),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                }
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radius20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderLight.withValues(alpha: 0.3),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
