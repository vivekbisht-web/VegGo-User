import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';

enum QuantitySelectorStyle { bordered, circular }

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final QuantitySelectorStyle style;
  final double? height;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.style = QuantitySelectorStyle.circular,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (style == QuantitySelectorStyle.bordered) {
      return _buildBorderedStyle(context);
    }
    return _buildCircularStyle(context);
  }

  Widget _buildBorderedStyle(BuildContext context) {
    return Container(
      height: height ?? 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius6),
        border: Border.all(color: AppColors.quantityBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            borderRadius: BorderRadius.circular(AppSpacing.radius4),
            child: const Padding(
              padding: AppSpacing.paddingHorizontal8,
              child: Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
          InkWell(
            onTap: onIncrement,
            borderRadius: BorderRadius.circular(AppSpacing.radius4),
            child: const Padding(
              padding: AppSpacing.paddingHorizontal8,
              child: Icon(Icons.add, size: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularStyle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: AppSpacing.paddingResponsiveAll(0.012),
            decoration: BoxDecoration(
              color: AppColors.borderLight.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.remove,
              color: AppColors.textSecondary,
              size: AppSpacing.screenWidth * 0.04,
            ),
          ),
        ),
        Padding(
          padding: AppSpacing.paddingResponsiveHorizontal(0.04),
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: AppSpacing.paddingResponsiveAll(0.012),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: AppColors.surface,
              size: AppSpacing.screenWidth * 0.04,
            ),
          ),
        ),
      ],
    );
  }
}
