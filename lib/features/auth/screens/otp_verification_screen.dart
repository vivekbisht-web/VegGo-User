//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_icon_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_input_row.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String emailOrPhone;
  const OTPVerificationScreen({super.key, this.emailOrPhone = ''});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  AuthController get _authController => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  DateTime? _lastBackPressTime;

  String get _targetPhone => widget.emailOrPhone.isNotEmpty
      ? widget.emailOrPhone
      : (Get.arguments?.toString() ?? '');

  @override
  void initState() {
    super.initState();
    _authController.resetLoading();
    if (_authController.resendCooldown.value == 0) {
      _authController.startResendCooldown();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final fullOtp = _controllers.map((c) => c.text).join();
    if (fullOtp.length == 6) {
      _onVerifyPressed();
    }
  }

  void _onVerifyPressed() {
    final otpCode = _controllers.map((c) => c.text).join();
    _authController.verifyOtp(otpCode);
  }

  void _onResendPressed() {
    if (_authController.resendCooldown.value == 0 && _targetPhone.isNotEmpty) {
      _authController.requestOtp("", onCodeSent: () {});
    }
  }

  bool _handleDoubleBackPress() {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      Get.snackbar(
        AppStrings.appName,
        'Press back again to change mobile number',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.textPrimary,
        colorText: AppColors.surface,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_handleDoubleBackPress()) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: CustomIconButton(
            icon: Icons.arrow_back,
            color: AppColors.primary,
            onPressed: () {
              if (_handleDoubleBackPress()) {
                Get.back();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingResponsiveAll(0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.otpVerification,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.h8,
                Text(
                  '${AppStrings.enterOtpSentTo}$_targetPhone',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.responsiveHeight(0.05),
                OtpInputRow(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  onChanged: _onOtpDigitChanged,
                ),
                AppSpacing.responsiveHeight(0.04),
                Obx(
                  () => CustomButton(
                    text: AppStrings.verifyCode,
                    isLoading: _authController.isLoading.value,
                    onPressed: _onVerifyPressed,
                  ),
                ),
                AppSpacing.responsiveHeight(0.03),
                Center(
                  child: Obx(() {
                    final cooldown = _authController.resendCooldown.value;
                    final isCooldownActive = cooldown > 0;

                    return TextButton(
                      onPressed: isCooldownActive ? null : _onResendPressed,
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.didntReceiveCode,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: isCooldownActive
                                  ? '${AppStrings.resendCodeIn}$cooldown${AppStrings.resendCodeInSuffix}'
                                  : AppStrings.resendCode,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isCooldownActive
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
