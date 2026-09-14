//
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_colors.dart';

class PermissionHandlerService {
  static Future<bool> handleLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.locationPermissionDenied,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
      return false;
    }

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.locationPermissionDeniedForever,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: Text(
            AppStrings.settings,
            style: Theme.of(Get.context!).textTheme.labelLarge?.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return false;
    }

    return false;
  }
}
