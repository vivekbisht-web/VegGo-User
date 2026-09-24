import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/section_header.dart';
import 'package:vegon_user/features/cart/controllers/cart_controller.dart';
import 'package:vegon_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:vegon_user/features/dashboard/widgets/app_drawer.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';
import 'package:vegon_user/features/home/controllers/home_search_controller.dart';
import 'package:vegon_user/features/home/widgets/home_all_products_grid.dart';
import 'package:vegon_user/features/home/widgets/home_banner.dart';
import 'package:vegon_user/features/home/widgets/home_best_deals.dart';
import 'package:vegon_user/features/home/widgets/home_categories.dart';
import 'package:vegon_user/features/home/widgets/home_header_sliver.dart';
import 'package:vegon_user/features/home/widgets/home_live_search_results.dart';
import 'package:vegon_user/features/home/widgets/home_product_section.dart';
import 'package:vegon_user/features/home/widgets/home_quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final searchController = Get.isRegistered<HomeSearchController>()
        ? Get.find<HomeSearchController>()
        : Get.put(HomeSearchController());

    Future<void> onRefresh() async {
      await homeController.refreshHome();
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().fetchCartBadgeCount();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.primary,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  const HomeHeaderSliver(),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (searchController.searchQuery.value.isNotEmpty) {
                        return const HomeLiveSearchResults();
                      }

                      return Padding(
                        padding: AppSpacing.paddingFromLTRB(16, 14, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HomeBanner(),
                            AppSpacing.h20,
                            SectionHeader(
                              title: AppStrings.shopByCategory,
                              onActionTap: () =>
                                  dashboardController.changeTabIndex(1),
                            ),
                            AppSpacing.h8,
                            const HomeCategories(),
                            AppSpacing.h20,
                            Obx(() {
                              if (homeController.bestDeals.isEmpty &&
                                  !homeController.isDealsLoading.value &&
                                  !homeController.isLoading.value) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionHeader(
                                    title: AppStrings.bestDealsForYou,
                                    onActionTap: () =>
                                        dashboardController.changeTabIndex(1),
                                  ),
                                  AppSpacing.h8,
                                  const HomeBestDeals(),
                                  AppSpacing.h20,
                                ],
                              );
                            }),
                            const HomeQuickActions(),
                            AppSpacing.h20,
                            Obx(() {
                              if (homeController.freshProduce.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionHeader(
                                    title: AppStrings.freshVegetablesTitle,
                                    onActionTap: () =>
                                        dashboardController.changeTabIndex(1),
                                  ),
                                  AppSpacing.h8,
                                  HomeProductSection(
                                    products: homeController.freshProduce,
                                    maxItems: 4,
                                  ),
                                  AppSpacing.h20,
                                ],
                              );
                            }),
                            SectionHeader(
                              title: AppStrings.allProducts,
                              onActionTap: () =>
                                  dashboardController.changeTabIndex(1),
                            ),
                            AppSpacing.h8,
                            const HomeAllProductsGrid(),
                            AppSpacing.h32,
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            ],
          ),
        ),
      );
  }
}
