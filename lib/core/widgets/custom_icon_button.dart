//
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class CustomIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const CustomIconButton({
    super.key,
    this.icon,
    this.customIcon,
    required this.onPressed,
    this.color,
    this.size,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: padding ?? AppSpacing.paddingAll8,
          child:
              customIcon ??
              Icon(
                icon ?? Icons.error,
                color: color ?? AppColors.textPrimary,
                size: size ?? 24.0,
              ),
        ),
      ),
    );
  }
}
