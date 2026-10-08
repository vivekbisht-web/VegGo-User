import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const double _avatarSize = 32;
  static const double _avatarGap = 8;

  static final Color _greenDark = Color.lerp(
    AppColors.primary,
    Colors.black,
    0.22,
  )!;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BotAvatar(size: 40, showOnline: true),
            AppSpacing.w12,
            Flexible(
              child: Text(
                AppStrings.chatTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.chipBorder.withValues(alpha: 0.6),
          ),
        ),
      ),
      body: ColoredBox(
        color: AppColors.background,
        child: Column(
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount:
                      entries.length + (controller.isLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value && index == 0) {
                      return _typingIndicator(context);
                    }
                    final offset = controller.isLoading.value ? 1 : 0;
                    final entryIndex = entries.length - 1 - (index - offset);
                    final entry = entries[entryIndex];
                    return _FadeSlide(
                      key: ValueKey(entryIndex),
                      child: _entry(
                        context,
                        entry,
                        canSend: canSend,
                        rated: rated,
                        showActions:
                            entryIndex == entries.length - 1 &&
                            !controller.isLoading.value,
                      ),
                    );
                  },
                );
              }),
            ),
            _composer(context),
          ],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, ChatEntry entry) {
    final fromCustomer = entry.fromCustomer;
    final textTheme = Theme.of(context).textTheme;
    final maxWidth =
        MediaQuery.sizeOf(context).width * AppSpacing.chatBubbleWidthRatio;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fromCustomer ? null : AppColors.surface,
        gradient: fromCustomer
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, _greenDark],
              )
            : null,
        border: fromCustomer
            ? null
            : Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(fromCustomer ? 20 : 5),
          bottomRight: Radius.circular(fromCustomer ? 5 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: (fromCustomer ? AppColors.primary : AppColors.black)
                .withValues(alpha: fromCustomer ? 0.28 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SelectableText(
        entry.text,
        style: textTheme.bodyMedium?.copyWith(
          color: fromCustomer ? AppColors.surface : AppColors.textPrimary,
          height: 1.4,
          fontSize: 14,
        ),
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
    final fromCustomer = entry.fromCustomer;

    final extras = <Widget>[
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
        TextButton.icon(
          onPressed: canSend ? controller.retryLastRequest : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text(AppStrings.chatRetry),
        ),
      if (showActions && rated)
        CustomButton(
          text: AppStrings.chatStartNew,
          onPressed: () => controller.startNewChat(),
          backgroundColor: AppColors.primary,
        ),
    ];

    return Column(
      crossAxisAlignment: fromCustomer
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: fromCustomer
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!fromCustomer) ...[
                const _BotAvatar(size: _avatarSize),
                const SizedBox(width: _avatarGap),
              ],
              Flexible(child: _bubble(context, entry)),
            ],
          ),
        ),
        if (extras.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: fromCustomer ? 0 : _avatarSize + _avatarGap,
              bottom: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: extras,
            ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return Material(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            shape: StadiumBorder(
              side: BorderSide(
                color: enabled
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.chipBorder,
              ),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: enabled ? () => controller.chooseOption(option) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: enabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _typingIndicator(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _BotAvatar(size: _avatarSize),
        const SizedBox(width: _avatarGap),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _TypingDots(),
              AppSpacing.w8,
              Text(
                AppStrings.chatLoading,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _composer(BuildContext context) {
    return Obx(() {
      final canSend = controller.canSend;
      final textTheme = Theme.of(context).textTheme;
      final inputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      );

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.chatComposerPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.rateLimitSeconds.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      AppStrings.chatWaitSeconds(
                        controller.rateLimitSeconds.value,
                      ),
                      style: textTheme.bodySmall?.copyWith(
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
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.primary.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.fromLTRB(20, 14, 6, 14),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    disabledBorder: inputBorder,
                    focusedBorder: inputBorder.copyWith(
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Ink(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: canSend ? null : AppColors.chipBorder,
                            gradient: canSend
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppColors.primary, _greenDark],
                                  )
                                : null,
                            boxShadow: canSend
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: canSend ? () => _submit(input.text) : null,
                            child: const Tooltip(
                              message: AppStrings.chatSend,
                              child: Icon(
                                Icons.send_rounded,
                                color: AppColors.surface,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

class _BotAvatar extends StatelessWidget {
  final double size;
  final bool light;
  final bool showOnline;

  const _BotAvatar({
    required this.size,
    this.light = false,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(AppColors.primary, Colors.black, 0.22)!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: light ? AppColors.surface : null,
              gradient: light
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, dark],
                    ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: light ? AppColors.primary : AppColors.surface,
              size: size * 0.56,
            ),
          ),
          if (showOnline)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Widget child;
  const _FadeSlide({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_controller.value - i * 0.18) % 1.0;
            final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Container(
              width: 7,
              height: 7,
              margin: EdgeInsets.only(right: i == 2 ? 0 : 4),
              transform: Matrix4.translationValues(0, -3 * t, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.35 + 0.65 * t),
              ),
            );
          }),
        );
      },
    );
  }
}
