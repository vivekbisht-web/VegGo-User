//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';

class AiAssistantFab extends StatelessWidget {
  final double bottom;
  final double right;

  const AiAssistantFab({super.key, this.bottom = 68, this.right = 14});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: Material(
        color: AppColors.aiFloating,
        elevation: 7,
        shadowColor: Colors.black54,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 27,
                ),
                Positioned(
                  right: 0,
                  bottom: 1,
                  child: Container(
                    height: 15,
                    padding: AppSpacing.paddingHorizontal4,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    ),
                    child: Text(
                      'AI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.aiFloating,
                        fontWeight: FontWeight.w900,
                        fontSize: 7,
                        height: 1,
                      ),
                    ),
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
