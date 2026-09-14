//
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';

import '../widgets/custom_image_view.dart';

class AnimationOverlayHelper {
  static void showRocketAddToCart(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 2500),
          curve: Curves.easeInOutCubic,
          onEnd: () {
            overlayEntry.remove();
            onComplete();
          },
          builder: (context, value, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            final x = -150 + (screenWidth + 300) * value;

            final baseY = screenHeight - (screenHeight + 300) * value;
            final y = baseY + sin(value * pi * 3) * 60;

            double scale = 1.0;
            if (value < 0.2) {
              scale = (value / 0.2).clamp(0.0, 1.0);
            } else if (value > 0.8) {
              scale = 1.0 + ((value - 0.8) * 5);
            }

            double opacity = 1.0;
            if (value < 0.1) {
              opacity = (value / 0.1).clamp(0.0, 1.0);
            } else if (value > 0.9) {
              opacity = (1.0 - ((value - 0.9) * 10)).clamp(0.0, 1.0);
            }

            final tiltAngle = -pi / 8 + (cos(value * pi * 3) * 0.1);

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: tiltAngle,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: const Icon(
                      Icons.rocket_launch,
                      color: AppColors.primary,
                      size: 80,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(overlayEntry);
  }

  static void showCenterPopupAnimation(
    BuildContext context, {
    required String gifUrl,
    required IconData fallbackIcon,
    required Color iconColor,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 3000),
            curve: Curves.elasticOut,
            onEnd: () {
              Future.delayed(const Duration(milliseconds: 500), () {
                overlayEntry.remove();
                if (onComplete != null) onComplete();
              });
            },
            builder: (context, value, child) {
              final scale = value < 0.8 ? value : 1.0 + (value - 0.8) * 2;
              final opacity = value < 0.8 ? 1.0 : 1.0 - (value - 0.8) * 5;

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    padding: AppSpacing.paddingAll20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CustomImageView(
                      imageUrl: gifUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}
