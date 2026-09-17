//
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSpacing {
  AppSpacing._();

  static double get screenWidth => Get.width;
  static double get screenHeight => Get.height;

  static const SizedBox h2 = SizedBox(height: 2);
  static const SizedBox h4 = SizedBox(height: 4);
  static const SizedBox h6 = SizedBox(height: 6);
  static const SizedBox h8 = SizedBox(height: 8);
  static const SizedBox h10 = SizedBox(height: 10);
  static const SizedBox h12 = SizedBox(height: 12);
  static const SizedBox h16 = SizedBox(height: 16);
  static const SizedBox h20 = SizedBox(height: 20);
  static const SizedBox h24 = SizedBox(height: 24);
  static const SizedBox h32 = SizedBox(height: 32);
  static const SizedBox h40 = SizedBox(height: 40);
  static const SizedBox h48 = SizedBox(height: 48);

  static const SizedBox w2 = SizedBox(width: 2);
  static const SizedBox w4 = SizedBox(width: 4);
  static const SizedBox w6 = SizedBox(width: 6);
  static const SizedBox w8 = SizedBox(width: 8);
  static const SizedBox w10 = SizedBox(width: 10);
  static const SizedBox w12 = SizedBox(width: 12);
  static const SizedBox w16 = SizedBox(width: 16);
  static const SizedBox w20 = SizedBox(width: 20);
  static const SizedBox w24 = SizedBox(width: 24);
  static const SizedBox w32 = SizedBox(width: 32);
  static const SizedBox w40 = SizedBox(width: 40);
  static const SizedBox w48 = SizedBox(width: 48);

  static Widget responsiveHeight(double percentage) =>
      SizedBox(height: Get.height * percentage);

  static Widget responsiveWidth(double percentage) =>
      SizedBox(width: Get.width * percentage);

  static Widget get sectionSpacer => SizedBox(height: Get.height * 0.03);

  static Widget get smallSpacer => SizedBox(height: Get.height * 0.02);

  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingAll4 = EdgeInsets.all(4);
  static const EdgeInsets paddingAll3 = EdgeInsets.all(3);
  static const EdgeInsets paddingHorizontal2_5 = EdgeInsets.symmetric(horizontal: 2.5);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(8);
  static const EdgeInsets paddingAll10 = EdgeInsets.all(10);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(24);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(32);

  static const EdgeInsets paddingHorizontal4 = EdgeInsets.symmetric(
    horizontal: 4,
  );
  static const EdgeInsets paddingHorizontal8 = EdgeInsets.symmetric(
    horizontal: 8,
  );
  static const EdgeInsets paddingHorizontal12 = EdgeInsets.symmetric(
    horizontal: 12,
  );
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(
    horizontal: 16,
  );
  static const EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(
    horizontal: 24,
  );

  static const EdgeInsets paddingVertical4 = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets paddingVertical12 = EdgeInsets.symmetric(
    vertical: 12,
  );
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(
    vertical: 16,
  );
  static const EdgeInsets paddingVertical24 = EdgeInsets.symmetric(
    vertical: 24,
  );

  static const double radius2 = 2.0;
  static const double radius4 = 4.0;
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius10 = 10.0;
  static const double radius12 = 12.0;
  static const double radius14 = 14.0;
  static const double radius16 = 16.0;
  static const double radius18 = 18.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;

  static const double bannerHeightMin = 120.0;
  static const double bannerHeightMax = 155.0;
  static const double bannerHeightRatio = 0.165;
  static const double bannerImageWidthRatio = 0.48;
  static const double bannerDotHeight = 3.5;
  static const double bannerDotActiveWidth = 12.0;
  static const double bannerDotInactiveWidth = 5.0;
  static const double bannerButtonHeight = 28.0;
  static const double bannerButtonWidth = 86.0;
  static const double bannerFontSizeBadge = 9.0;
  static const double bannerFontSizeTitle = 11.5;
  static const double bannerFontSizeSubtitle = 13.5;
  static const double bannerFontSizeInfo = 9.5;
  static const double bannerFontSizeButton = 10.5;
  static const EdgeInsets bannerPadding = EdgeInsets.fromLTRB(14.0, 8.0, 10.0, 10.0);
  static const EdgeInsets bannerBadgePadding = EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0);

  static const double categoryCardRadius = 16.0;
  static const double categoryCardAspectRatio = 0.85;
  static const double categoryCardImageHeight = 44.0;
  static const double categoryGridCrossAxisSpacing = 8.0;
  static const double categoryGridMainAxisSpacing = 8.0;
  static const double categoryFontSize = 11.5;
  static const double categoryMoreSquareSize = 13.0;
  static const double categoryMoreSquareRadius = 3.5;
  static const double categoryMoreSpacing = 3.5;
  static const double moreIconRotationAngle = 0.785398;
  static const EdgeInsets categoryCardPadding = EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0);

  static const double sectionHeaderTitleSize = 16.0;
  static const double sectionHeaderActionSize = 12.0;
  static const double sectionHeaderIconSize = 11.0;

  static const double dealCardWidth = 140.0;
  static const double dealCardHeight = 185.0;
  static const double storeCardWidth = 150.0;
  static const double storeCardHeight = 175.0;
  static const double addCircleButtonSize = 28.0;
  static const double quickActionHeight = 52.0;
  static const double quickActionIconSize = 24.0;
  static const double drawerAvatarSize = 58.0;
  static const double drawerIconSize = 20.0;
  static const double drawerCloseIconSize = 20.0;
  static const double drawerBadgeSize = 18.0;
  static const double drawerDividerIndent = 16.0;

  static EdgeInsets paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static EdgeInsets paddingResponsiveAll(double percentage) {
    return EdgeInsets.all(Get.width * percentage);
  }

  static EdgeInsets paddingResponsiveSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal > 0 ? Get.width * horizontal : 0.0,
      vertical: vertical > 0 ? Get.width * vertical : 0.0,
    );
  }

  static EdgeInsets paddingResponsiveHorizontal(double percentage) {
    return EdgeInsets.symmetric(horizontal: Get.width * percentage);
  }

  static EdgeInsets paddingResponsiveVertical(double percentage) {
    return EdgeInsets.symmetric(vertical: Get.width * percentage);
  }

  static EdgeInsets paddingResponsiveOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left > 0 ? Get.width * left : 0.0,
      right: right > 0 ? Get.width * right : 0.0,
      top: top > 0 ? Get.width * top : 0.0,
      bottom: bottom > 0 ? Get.width * bottom : 0.0,
    );
  }

  static EdgeInsets paddingOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  }

  static EdgeInsets paddingAll(double value) {
    return EdgeInsets.all(value);
  }

  static EdgeInsets paddingFromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}
