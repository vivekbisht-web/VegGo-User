//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/utils/snackbar_helper.dart';
import '../controllers/complaint_controller.dart';

class FileComplaintScreen extends StatefulWidget {
  const FileComplaintScreen({super.key});

  @override
  State<FileComplaintScreen> createState() => _FileComplaintScreenState();
}

class _FileComplaintScreenState extends State<FileComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCategory;

  static const _categories = [
    ('ORDER_ISSUE', AppStrings.catOrderIssue),
    ('PAYMENT_ISSUE', AppStrings.catPaymentIssue),
    ('DELIVERY_ISSUE', AppStrings.catDeliveryIssue),
    ('PRODUCT_QUALITY', AppStrings.catProductQuality),
    ('APP_ISSUE', AppStrings.catAppIssue),
    ('ACCOUNT_ISSUE', AppStrings.catAccountIssue),
    ('VENDOR_BEHAVIOR', AppStrings.catVendorBehavior),
    ('DELIVERY_BEHAVIOR', AppStrings.catDeliveryBehavior),
    ('OTHER', AppStrings.catOther),
  ];


  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ComplaintController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAll16,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category dropdown
              Text(
                AppStrings.complaintCategory,
                style: theme.textTheme.labelLarge,
              ),
              AppSpacing.h8,
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                hint: Text(
                  AppStrings.complaintSelectCategory,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                decoration: _inputDecoration(),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c.$1,
                    child: Text(c.$2,
                        style: theme.textTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null
                    ? AppStrings.complaintSelectCategory
                    : null,
              ),

              AppSpacing.h16,

              // Title
              Text(AppStrings.complaintTitle,
                  style: theme.textTheme.labelLarge),
              AppSpacing.h8,
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDecoration(
                    hint: AppStrings.complaintTitle),
                style: theme.textTheme.bodyMedium,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.complaintEnterTitle
                    : null,
              ),

              AppSpacing.h16,

              // Description
              Text(AppStrings.complaintDescription,
                  style: theme.textTheme.labelLarge),
              AppSpacing.h8,
              TextFormField(
                controller: _descCtrl,
                decoration: _inputDecoration(
                    hint: AppStrings.complaintDescription),
                style: theme.textTheme.bodyMedium,
                maxLines: 5,
                minLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.complaintEnterDesc
                    : null,
              ),

              AppSpacing.h16,

              // Attachments
              Text(AppStrings.complaintAttachments,
                  style: theme.textTheme.labelLarge),
              AppSpacing.h8,
              _AttachmentRow(ctrl: ctrl),

              AppSpacing.h32,

              // Submit
              Obx(
                () => CustomButton(
                  text: ctrl.isSubmitting.value
                      ? AppStrings.complaintSubmitting
                      : AppStrings.complaintSubmit,
                  onPressed: () {
                    if (!ctrl.isSubmitting.value) _submit(ctrl);
                  },
                  isLoading: ctrl.isSubmitting.value,
                ),
              ),

              AppSpacing.h24,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.paddingAll12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );

  Future<void> _submit(ComplaintController ctrl) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ctrl.submitComplaint(
      category: _selectedCategory!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    if (ok) {
      Get.back();
      SnackbarHelper.showGetSuccess(AppStrings.complaintSubmitSuccess);
    }
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.ctrl});
  final ComplaintController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Existing images
            ...ctrl.pickedImages.asMap().entries.map((entry) {
            return Padding(
              padding: AppSpacing.paddingOnly(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radius10),
                    child: Image.file(
                      File(entry.value.path),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => ctrl.removeImage(entry.key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        padding: AppSpacing.paddingAll3,
                        child: const Icon(Icons.close,
                            size: 12, color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add photo button (max 3)
          if (ctrl.pickedImages.length < 3)
            GestureDetector(
              onTap: ctrl.pickImage,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radius10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary, size: 24),
                    AppSpacing.h4,
                    Text(
                      AppStrings.complaintAddPhoto,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
