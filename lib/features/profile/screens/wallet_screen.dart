import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/wallet_controller.dart';
import '../models/wallet_models.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.onRefresh,
        child: Padding(
          padding: AppSpacing.paddingResponsiveAll(0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(context, controller),
              AppSpacing.responsiveHeight(0.03),
              _buildHeaderAndFilters(context, controller),
              AppSpacing.responsiveHeight(0.015),
              Expanded(
                child: _buildTransactionList(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletController controller) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingResponsiveAll(0.06),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppSpacing.screenWidth * 0.04,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.walletBalance,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.surface,
                ),
          ),
          AppSpacing.h8,
          Obx(() {
            if (controller.isBalanceLoading.value) {
              return SizedBox(
                height: AppSpacing.screenWidth * 0.09,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: AppSpacing.radius20,
                    height: AppSpacing.radius20,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSpacing.radius2,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              );
            }
            return Text(
              '${AppStrings.currencySymbol}${controller.balance.value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
            );
          }),
          AppSpacing.responsiveHeight(0.02),
          CustomButton(
            text: AppStrings.addMoney,
            icon: Icons.add,
            backgroundColor: AppColors.surface,
            textColor: AppColors.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndFilters(
      BuildContext context, WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentTransactions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        AppSpacing.h12,
        Obx(
          () => Row(
            children: [
              _buildFilterChip(
                context,
                label: AppStrings.allFilter,
                filterKey: AppStrings.filterAll,
                isSelected:
                    controller.selectedFilter.value == AppStrings.filterAll,
                onTap: () => controller.changeFilter(AppStrings.filterAll),
              ),
              AppSpacing.w8,
              _buildFilterChip(
                context,
                label: AppStrings.creditFilter,
                filterKey: AppStrings.filterCredit,
                isSelected:
                    controller.selectedFilter.value == AppStrings.filterCredit,
                onTap: () => controller.changeFilter(AppStrings.filterCredit),
              ),
              AppSpacing.w8,
              _buildFilterChip(
                context,
                label: AppStrings.debitFilter,
                filterKey: AppStrings.filterDebit,
                isSelected:
                    controller.selectedFilter.value == AppStrings.filterDebit,
                onTap: () => controller.changeFilter(AppStrings.filterDebit),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterKey,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingSymmetric(
          horizontal: AppSpacing.radius16,
          vertical: AppSpacing.radius8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, WalletController controller) {
    return Obx(() {
      if (controller.isTransactionsLoading.value &&
          controller.transactions.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.failedToLoadTransactions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.h12,
              CustomButton(
                text: AppStrings.retry,
                onPressed: () => controller.fetchTransactions(refresh: true),
              ),
            ],
          ),
        );
      }

      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: AppSpacing.screenWidth * 0.14,
                color: AppColors.textSecondary,
              ),
              AppSpacing.h12,
              Text(
                AppStrings.noTransactionsFound,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              AppSpacing.h6,
              Text(
                AppStrings.noTransactionsDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.transactions.length +
            (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.transactions.length) {
            return Padding(
              padding: AppSpacing.paddingResponsiveAll(0.02),
              child: const Center(
                child: SizedBox(
                  width: AppSpacing.radius20,
                  height: AppSpacing.radius20,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.radius2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final item = controller.transactions[index];
          return _buildTransactionTile(context, item);
        },
      );
    });
  }

  Widget _buildTransactionTile(
      BuildContext context, WalletTransactionItem item) {
    return Container(
      margin: AppSpacing.paddingOnly(bottom: AppSpacing.screenWidth * 0.025),
      padding: AppSpacing.paddingResponsiveAll(0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.screenWidth * 0.03),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.paddingAll8,
            decoration: BoxDecoration(
              color: item.isCredit
                  ? AppColors.successBackground
                  : AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: item.isCredit ? AppColors.primary : AppColors.error,
              size: AppSpacing.radius20,
            ),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.referenceId != null && item.referenceId!.isNotEmpty) ...[
                  AppSpacing.h4,
                  Text(
                    '${AppStrings.referencePrefix}${item.referenceId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                AppSpacing.h4,
                Text(
                  item.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          AppSpacing.w8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isCredit ? AppStrings.plusSymbol : AppStrings.minusSymbol}${AppStrings.currencySymbol}${item.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          item.isCredit ? AppColors.primary : AppColors.error,
                    ),
              ),
              if (item.balanceAfter != null) ...[
                AppSpacing.h4,
                Text(
                  '${AppStrings.currencySymbol}${item.balanceAfter!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
