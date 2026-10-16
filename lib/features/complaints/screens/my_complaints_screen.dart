//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_app_bar.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/routes/app_routes.dart';
import '../controllers/complaint_controller.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complaint_shimmer.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  static const _filters = [
    ('', AppStrings.complaintFilterAll),
    ('PENDING', AppStrings.complaintFilterPending),
    ('RESOLVED', AppStrings.complaintFilterResolved),
    ('REOPENED', AppStrings.complaintFilterReopened),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ComplaintController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.fileComplaint),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.complaintRaiseNew,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          _FilterBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const ComplaintListShimmer();
              }

              if (ctrl.hasError.value) {
                return _ErrorState(ctrl: ctrl);
              }

              if (ctrl.complaints.isEmpty) {
                return _EmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ctrl.loadComplaints(),
                child: ListView.builder(
                  padding: AppSpacing.paddingAll16,
                  itemCount: ctrl.complaints.length,
                  itemBuilder: (_, i) =>
                      ComplaintCard(complaint: ctrl.complaints[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.ctrl});
  final ComplaintController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: AppSpacing.paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MyComplaintsScreen._filters.map((f) {
              final active = ctrl.activeFilter.value == f.$1;
              return Padding(
                padding: AppSpacing.paddingOnly(right: 8),
                child: ChoiceChip(
                  label: Text(f.$2),
                  selected: active,
                  onSelected: (_) => ctrl.setFilter(f.$1),
                  selectedColor: AppColors.primary,
                  labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: active ? AppColors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.chipBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius20),
                    side: BorderSide(
                      color: active ? AppColors.primary : AppColors.borderLight,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAll32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            AppSpacing.h16,
            Text(
              AppStrings.noComplaintsYet,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.h8,
            Text(
              AppStrings.noComplaintsDesc,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.h24,
            CustomButton(
              text: AppStrings.complaintRaiseNew,
              onPressed: () => Get.toNamed(AppRoutes.fileComplaint),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.ctrl});
  final ComplaintController ctrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error,
          ),
          AppSpacing.h12,
          Text(
            AppStrings.complaintLoadFailed,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.h16,
          TextButton(
            onPressed: () => ctrl.loadComplaints(),
            child: Text(
              AppStrings.tryAgain,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
