import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class ChatContextBar extends StatelessWidget {
  final Map<String, dynamic> contextData;
  final bool enabled;
  final VoidCallback onChangeOrder;

  const ChatContextBar({
    super.key,
    required this.contextData,
    required this.enabled,
    required this.onChangeOrder,
  });

  @override
  Widget build(BuildContext context) {
    final orderNumber =
        contextData['orderNumber']?.toString() ??
        contextData['orderId']?.toString() ??
        '';
    final statusLabel = contextData['statusLabel']?.toString() ?? '';
    final details = [
      orderNumber,
      statusLabel,
    ].where((value) => value.isNotEmpty).join(' · ');

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: AppSpacing.paddingHorizontal12,
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
          AppSpacing.w8,
          Expanded(
            child: Text(
              '${AppStrings.chatTalkingAbout} $details',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: enabled ? onChangeOrder : null,
            child: const Text(AppStrings.chatChangeOrder),
          ),
        ],
      ),
    );
  }
}
