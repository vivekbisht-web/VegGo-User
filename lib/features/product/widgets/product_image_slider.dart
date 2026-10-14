//
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_image_view.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final ValueChanged<int>? onPageChanged;

  const ProductImageSlider({
    super.key,
    required this.imageUrls,
    this.onPageChanged,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant ProductImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls.isNotEmpty &&
        _currentIndex >= widget.imageUrls.length) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius20),
        child: Padding(
          padding: AppSpacing.productImagePadding,
          child: const CustomImageView(
            imageUrl: '',
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius20),
        child: Padding(
          padding: AppSpacing.productImagePadding,
          child: CustomImageView(
            imageUrl: widget.imageUrls.first,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    final hasMultiple = widget.imageUrls.length > 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius20),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: AppSpacing.productImagePadding,
                child: CustomImageView(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          if (hasMultiple)
            Positioned(
              bottom: AppSpacing.radius12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) {
                    final isActive = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: AppSpacing.paddingHorizontal2_5,
                      height: AppSpacing.sliderDotHeight,
                      width: isActive
                          ? AppSpacing.sliderDotActiveWidth
                          : AppSpacing.sliderDotInactiveWidth,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.chipBorder,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.sliderDotRadius,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (hasMultiple)
            Positioned(
              bottom: AppSpacing.radius12,
              right: AppSpacing.radius12,
              child: Container(
                padding: AppSpacing.sliderBadgePadding,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  border: Border.all(color: AppColors.chipBorder, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_currentIndex + 1}${AppStrings.slash}${widget.imageUrls.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
