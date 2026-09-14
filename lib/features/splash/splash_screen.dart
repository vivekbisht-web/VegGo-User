//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';
import 'package:vegon_user/core/constants/app_images.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    final double logoSize = AppSpacing.screenWidth * 0.5;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: ((value - 0.5) * 2).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: CustomImageView(
            imageUrl: AppImages.logo,
            width: logoSize,
            fit: BoxFit.contain,
            isAsset: true,
          ),
        ),
      ),
    );
  }
}
