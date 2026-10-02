import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/voice_search_bottom_sheet.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/cart/screens/cart_screen.dart';
import 'package:vegon_user/features/dashboard/controllers/notification_controller.dart';
import 'package:vegon_user/features/dashboard/screens/notification_screen.dart';
import 'package:vegon_user/features/home/controllers/home_search_controller.dart';
import 'package:vegon_user/features/home/widgets/home_live_search_results.dart';
import '../controller/category_controller.dart';
import '../widgets/category_product_card.dart';
import '../widgets/category_shimmer_loading.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/category_sort_filter_bar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final RxBool isSearchOpen = false.obs;

  @override
  Widget build(BuildContext context) {
    Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController());
    final HomeSearchController searchController =
        Get.isRegistered<HomeSearchController>()
            ? Get.find<HomeSearchController>()
            : Get.put(HomeSearchController());
    final CartController cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    final NotificationController notificationController =
        Get.isRegistered<NotificationController>()
            ? Get.find<NotificationController>()
            : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              // ── Custom Premium Category Header ───────────────────────
              _buildCategoryHeader(
                context,
                searchController,
                cartController,
                notificationController,
              ),

              // ── Body / Live Search Results ───────────────────────────
              Expanded(
                child: Obx(() {
                  if (searchController.searchQuery.value.isNotEmpty ||
                      isSearchOpen.value) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (searchController.searchQuery.value.isNotEmpty)
                            const HomeLiveSearchResults()
                          else
                            Padding(
                              padding: AppSpacing.paddingAll16,
                              child: Text(
                                AppStrings.typeOrVoiceSearchHint,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return const _CategoryScreenContent();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    HomeSearchController searchController,
    CartController cartController,
    NotificationController notificationController,
  ) {
    return Obx(() {
      final bool inSearchMode = isSearchOpen.value;

      return Container(
        padding: AppSpacing.paddingFromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: inSearchMode
              ? _buildActiveSearchBar(context, searchController)
              : _buildStandardAppBar(
                  context,
                  searchController,
                  cartController,
                  notificationController,
                ),
        ),
      );
    });
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    HomeSearchController searchController,
    CartController cartController,
    NotificationController notificationController,
  ) {
    final canPop = Navigator.canPop(context);

    return Row(
      children: [
        if (canPop)
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(AppSpacing.radius20),
            child: const Padding(
              padding: AppSpacing.paddingAll6,
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          )
        else
          AppSpacing.w4,

        Expanded(
          child: Text(
            AppStrings.categories,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 19,
                ),
          ),
        ),

        // Search Icon Action
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () {
            isSearchOpen.value = true;
          },
        ),

        // Notification Action
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
              onPressed: () => Get.to(() => const NotificationScreen()),
            ),
            Obx(() {
              final unread = notificationController.unreadCount.value;
              if (unread <= 0) return const SizedBox.shrink();
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: AppSpacing.paddingHorizontal4,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Center(
                    child: Text(
                      '$unread',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.surface,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),

        // Cart Action
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
              onPressed: () => Get.to(() => CartScreen()),
            ),
            Obx(() {
              final int count = cartController.totalItems;
              if (count <= 0) return const SizedBox.shrink();
              return Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: AppSpacing.paddingHorizontal4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.surface,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveSearchBar(
    BuildContext context,
    HomeSearchController searchController,
  ) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            searchController.clearSearch();
            isSearchOpen.value = false;
          },
          borderRadius: BorderRadius.circular(AppSpacing.radius20),
          child: const Padding(
            padding: AppSpacing.paddingAll6,
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
        AppSpacing.w6,

        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: searchController.searchTextController,
              autofocus: true,
              onChanged: searchController.onSearchQueryChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: AppSpacing.paddingVertical8,
                hintText: AppStrings.searchVegPlaceholder,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      if (searchController.searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return InkWell(
                        onTap: searchController.clearSearch,
                        child: const Padding(
                          padding: AppSpacing.paddingHorizontal8,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: () {
                        VoiceSearchBottomSheet.show(
                          context,
                          onResult: (spokenText) {
                            searchController.searchTextController.text =
                                spokenText;
                            searchController.onSearchQueryChanged(spokenText);
                          },
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radius20),
                      child: Container(
                        margin: AppSpacing.paddingRight8,
                        padding: AppSpacing.paddingAll6,
                        decoration: const BoxDecoration(
                          color: AppColors.mintLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  borderSide: const BorderSide(color: AppColors.chipBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  borderSide: const BorderSide(color: AppColors.chipBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
              SizedBox(
                height: AppSpacing.screenHeight * 0.4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                      AppSpacing.h12,
                      Text(
                        AppStrings.noProductsInCategory,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
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
          padding: AppSpacing.paddingAll12,
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.64,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return CategoryProductCard(product: product);
          },
        ),
      );
    });
  }
}
