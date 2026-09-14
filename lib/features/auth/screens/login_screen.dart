//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/freshness_guarantee_badge.dart';
import '../widgets/login_header_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  AuthController get _authController => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _authController.resetLoading();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Future<void> _onGetOtpPressed() async {
  //   final rawPhone = _phoneController.text.trim();
  //   final success = await _authController.requestOtp(rawPhone);
  //   if (success) {
  //     final formattedPhone = _authController.sanitizePhone(rawPhone) ?? rawPhone;
  //     Get.toNamed(
  //       AppRoutes.otpVerification,
  //       arguments: formattedPhone,
  //     );
  //   }
  // }

  Future<void> _onGetOtpPressed() async {
    final rawPhone = _phoneController.text.trim();
    final success = await _authController.requestOtp(
      rawPhone,
      onCodeSent: () {},
    );
    if (success) {
      final formattedPhone =
          _authController.sanitizePhone(rawPhone) ?? rawPhone;
      Get.toNamed(AppRoutes.otpVerification, arguments: formattedPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingSymmetric(
            horizontal: AppSpacing.screenWidth * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LoginHeaderWidget(),
              AppSpacing.responsiveHeight(0.05),
              CustomTextField(
                controller: _phoneController,
                label: AppStrings.mobileNumber,
                hintText: AppStrings.mobileHint,
                prefixIcon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              AppSpacing.responsiveHeight(0.04),
              Obx(
                () => CustomButton(
                  text: AppStrings.sendOtp,
                  icon: Icons.arrow_forward,
                  isLoading: _authController.isLoading.value,
                  onPressed: _onGetOtpPressed,
                ),
              ),
              AppSpacing.responsiveHeight(0.06),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.register),
                child: RichText(
                  text: TextSpan(
                    text: AppStrings.noAccount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: AppStrings.createAccount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.responsiveHeight(0.05),
              const FreshnessGuaranteeBadge(),
              AppSpacing.responsiveHeight(0.04),
            ],
          ),
        ),
      ),
    );
  }
}
