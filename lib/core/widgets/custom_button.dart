//
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isOutlined;
  final bool isTextButton;
  final Color? textColor;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height,
    this.backgroundColor,
    this.icon,
    this.isOutlined = false,
    this.isTextButton = false,
    this.textColor,
    this.iconColor,
    this.textStyle,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      _controller.reverse();
      widget.onPressed();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;
    final bgColor = (widget.isOutlined || widget.isTextButton)
        ? AppColors.transparent
        : (widget.backgroundColor ?? themeColor);
    final displayTextColor =
        widget.textColor ??
        (widget.isOutlined || widget.isTextButton
            ? themeColor
            : AppColors.surface);
    final displayIconColor = widget.iconColor ?? displayTextColor;

    final defaultTextStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: displayTextColor,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          final yOffset = (1.0 - _elevationAnimation.value) * 4.0;
          final shadowOpacity = widget.isOutlined
              ? 0.0
              : 0.3 * _elevationAnimation.value;
          final blurRadius = 8.0 * _elevationAnimation.value;

          return Transform.translate(
            offset: Offset(0, yOffset),
            child: Container(
              width: widget.isTextButton ? null : widget.width,
              height: widget.isTextButton ? null : (widget.height ?? 52),
              padding: widget.isTextButton
                  ? AppSpacing.paddingAll8
                  : (widget.height != null && widget.height! < 40
                      ? AppSpacing.paddingHorizontal8
                      : AppSpacing.paddingHorizontal16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? AppSpacing.radius32,
                ),
                border: widget.isOutlined
                    ? Border.all(color: AppColors.border, width: 1.5)
                    : null,
                boxShadow: [
                  if (shadowOpacity > 0.01 && !widget.isTextButton)
                    BoxShadow(
                      color: bgColor.withValues(alpha: shadowOpacity),
                      blurRadius: blurRadius,
                      offset: Offset(0, 4.0 * _elevationAnimation.value),
                    ),
                ],
              ),
              child: widget.isLoading
                  ? CircularProgressIndicator(
                      color: displayTextColor,
                      strokeWidth: 2.5,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isTextButton || widget.width == null)
                          Text(
                            widget.text,
                            style: widget.textStyle ?? defaultTextStyle,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Flexible(
                            child: Text(
                              widget.text,
                              style: widget.textStyle ?? defaultTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.icon != null) ...[
                          AppSpacing.w8,
                          Icon(widget.icon, color: displayIconColor, size: 20),
                        ],
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
