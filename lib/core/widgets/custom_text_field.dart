//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vegon_user/core/widgets/custom_icon_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? label;
  final Widget? customSuffix;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? rightActionText;
  final VoidCallback? onRightActionTap;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TapRegionCallback? onTapOutside;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.label,
    this.customSuffix,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.rightActionText,
    this.onRightActionTap,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.textInputAction,
    this.onSubmitted,
    this.style,
    this.decoration,
    this.onTapOutside,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    Widget field = TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      onTapOutside: widget.onTapOutside,
      onFieldSubmitted: widget.onSubmitted,
      style: widget.style,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      focusNode: widget.focusNode,
      textAlign: widget.textAlign,
      decoration: widget.decoration ?? InputDecoration(
        counterText: widget.maxLength != null ? '' : null,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
            : null,
        suffixIcon: widget.isPassword
            ? CustomIconButton(
                icon: _obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.customSuffix,
      ),
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.rightActionText != null &&
                  widget.onRightActionTap != null)
                GestureDetector(
                  onTap: widget.onRightActionTap,
                  child: Text(
                    widget.rightActionText!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.h8,
          field,
        ],
      );
    }
    return field;
  }
}
