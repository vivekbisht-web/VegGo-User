import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import '../controllers/chat_controller.dart';

class ChatRatingPanel extends StatelessWidget {
  final ChatController controller;

  const ChatRatingPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      return Padding(
        padding: AppSpacing.paddingVertical8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.chatRatingTitle, style: theme.textTheme.titleSmall),
            Wrap(
              children: List.generate(5, (index) {
                final value = index + 1;
                final selected =
                    value <= (controller.selectedRating.value ?? 0);
                return Semantics(
                  button: true,
                  selected: controller.selectedRating.value == value,
                  label: AppStrings.chatStarLabel(value),
                  child: IconButton(
                    onPressed: controller.isSendingRating.value
                        ? null
                        : () => controller.selectRating(value),
                    icon: Icon(
                      selected ? Icons.star : Icons.star_border,
                      color: AppColors.ratingStar,
                    ),
                  ),
                );
              }),
            ),
            if (controller.selectedRating.value != null)
              Wrap(
                spacing: AppSpacing.radius8,
                runSpacing: AppSpacing.radius8,
                children: controller.ratingTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: controller.selectedTags.contains(tag),
                        onSelected: controller.isSendingRating.value
                            ? null
                            : (_) => controller.toggleTag(tag),
                      ),
                    )
                    .toList(),
              ),
            if (controller.ratingError.value.isNotEmpty)
              Padding(
                padding: AppSpacing.paddingVertical8,
                child: Text(
                  controller.ratingError.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.isSendingRating.value
                    ? null
                    : () => controller.submitRating(skip: true),
                child: const Text(AppStrings.chatRatingSkip),
              ),
            ),
            CustomButton(
              text: AppStrings.chatRatingSubmit,
              onPressed: () => controller.submitRating(),
              isLoading: controller.isSendingRating.value,
            ),
          ],
        ),
      );
    });
  }
}
