import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typographic hierarchy for SmartFrost.
///
/// Uses [GoogleFonts.plusJakartaSans] for modern, highly-legible
/// enterprise and operational mobile interfaces.
abstract final class AppTypography {
  static TextStyle get _base => GoogleFonts.plusJakartaSans();

  /// Overline/Kicker text (e.g., "DISTRIBUTOR B")
  static TextStyle get overline => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.primary,
  );

  /// Main screen title (e.g., "Penerimaan ikan")
  static TextStyle get pageTitle => _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Subtitle below screen title (e.g., "Periksa data batch sebelum...")
  static TextStyle get pageSubtitle => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Section headers (e.g., "Perlu diperiksa")
  static TextStyle get sectionTitle => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Hero big stat numbers (e.g., "1 batch" in hero card)
  static TextStyle get heroStat => _base.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.textInverted,
  );

  /// Secondary stat numbers (e.g., "1", "0" in metric cards)
  static TextStyle get metricStat => _base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Metric label below number (e.g., "Menunggu", "Diterima")
  static TextStyle get metricLabel => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Card primary title (e.g., "Scan QR penerimaan", "Kerapu • 85 kg")
  static TextStyle get cardTitle => _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Card secondary text (e.g., "Bahari Sejahtera")
  static TextStyle get cardSubtitle => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Monospace or batch code identifier (e.g., "SFR-PKP-240601")
  static TextStyle get batchCode => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  /// Badges and pills (e.g., "Menunggu periksa", "1 batch")
  static TextStyle get badge =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2);

  /// General body regular
  static TextStyle get body => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// General body small
  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Footnotes, sync status, and disclaimer captions
  static TextStyle get caption => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );
}
