//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/features/category/screens/category_screen.dart';
import 'package:vegon_user/features/home/screens/home_screen.dart';
import 'package:vegon_user/features/orders/screens/my_orders_screen.dart';
import 'package:vegon_user/features/profile/screens/favorites_screen.dart';
import 'package:vegon_user/features/profile/screens/profile_screen.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController controller = Get.put(DashboardController());

  final List<Widget> pages = const [
    HomeScreen(),
    CategoryScreen(),
    MyOrdersScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.selectedIndex.value == 0,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          if (controller.selectedIndex.value != 0) {
            controller.changeTabIndex(0);
          }
        },
        child: Scaffold(
          key: controller.scaffoldKey,
          backgroundColor: AppColors.surface,
          drawer: const AppDrawer(),
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children: List.generate(
              pages.length,
              (index) => controller.visitedTabs.contains(index)
                  ? pages[index]
                  : const SizedBox.shrink(),
            ),
          ),
          bottomNavigationBar: _buildCustomBottomNavBar(context),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
    return Obx(() {
      final selectedIdx = controller.selectedIndex.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.chipBorder.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: AppStrings.home,
                  isSelected: selectedIdx == 0,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: AppStrings.categories,
                  isSelected: selectedIdx == 1,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag_rounded,
                  label: AppStrings.orders,
                  isSelected: selectedIdx == 2,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  label: AppStrings.wishlist,
                  isSelected: selectedIdx == 3,
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: AppStrings.profile,
                  isSelected: selectedIdx == 4,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTabIndex(index),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            AppSpacing.h2,
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
