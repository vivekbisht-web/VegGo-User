import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../controllers/orders_controller.dart';
import '../models/order_track_response_model.dart';

class OrderTrackingStatusCard extends StatelessWidget {
  const OrderTrackingStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    return Obx(() {
      final trackData = ordersController.orderTrackingData.value;

      if (ordersController.isTrackingLoading.value && trackData == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (trackData == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('No tracking data available')),
        );
      }

      final timeline = trackData.statusTimeline ?? [];
      final isDelivered = (trackData.status ?? '').toUpperCase() == 'DELIVERED';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Status header ----------
          Container(
            padding: AppSpacing.paddingResponsiveAll(0.05),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppSpacing.screenWidth * 0.04,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusLabel(trackData.status),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppSpacing.h4,
                          if (trackData.orderNumber != null)
                            Text(
                              trackData.orderNumber!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    if (trackData.estimatedDeliveryWindow != null &&
                        !isDelivered)
                      Container(
                        padding: AppSpacing.paddingSymmetric(
                          horizontal: AppSpacing.screenWidth * 0.03,
                          vertical: AppSpacing.screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.screenWidth * 0.05,
                          ),
                        ),
                        child: Text(
                          trackData.estimatedDeliveryWindow!,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.responsiveHeight(0.04),
                if (timeline.isNotEmpty) _AnimatedStepper(timeline: timeline),
              ],
            ),
          ),

          AppSpacing.responsiveHeight(0.02),

          // ---------- Drop OTP ----------
          if (trackData.dropOtp != null && !isDelivered)
            _buildOtpCard(context, trackData.dropOtp!),

          // ---------- Delivery agent ----------
          if (trackData.deliveryAgentName != null)
            _buildDeliveryAgentCard(context, trackData),

          // ---------- Shop info ----------
          if (trackData.shopName != null)
            _buildInfoTile(
              context,
              icon: Icons.storefront_outlined,
              title: trackData.shopName!,
              subtitle: trackData.shopBusinessPhone,
              onCallTap: trackData.shopBusinessPhone != null
                  ? () => _launchCall(trackData.shopBusinessPhone!)
                  : null,
            ),

          // ---------- Delivery address ----------
          if (trackData.deliveryAddress != null)
            _buildInfoTile(
              context,
              icon: Icons.location_on_outlined,
              title: 'Delivery Address',
              subtitle: trackData.deliveryAddress,
            ),

          // ---------- Items ----------
          if (trackData.items != null && trackData.items!.isNotEmpty)
            _buildItemsCard(context, trackData),
        ],
      );
    });
  }

  // ---------------- Helpers ----------------

  String _statusLabel(String? status) {
    switch (status) {
      case 'PLACED':
        return 'Order Placed';
      case 'PREPARED':
        return 'Prepared';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return status ?? 'Tracking Order';
    }
  }

  Widget _buildOtpCard(BuildContext context, String otp) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.screenWidth * 0.03),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ' this is  OTP',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            otp,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAgentCard(
    BuildContext context,
    OrderTrackData trackData,
  ) {
    return _buildInfoTile(
      context,
      icon: Icons.delivery_dining_outlined,
      title: trackData.deliveryAgentName ?? 'Delivery Agent',
      subtitle: trackData.deliveryAgentPhone,
      onCallTap: trackData.deliveryAgentPhone != null
          ? () => _launchCall(trackData.deliveryAgentPhone!)
          : null,
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onCallTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.screenWidth * 0.03),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.screenWidth * 0.025),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onCallTap != null)
            IconButton(
              onPressed: onCallTap,
              icon: const Icon(Icons.call_outlined),
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderTrackData trackData) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.screenWidth * 0.03),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.h8,
          ...trackData.items!.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.screenWidth * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName ?? ''} x${item.quantity ?? 0}'
                      '${item.unit != null ? ' (${item.unit})' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '₹${(item.subTotal ?? 0).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${(trackData.total ?? 0).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    // Requires the `url_launcher` package in pubspec.yaml.
    // final uri = Uri(scheme: 'tel', path: phone);
    // if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

/// Stepper row with a bike icon that continuously animates back and forth
/// along the line segment of whichever step is currently active
/// (the "On the way" step), giving a "moving/in-transit" feel.
class _AnimatedStepper extends StatefulWidget {
  final List<OrderStatusTimeline> timeline;

  const _AnimatedStepper({required this.timeline});

  @override
  State<_AnimatedStepper> createState() => _AnimatedStepperState();
}

class _AnimatedStepperState extends State<_AnimatedStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bikeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bikeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.timeline]
      ..sort((a, b) => (a.step ?? 0).compareTo(b.step ?? 0));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(sorted.length, (index) {
        final step = sorted[index];
        final isCompleted = step.completedAt != null && step.current != true;
        final isCurrent = step.current == true;
        final isFirst = index == 0;
        final isLast = index == sorted.length - 1;

        // Bike only animates on the connector line that comes *before*
        // the currently active step (i.e. the segment being travelled).
        final bool animateLeadingLine = isCurrent && !isFirst;

        return _buildStep(
          context,
          step.label ?? 'Step ${step.step ?? index + 1}',
          isCompleted || isCurrent,
          isCurrent: isCurrent,
          isFirst: isFirst,
          isLast: isLast,
          animateLeadingLine: animateLeadingLine,
        );
      }),
    );
  }

  Widget _buildStep(
    BuildContext context,
    String label,
    bool isCompleted, {
    bool isCurrent = false,
    bool isFirst = false,
    bool isLast = false,
    bool animateLeadingLine = false,
  }) {
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = AppColors.borderLight;
    const double lineHeight = 3;
    const double bikeSize = 20;

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              // ---- Leading connector line (with bike if active) ----
              Expanded(
                child: isFirst
                    ? const SizedBox()
                    : animateLeadingLine
                    ? SizedBox(
                        height: bikeSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(height: lineHeight, color: activeColor),
                            AnimatedBuilder(
                              animation: _bikeAnimation,
                              builder: (context, child) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxOffset =
                                        constraints.maxWidth - bikeSize;
                                    final dx =
                                        _bikeAnimation.value *
                                        (maxOffset < 0 ? 0 : maxOffset);
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: dx),
                                        child: child,
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: bikeSize,
                                height: bikeSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.pedal_bike,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: lineHeight,
                        color: isCompleted ? activeColor : inactiveColor,
                      ),
              ),

              // ---- Step circle ----
              Container(
                width: AppSpacing.screenWidth * 0.06,
                height: AppSpacing.screenWidth * 0.06,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted && !isCurrent
                      ? activeColor
                      : (isCurrent ? AppColors.surface : AppColors.background),
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? activeColor
                        : inactiveColor,
                    width: 2,
                  ),
                ),
                child: (isCompleted && !isCurrent)
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.surface,
                      )
                    : (isCurrent
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null),
              ),

              // ---- Trailing connector line ----
              Expanded(
                child: isLast
                    ? const SizedBox()
                    : Container(
                        height: lineHeight,
                        color: isCompleted && !isCurrent
                            ? activeColor
                            : inactiveColor,
                      ),
              ),
            ],
          ),
          AppSpacing.h8,
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isCompleted || isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
