//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';

class ProductOffersSection extends StatelessWidget {
  const ProductOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferData(
        icon: Icons.discount_outlined,
        title: AppStrings.flat20Off,
        subtitle1: AppStrings.codeVeggo20,
        subtitle2: AppStrings.minOrder199,
      ),
      _OfferData(
        icon: Icons.account_balance_outlined,
        title: AppStrings.instantDiscount10,
        subtitle1: AppStrings.onAllUpi,
        subtitle2: AppStrings.minOrder299,
      ),
      _OfferData(
        icon: Icons.inventory_2_outlined,
        title: AppStrings.freeDeliveryCaps,
        subtitle1: AppStrings.onOrdersAbove299,
        subtitle2: '',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHorizontal16,
          child: Text(
            AppStrings.offersForYou,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
        AppSpacing.h10,
        SizedBox(
          height: 72,
          child: ListView.separated(
            padding: AppSpacing.paddingHorizontal16,
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (context, index) => AppSpacing.w10,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Container(
                width: 210,
                padding: AppSpacing.paddingAll10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  border: Border.all(
                    color: AppColors.mintBadge.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(offer.icon, size: 20, color: AppColors.primary),
                    AppSpacing.w8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 11,
                                ),
                          ),
                          AppSpacing.h2,
                          Text(
                            offer.subtitle1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 9.5,
                                ),
                          ),
                          if (offer.subtitle2.isNotEmpty)
                            Text(
                              offer.subtitle2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 8.5,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OfferData {
  final IconData icon;
  final String title;
  final String subtitle1;
  final String subtitle2;

  const _OfferData({
    required this.icon,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
  });
}
