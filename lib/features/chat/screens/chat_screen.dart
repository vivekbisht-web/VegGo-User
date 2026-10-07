import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import 'package:vegon_user/features/chat/controllers/chat_controller.dart';
import 'package:vegon_user/features/chat/models/chat_models.dart';
import 'package:vegon_user/features/chat/widgets/chat_context_bar.dart';
import 'package:vegon_user/features/chat/widgets/chat_order_card.dart';
import 'package:vegon_user/features/chat/widgets/chat_rating_panel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.find<ChatController>();
  late final TextEditingController input;

  @override
  void initState() {
    super.initState();
    input = TextEditingController();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppStrings.chatTitle),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(() {
            final contextData = controller.context;
            if (contextData == null) return const SizedBox.shrink();
            return ChatContextBar(
              contextData: contextData,
              enabled: controller.canSend,
              onChangeOrder: controller.changeOrder,
            );
          }),
          Expanded(
            child: Obx(() {
              final entries = controller.entries;
              final canSend = controller.canSend;
              final rated = controller.rated.value;
              return ListView.builder(
                reverse: true,
                padding: AppSpacing.paddingAll16,
                itemCount:
                    entries.length + (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (controller.isLoading.value && index == 0) {
                    return _typingIndicator(context);
                  }
                  final offset = controller.isLoading.value ? 1 : 0;
                  final entryIndex = entries.length - 1 - (index - offset);
                  final entry = entries[entryIndex];
                  return _entry(
                    context,
                    entry,
                    canSend: canSend,
                    rated: rated,
                    showActions:
                        entryIndex == entries.length - 1 &&
                        !controller.isLoading.value,
                  );
                },
              );
            }),
          ),
          _composer(context),
        ],
      ),
    );
  }

  Widget _entry(
    BuildContext context,
    ChatEntry entry, {
    required bool canSend,
    required bool rated,
    required bool showActions,
  }) {
    final reply = entry.reply;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: entry.fromCustomer
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: entry.fromCustomer
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.sizeOf(context).width *
                  AppSpacing.chatBubbleWidthRatio,
            ),
            margin: AppSpacing.paddingVertical8,
            padding: AppSpacing.paddingAll12,
            decoration: BoxDecoration(
              color: entry.fromCustomer
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
            ),
            child: SelectableText(
              entry.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: entry.fromCustomer
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        if (reply != null)
          ...reply.orders.map(
            (order) => ChatOrderCard(
              order: order,
              enabled: showActions && canSend,
              onTap: () => controller.chooseOrder(order),
            ),
          ),
        if (showActions && reply != null && !reply.ratingPrompt)
          _options(context, reply.options, enabled: canSend),
        if (showActions && reply?.ratingPrompt == true && !rated)
          ChatRatingPanel(controller: controller),
        if (showActions && entry.retryable)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: canSend ? controller.retryLastRequest : null,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.chatRetry),
            ),
          ),
        if (showActions && rated)
          CustomButton(
            text: AppStrings.chatStartNew,
            onPressed: () => controller.startNewChat(),
            backgroundColor: AppColors.primary,
          ),
      ],
    );
  }

  Widget _options(
    BuildContext context,
    List<ChatOption> options, {
    required bool enabled,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.radius8,
      runSpacing: AppSpacing.radius8,
      children: options.map((option) {
        return ActionChip(
          label: Text(option.label),
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: enabled ? AppColors.primary : AppColors.textSecondary,
          ),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          onPressed: enabled ? () => controller.chooseOption(option) : null,
        );
      }).toList(),
    );
  }

  Widget _typingIndicator(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: AppSpacing.paddingVertical8,
      child: Text(
        AppStrings.chatLoading,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
    ),
  );

  Widget _composer(BuildContext context) {
    return Obx(() {
      final canSend = controller.canSend;
      return SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.chatComposerPadding,
          child: Column(
            children: [
              if (controller.rateLimitSeconds.value > 0)
                Padding(
                  padding: AppSpacing.paddingVertical4,
                  child: Text(
                    AppStrings.chatWaitSeconds(
                      controller.rateLimitSeconds.value,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              CustomTextField(
                controller: input,
                enabled: canSend,
                hintText: AppStrings.chatInputHint,
                maxLength: 200,
                textInputAction: TextInputAction.send,
                onSubmitted: _submit,
                decoration: InputDecoration(
                  hintText: AppStrings.chatInputHint,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  contentPadding: AppSpacing.paddingHorizontal16,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    tooltip: AppStrings.chatSend,
                    onPressed: canSend ? () => _submit(input.text) : null,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _submit(String value) async {
    final accepted = await controller.sendText(value);
    if (accepted && mounted) input.clear();
  }
}
