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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthController _authController = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _authController.resetLoading();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.emptyFieldError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return;
    }

    if (!_agreedToTerms) {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.termsAgree,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.surface,
      );
      return;
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.responsiveHeight(0.04),
              Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 24),
                  AppSpacing.responsiveWidth(0.02),
                  Text(
                    AppStrings.veggoFresh,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              AppSpacing.responsiveHeight(0.03),
              Text(
                AppStrings.registerHere,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.responsiveHeight(0.01),
              Text(
                AppStrings.registerToContinue,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.responsiveHeight(0.04),
              CustomTextField(
                controller: _nameController,
                label: AppStrings.fullName,
                hintText: AppStrings.nameHint,
                prefixIcon: Icons.person_outline,
              ),
              AppSpacing.responsiveHeight(0.025),
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
              AppSpacing.responsiveHeight(0.025),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) =>
                          setState(() => _agreedToTerms = val ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  AppSpacing.responsiveWidth(0.03),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: AppStrings.termsAgree,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.terms,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const TextSpan(text: AppStrings.and),
                          TextSpan(
                            text: AppStrings.privacyPolicy,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.responsiveHeight(0.04),
              Obx(
                () => CustomButton(
                  text: AppStrings.sendOtp,
                  icon: Icons.arrow_forward,
                  isLoading: _authController.isLoading.value,
                  onPressed: _onRegisterPressed,
                ),
              ),
              AppSpacing.responsiveHeight(0.06),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      text: AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: AppStrings.login,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppSpacing.responsiveHeight(0.04),
            ],
          ),
        ),
      ),
    );
  }
}
