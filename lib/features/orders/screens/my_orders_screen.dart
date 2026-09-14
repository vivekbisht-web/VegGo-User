//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/empty_state_widget.dart';
import 'package:vegon_user/features/orders/controllers/orders_controller.dart';
import 'package:vegon_user/features/orders/models/order_model.dart';
import 'package:vegon_user/features/orders/screens/track_order_screen.dart';
import 'package:vegon_user/features/orders/screens/order_delivered_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // One scroll controller per tab so each list paginates independently.
  final ScrollController _allScrollController = ScrollController();
  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _completedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _attachPaginationListener(_allScrollController);
    _attachPaginationListener(_activeScrollController);
    _attachPaginationListener(_completedScrollController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().fetchOrders(isRefresh: true);
      }
    });
  }

  /// Triggers loading the next page once the user scrolls near the
  /// bottom (within 200px) of the currently visible tab's list.
  void _attachPaginationListener(ScrollController controller) {
    controller.addListener(() {
      if (!controller.hasClients) return;
      final threshold = controller.position.maxScrollExtent - 200;
      if (controller.position.pixels >= threshold && threshold > 0) {
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().loadMoreOrders();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _allScrollController.dispose();
    _activeScrollController.dispose();
    _completedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: AppStrings.allOrders),
                Tab(text: AppStrings.inProgress),
                Tab(text: AppStrings.delivered),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(
                  ordersController,
                  type: 0,
                  scrollController: _allScrollController,
                ),
                _buildOrderList(
                  ordersController,
                  type: 1,
                  scrollController: _activeScrollController,
                ),
                _buildOrderList(
                  ordersController,
                  type: 2,
                  scrollController: _completedScrollController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    OrdersController controller, {
    required int type,
    required ScrollController scrollController,
  }) {
    return Obx(() {
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      List<OrderModel> list;
      if (type == 1) {
        list = controller.activeOrders;
      } else if (type == 2) {
        list = controller.completedOrders;
      } else {
        list = controller.orders;
      }

      if (list.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchOrders(isRefresh: true),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: AppSpacing.screenHeight * 0.7,
              child: const Center(
                child: EmptyStateWidget(
                  title: AppStrings.noOrdersYet,
                  subtitle: AppStrings.orderProduceHint,
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ),
          ),
        );
      }

      // "All" tab drives real pagination against the backend (type 0),
      // since Active/Completed are just client-side filters over the
      // same underlying `orders` list. Loading more still works for
      // them because they read from the same growing list.
      final bool showTrailingLoader =
          controller.isLoadingMore.value && controller.hasMorePages.value;

      return RefreshIndicator(
        onRefresh: () => controller.fetchOrders(isRefresh: true),
        color: AppColors.primary,
        child: ListView.separated(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.paddingResponsiveAll(0.04),
          itemCount: list.length + (showTrailingLoader ? 1 : 0),
          separatorBuilder: (context, index) => AppSpacing.h16,
          itemBuilder: (context, index) {
            if (index >= list.length) {
              // Bottom pagination loader.
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }
            final order = list[index];
            return _buildOrderCard(context, order, controller);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    OrdersController controller,
  ) {
    final isDelivered = order.status == OrderStatus.delivered;

    final String? shopName = order.shopName;
    final String? agentName = order.deliveryAgentName;

    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date + status chip ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: AppSpacing.paddingSymmetric(
                  horizontal: AppSpacing.radius8,
                  vertical: AppSpacing.radius4,
                ),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? AppColors.successBackground
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radius8),
                ),
                child: Text(
                  order.statusText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDelivered ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h12,

          // ── Thumbnail + order info ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(order),
              AppSpacing.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${order.displayOrderNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.h4,
                    Text(
                      '${order.items.length} ${AppStrings.items} • ${AppStrings.rupeeSymbol}${order.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (shopName != null && shopName.isNotEmpty) ...[
                      AppSpacing.h4,
                      Text(
                        shopName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (agentName != null && agentName.isNotEmpty) ...[
                      AppSpacing.h4,
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          AppSpacing.w4,
                          Expanded(
                            child: Text(
                              agentName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h16,

          // ── Action button ──
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: isDelivered
                      ? AppStrings.rateReorder
                      : AppStrings.trackOrder,
                  isOutlined: true,
                  onPressed: () {
                    controller.selectOrder(order);
                    if (isDelivered) {
                      Get.to(() => const OrderDeliveredScreen());
                    } else {
                      Get.to(() => const TrackOrderScreen());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(OrderModel order) {
    const double size = 56;

    if (!order.hasThumbnail) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radius8),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.textSecondary,
          size: 24,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius8),
      child: Image.network(
        order.primaryThumbnail,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: AppColors.background,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: AppColors.background,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          );
        },
      ),
    );
  }
}
