//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/utils/snackbar_helper.dart';
import '../controllers/complaint_controller.dart';
import '../models/complaint_model.dart';
import '../widgets/complaint_status_badge.dart';
import '../widgets/complaint_shimmer.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  const ComplaintDetailsScreen({super.key});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  String? _complaintId;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<ComplaintController>();
    final args = Get.arguments;

    if (args is ComplaintModel) {
      _complaintId = args.id;
      ctrl.selected.value = args;
    } else if (args is String) {
      _complaintId = args;
    }

    if (_complaintId != null && _complaintId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.loadDetails(_complaintId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ComplaintController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: Obx(() {
        if (ctrl.isLoadingDetails.value && ctrl.selected.value == null) {
          return const ComplaintDetailsShimmer();
        }

        final complaint = ctrl.selected.value;
        if (complaint == null) {
          return Center(
            child: Text(
              AppStrings.complaintLoadFailed,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return _Body(complaint: complaint, ctrl: ctrl);
      }),
    );
  }
}


class _Body extends StatelessWidget {
  const _Body({required this.complaint, required this.ctrl});
  final ComplaintModel complaint;
  final ComplaintController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket header card
          _InfoCard(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${AppStrings.complaintTicketNumber}${complaint.ticketNumber}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ComplaintStatusBadge(status: complaint.status),
                ],
              ),
              AppSpacing.h12,
              Text(
                complaint.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              AppSpacing.h4,
              Text(
                _categoryLabel(complaint.category),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
              AppSpacing.h12,
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _DateChip(
                    icon: Icons.calendar_today_outlined,
                    label: '${AppStrings.complaintCreatedOn} ${_fmt(complaint.createdAt)}',
                  ),
                  _DateChip(
                    icon: Icons.update_rounded,
                    label: '${AppStrings.complaintUpdatedOn} ${_fmt(complaint.updatedAt)}',
                  ),
                ],
              ),
            ],
          ),

          AppSpacing.h12,

          // Description
          _InfoCard(
            children: [
              Text(AppStrings.complaintDescription,
                  style: theme.textTheme.labelLarge),
              AppSpacing.h8,
              Text(
                complaint.description,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),

          // Admin note (if any)
          if (complaint.adminNote != null &&
              complaint.adminNote!.isNotEmpty) ...[
            AppSpacing.h12,
            _InfoCard(
              color: AppColors.mintLight,
              children: [
                Row(
                  children: [
                    const Icon(Icons.support_agent_rounded,
                        color: AppColors.primary, size: 18),
                    AppSpacing.w8,
                    Text('Support Note',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: AppColors.primary)),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  complaint.adminNote!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          ],

          // Reopen button (only for RESOLVED + canReopen)
          if (complaint.status.toUpperCase() == 'RESOLVED' &&
              complaint.canReopen) ...[
            AppSpacing.h24,
            Obx(
              () => CustomButton(
                text: AppStrings.complaintReopenBtn,
                isLoading: ctrl.isReopening.value,
                onPressed: () {
                  if (!ctrl.isReopening.value) {
                    _showReopenSheet(context, ctrl, complaint.id);
                  }
                },
              ),
            ),
          ],

          AppSpacing.h24,
        ],
      ),
    );
  }

  void _showReopenSheet(
      BuildContext context, ComplaintController ctrl, String id) {
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radius24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radius2),
                ),
              ),
            ),
            AppSpacing.h16,
            Text(
              AppStrings.complaintReopenBtn,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.h4,
            Text(
              AppStrings.complaintReopenReason,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.h16,
            TextField(
              controller: reasonCtrl,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.complaintReopenReasonHint,
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: AppSpacing.paddingAll12,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radius12),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radius12),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radius12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            AppSpacing.h20,
            Obx(
              () => CustomButton(
                text: AppStrings.complaintReopenSubmit,
                isLoading: ctrl.isReopening.value,
                onPressed: () async {
                  if (ctrl.isReopening.value) return;
                  final reason = reasonCtrl.text.trim();
                  if (reason.isEmpty) {
                    SnackbarHelper.showGetError(
                      AppStrings.complaintEnterReopenReason,
                      context: ctx,
                    );
                    return;
                  }
                  final ok = await ctrl.reopenComplaint(id, reason);
                  if (ok && ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'ORDER_ISSUE':
        return AppStrings.catOrderIssue;
      case 'PAYMENT_ISSUE':
        return AppStrings.catPaymentIssue;
      case 'DELIVERY_ISSUE':
        return AppStrings.catDeliveryIssue;
      case 'PRODUCT_QUALITY':
        return AppStrings.catProductQuality;
      case 'APP_ISSUE':
        return AppStrings.catAppIssue;
      case 'ACCOUNT_ISSUE':
        return AppStrings.catAccountIssue;
      case 'VENDOR_BEHAVIOR':
        return AppStrings.catVendorBehavior;
      case 'DELIVERY_BEHAVIOR':
        return AppStrings.catDeliveryBehavior;
      default:
        return AppStrings.catOther;
    }
  }

}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children, this.color});
  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        AppSpacing.w4,
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
