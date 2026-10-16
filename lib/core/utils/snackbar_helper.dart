//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';

class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius8),
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius8),
        ),
      ),
    );
  }

  static void showGetSuccess(String message, {BuildContext? context}) {
    final targetContext = context ?? Get.context;
    if (targetContext != null && targetContext.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(targetContext);
      if (messenger != null) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: Theme.of(targetContext).textTheme.bodyMedium?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius8),
            ),
          ),
        );
        return;
      }
    }

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.snackbar(
      AppStrings.appName,
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.surface,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 1500),
      animationDuration: const Duration(milliseconds: 250),
      margin: AppSpacing.paddingAll16,
      borderRadius: AppSpacing.radius12,
    );
  }

  static void showGetError(String message, {BuildContext? context}) {
    final targetContext = context ?? Get.context;
    if (targetContext != null && targetContext.mounted) {
      final messenger = ScaffoldMessenger.maybeOf(targetContext);
      if (messenger != null) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: Theme.of(targetContext).textTheme.bodyMedium?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius8),
            ),
          ),
        );
        return;
      }
    }

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.snackbar(
      AppStrings.appName,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.surface,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 1500),
      animationDuration: const Duration(milliseconds: 250),
      margin: AppSpacing.paddingAll16,
      borderRadius: AppSpacing.radius12,
    );
  }
}
