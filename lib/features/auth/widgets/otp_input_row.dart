//
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/custom_text_field.dart';

class OtpInputRow extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;

  // Legacy compatibility parameters
  final List<TextEditingController>? controllers;
  final List<FocusNode>? focusNodes;

  const OtpInputRow({
    super.key,
    this.controller,
    this.focusNode,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
    this.controllers,
    this.focusNodes,
  });

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _cursorAnimController;
  late final Animation<double> _cursorOpacity;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  int get _count => widget.controllers?.length ?? widget.length;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else if (widget.controllers != null && widget.controllers!.isNotEmpty) {
      final initialText = widget.controllers!.map((c) => c.text).join();
      _controller = TextEditingController(text: initialText);
      _isInternalController = true;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    _cursorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cursorOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _cursorAnimController, curve: Curves.easeInOut),
    );

    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);

    if (_focusNode.hasFocus) {
      _cursorAnimController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _cursorAnimController.dispose();

    if (_isInternalController) {
      _controller.dispose();
    }
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _cursorAnimController.repeat(reverse: true);
    } else {
      _cursorAnimController.stop();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _syncLegacyControllers(String text) {
    if (widget.controllers != null) {
      for (int i = 0; i < widget.controllers!.length; i++) {
        if (i < text.length) {
          widget.controllers![i].text = text[i];
        } else {
          widget.controllers![i].text = '';
        }
      }
    }
  }

  void _handleTextChanged(String val) {
    _cursorAnimController.reset();
    if (_focusNode.hasFocus) {
      _cursorAnimController.repeat(reverse: true);
    }

    _syncLegacyControllers(val);
    widget.onChanged?.call(val);

    if (val.length == _count) {
      widget.onCompleted?.call(val);
    }
  }

  void _onBoxTap(int index) {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    final text = _controller.text;
    if (index < text.length) {
      _controller.selection = TextSelection(
        baseOffset: index,
        extentOffset: index + 1,
      );
    } else {
      _controller.selection = TextSelection.collapsed(
        offset: math.min(text.length, _count),
      );
    }
    _cursorAnimController.reset();
    _cursorAnimController.repeat(reverse: true);
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim().replaceAll(RegExp(r'\D'), '') ?? '';
    if (text.isNotEmpty) {
      final code = text.length > _count ? text.substring(0, _count) : text;
      _controller.text = code;
      _controller.selection = TextSelection.collapsed(offset: code.length);
      _handleTextChanged(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _count;
    final boxSize = count > 4
        ? AppSpacing.screenWidth * 0.12
        : AppSpacing.screenWidth * 0.15;
    final borderRadius = BorderRadius.circular(AppSpacing.screenWidth * 0.03);

    final currentText = _controller.text;
    final cursorOffset = _controller.selection.baseOffset;
    final activeIndex = cursorOffset >= 0 && cursorOffset < count
        ? cursorOffset
        : math.min(currentText.length, count - 1);

    return AutofillGroup(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: _handlePaste,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Invisible full-width text field wired for keyboard, backspace, and OS autofill
            Positioned.fill(
              child: Opacity(
                opacity: 0.0,
                child: CustomTextField(
                  hintText: '',
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autoFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: count,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(count),
                  ],
                  showCursor: false,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.transparent,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: AppSpacing.paddingZero,
                  ),
                  onChanged: _handleTextChanged,
                  onSubmitted: (val) {
                    if (val.length == count) {
                      widget.onCompleted?.call(val);
                    }
                  },
                ),
              ),
            ),

            // Visual representation of responsive interactive OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(count, (index) {
                final hasDigit = index < currentText.length;
                final digit = hasDigit ? currentText[index] : '';
                final isCurrentActive =
                    _focusNode.hasFocus && index == activeIndex;

                Color borderColor = AppColors.borderLight;
                double borderWidth = 1.0;
                List<BoxShadow>? shadows;

                if (isCurrentActive) {
                  borderColor = AppColors.primary;
                  borderWidth = 2.0;
                  shadows = [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                    ),
                  ];
                } else if (hasDigit) {
                  borderColor = AppColors.primary.withValues(alpha: 0.5);
                  borderWidth = 1.5;
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onBoxTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                      boxShadow: shadows,
                    ),
                    alignment: Alignment.center,
                    child: hasDigit
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                    ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              digit,
                              key: ValueKey<String>('digit_${index}_$digit'),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                          )
                        : (isCurrentActive
                              ? FadeTransition(
                                  opacity: _cursorOpacity,
                                  child: Container(
                                    width: AppSpacing.w2.width,
                                    height: boxSize * 0.45,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radius2,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
