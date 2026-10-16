//
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

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
    _authController.onAutoVerifiedCallback = _handleAutoVerified;
  }

  @override
  void dispose() {
    if (_authController.onAutoVerifiedCallback == _handleAutoVerified) {
      _authController.onAutoVerifiedCallback = null;
    }
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _handleAutoVerified(PhoneAuthCredential credential) {
    if (credential.smsCode != null && credential.smsCode!.isNotEmpty) {
      _otpController.text = credential.smsCode!;
    }
    _authController.verifyPhoneAuthCredential(credential);
  }

  void _onVerifyPressed() {
    final otpCode = _otpController.text.trim();
    if (otpCode.length == 6) {
      _authController.verifyOtp(otpCode);
    }
  }

  void _onResendPressed() {
    if (_authController.resendCooldown.value == 0 && _targetPhone.isNotEmpty) {
      _otpController.clear();
      _authController.requestOtp(
        _targetPhone,
        isResend: true,
        onCodeSent: () {},
        onAutoVerified: _handleAutoVerified,
      );
    }
  }

  void _onChangePhoneNumberPressed() {
    _authController.resetLoading();
    if (_authController.onAutoVerifiedCallback == _handleAutoVerified) {
      _authController.onAutoVerifiedCallback = null;
    }
    Get.back();
  }

  bool _handleDoubleBackPress() {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      Get.snackbar(
        AppStrings.appName,
        AppStrings.pressBackToChangeNumber,
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
            child: SingleChildScrollView(
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${AppStrings.enterOtpSentTo}$_targetPhone',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: _onChangePhoneNumberPressed,
                        style: TextButton.styleFrom(
                          padding: AppSpacing.paddingHorizontal8,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.changeNumber,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.responsiveHeight(0.05),
                  OtpInputRow(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                    length: 6,
                    autoFocus: true,
                    onCompleted: (_) => _onVerifyPressed(),
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: isCooldownActive
                                    ? '${AppStrings.resendCodeIn}$cooldown${AppStrings.resendCodeInSuffix}'
                                    : AppStrings.resendCode,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
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
                  AppSpacing.h12,
                  Center(
                    child: TextButton.icon(
                      onPressed: _onChangePhoneNumberPressed,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        AppStrings.changePhoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
