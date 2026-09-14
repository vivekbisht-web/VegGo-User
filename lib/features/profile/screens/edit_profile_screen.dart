import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import '../controllers/user_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserProfileController _controller =
      Get.isRegistered<UserProfileController>()
          ? Get.find<UserProfileController>()
          : Get.put(UserProfileController());

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _controller.name);
    _emailController = TextEditingController(text: _controller.email);
    _phoneController = TextEditingController(text: _controller.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final form = _formKey.currentState;
    if (form != null && !form.validate()) {
      return;
    }

    final success = await _controller.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (success) {
      Get.back();
      Get.snackbar(
        AppStrings.editProfile,
        AppStrings.profileUpdatedSuccessfully,
        backgroundColor: AppColors.success,
        colorText: AppColors.surface,
        snackPosition: SnackPosition.BOTTOM,
        margin: AppSpacing.paddingAll16,
      );
    } else {
      Get.snackbar(
        AppStrings.editProfile,
        _controller.errorMessage.value.isNotEmpty
            ? _controller.errorMessage.value
            : AppStrings.failedToUpdateProfile,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
        snackPosition: SnackPosition.BOTTOM,
        margin: AppSpacing.paddingAll16,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.editProfile,
        showBackButton: true,
        showCenterLogo: false,
        showActions: false,
        showCartButton: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.h24,
              _buildProfileImage(context),
              AppSpacing.h16,
              Text(
                AppStrings.changeProfilePicture,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.h32,
              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.fullName,
                label: AppStrings.fullName,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterName;
                  }
                  return null;
                },
              ),
              AppSpacing.h16,
              CustomTextField(
                controller: _emailController,
                hintText: AppStrings.email,
                label: AppStrings.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      !GetUtils.isEmail(value.trim())) {
                    return AppStrings.enterValidEmail;
                  }
                  return null;
                },
              ),
              AppSpacing.h16,
              CustomTextField(
                controller: _phoneController,
                hintText: AppStrings.phoneNumber,
                label: AppStrings.phoneNumber,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 10) {
                    return AppStrings.enterValidPhone;
                  }
                  return null;
                },
              ),
              AppSpacing.h40,
              Obx(() {
                return CustomButton(
                  text: AppStrings.saveChanges,
                  isLoading: _controller.isUpdating.value,
                  onPressed: _handleSave,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: AppSpacing.screenWidth * 0.25,
          height: AppSpacing.screenWidth * 0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlayLight.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Obx(() {
            final avatarUrl = _controller.avatar;
            if (avatarUrl.isNotEmpty) {
              return ClipOval(
                child: CustomImageView(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                ),
              );
            }
            return Icon(
              Icons.person,
              size: AppSpacing.screenWidth * 0.12,
              color: AppColors.textSecondary,
            );
          }),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: AppSpacing.paddingAll4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: AppColors.surface,
              size: AppSpacing.radius16,
            ),
          ),
        ),
      ],
    );
  }
}
