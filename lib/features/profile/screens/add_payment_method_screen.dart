import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onSaveCard() {
    if (_formKey.currentState?.validate() == true) {
      Get.back();
      Get.snackbar(
        AppStrings.success,
        AppStrings.paymentMethodSaved,
        backgroundColor: AppColors.success,
        colorText: AppColors.surface,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: AppStrings.addNewPayment,
        showCenterLogo: false,
        showActions: false,
        showCartButton: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.04),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                ],
                prefixIcon: Icons.credit_card,
                hintText: AppStrings.cardNumber,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.invalidCardNumber;
                  }
                  final clean = val.replaceAll(RegExp(r'\s+|-'), '');
                  if (clean.length < 13 ||
                      clean.length > 19 ||
                      !RegExp(r'^\d+$').hasMatch(clean)) {
                    return AppStrings.invalidCardNumber;
                  }
                  return null;
                },
              ),
              AppSpacing.responsiveHeight(0.02),

              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.cardHolderName,
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.invalidCardHolder;
                  }
                  return null;
                },
              ),
              AppSpacing.responsiveHeight(0.02),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _expiryController,
                      hintText: AppStrings.expiryDate,
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return AppStrings.invalidExpiry;
                        }
                        final parts = val.trim().split('/');
                        if (parts.length != 2) {
                          return AppStrings.invalidExpiry;
                        }
                        final month = int.tryParse(parts[0]);
                        final year = int.tryParse(parts[1]);
                        if (month == null ||
                            year == null ||
                            month < 1 ||
                            month > 12) {
                          return AppStrings.invalidExpiry;
                        }
                        return null;
                      },
                    ),
                  ),
                  AppSpacing.responsiveWidth(0.03),
                  Expanded(
                    child: CustomTextField(
                      controller: _cvvController,
                      hintText: AppStrings.cvv,
                      keyboardType: TextInputType.number,
                      isPassword: true,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return AppStrings.invalidCvv;
                        }
                        final clean = val.trim();
                        if ((clean.length != 3 && clean.length != 4) ||
                            !RegExp(r'^\d+$').hasMatch(clean)) {
                          return AppStrings.invalidCvv;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.responsiveHeight(0.04),

              CustomButton(
                text: AppStrings.saveCard,
                onPressed: _onSaveCard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
