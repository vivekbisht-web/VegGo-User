import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─────────────────────────────────────────────
  // Brand
  // ─────────────────────────────────────────────

  static const primary = Color(0xFF006A34);
  static const String primaryHex = '#006A34';
  static const secondary = Color(0xFFFDC003);

  // ─────────────────────────────────────────────
  // Surface / Background
  // ─────────────────────────────────────────────

  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;
  static const overlayLight = Color(0x1F000000);

  static const mintHeader = Color(0xFFDCF4DE);
  static const mintBadge = Color(0xFFC8E6C9);
  static const mintLight = Color(0xFFF1F8F3);
  static const mintIcon = Color(0xFFE2F3E7);

  // ─────────────────────────────────────────────
  // Text
  // ─────────────────────────────────────────────

  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);

  // ─────────────────────────────────────────────
  // Status
  // ─────────────────────────────────────────────

  static const error = Color(0xFFF44336);

  static const success = Color(0xFF2E7D32);
  static const successLight = Color(0xFF81C784);
  static const successBackground = Color(0xFFE8F5E9);

  static const warning = Color(0xFFFFC107);

  // ─────────────────────────────────────────────
  // Borders / Dividers
  // ─────────────────────────────────────────────

  static const border = Color(0xFFE0E0E0);
  static const borderLight = Color(0xFFEEEEEE);
  static const borderSubtle = Color(0xFFEEF2F0);

  // ─────────────────────────────────────────────
  // Product / Offers
  // ─────────────────────────────────────────────

  static const offerYellow = Color(0xFFFFD54F);
  static const discountGreen = Color(0xFF2E7D32);
  static const discountGreenDark = Color(0xFF1B5E20);

  static const saleYellow = Color(0xFFFFD600);
  static const saveOrange = Colors.orangeAccent;

  static const strikethrough = Color(0xFF9E9E9E);

  // ─────────────────────────────────────────────
  // Category / Chips
  // ─────────────────────────────────────────────

  static const chipBackground = Color(0xFFF4F6F8);
  static const chipBorder = Color(0xFFE5E7EB);

  static const categoryBackground = Colors.white;
  static const categoryBorder = Color(0xFFEEEEEE);
  static const activeCategoryBorder = primary;

  static const moreIconSlateLight = Color(0xFF8E9EB5);
  static const moreIconSlateDark = Color(0xFF63748E);
  static const moreIconLavender = Color(0xFFBDD2EF);
  static const moreIconGreen = Color(0xFF2E9E2A);

  // ─────────────────────────────────────────────
  // Product Combo
  // ─────────────────────────────────────────────

  static const comboPurpleBackground = Color(0xFFF6F0FF);
  static const comboPurpleBorder = Color(0xFFEAD8FF);
  static const comboPurpleBadge = Color(0xFFF3E8FF);
  static const comboPurpleText = Color(0xFF7E22CE);
  static const comboPurpleButton = Color(0xFF6B21A8);

  // ─────────────────────────────────────────────
  // Membership / Verification
  // ─────────────────────────────────────────────

  static const goldBackground = Color(0xFFFEF9E7);
  static const goldBorder = Color(0xFFFFE082);
  static const goldText = Color(0xFFB78103);

  static const verifiedBackground = successBackground;
  static const verifiedText = success;

  // ─────────────────────────────────────────────
  // Rating / Stats
  // ─────────────────────────────────────────────

  static const ratingStar = Color(0xFFFFB800);
  static const statsBorder = Color(0xFFFFF3CD);

  // ─────────────────────────────────────────────
  // Header / Banner
  // ─────────────────────────────────────────────

  static const darkHeaderStart = Color(0xFF032B14);
  static const darkHeaderEnd = Color(0xFF0B5226);

  static const bannerPastelGreen = Color(0xFFECF8EE);
  static const bannerDarkGreen = Color(0xFF0E5C23);
  static const badgeDarkGreen = Color(0xFF135A22);

  // ─────────────────────────────────────────────
  // Misc Feature Colors
  // ─────────────────────────────────────────────

  static const purpleTag = Color(0xFF7C4DFF);
  static const orangeFlame = Color(0xFFFF6D00);
  static const aiFloating = Color(0xFF00A859);
  static const sidebarSelected = Color(0xFFEAF5EC);

  // ─────────────────────────────────────────────
  // Quantity / Overlay
  // ─────────────────────────────────────────────

  static const quantityBorder = Color(0xFFD1D5DB);
  static const overlayDark = Color(0xB3000000);
}
