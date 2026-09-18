import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  AuthController get _authController => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.enterFullNameError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return;
    }
    _authController.submitBasicInfo(name);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingResponsiveAll(0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.responsiveHeight(0.04),
                Center(
                  child: Container(
                    padding: AppSpacing.paddingAll20,
                    decoration: BoxDecoration(
                      color: AppColors.mintLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                AppSpacing.responsiveHeight(0.03),
                Center(
                  child: Text(
                    AppStrings.basicInfoTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppSpacing.h8,
                Center(
                  child: Text(
                    AppStrings.basicInfoSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppSpacing.responsiveHeight(0.05),
                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.fullName,
                  hintText: AppStrings.nameHint,
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onSubmit(),
                ),
                AppSpacing.responsiveHeight(0.04),
                Obx(
                  () => CustomButton(
                    text: AppStrings.continueText,
                    icon: Icons.arrow_forward,
                    isLoading: _authController.isLoading.value,
                    onPressed: _onSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
