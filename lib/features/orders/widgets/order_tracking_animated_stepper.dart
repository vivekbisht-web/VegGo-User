//
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/order_track_response_model.dart';

class OrderTrackingAnimatedStepper extends StatefulWidget {
  final List<OrderStatusTimeline> timeline;

  const OrderTrackingAnimatedStepper({super.key, required this.timeline});

  @override
  State<OrderTrackingAnimatedStepper> createState() =>
      _OrderTrackingAnimatedStepperState();
}

class _OrderTrackingAnimatedStepperState
    extends State<OrderTrackingAnimatedStepper>
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
                                      color: AppColors.black.withValues(
                                        alpha: 0.15,
                                      ),
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
