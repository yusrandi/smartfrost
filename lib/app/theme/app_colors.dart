import 'package:flutter/material.dart';

/// Semantic and brand design tokens for SmartFrost.
///
/// Designed with a cold-chain logistics aesthetic:
/// crisp white/light gray background, petrol/navy blues,
/// ocean teal primary accents, and subtle status indicators.
abstract final class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF0E8AA7); // Ocean teal
  static const Color primaryDark = Color(0xFF163E51); // Hero deep petrol navy
  static const Color primaryContainer = Color(0xFFE8F6F8); // Soft cyan/ice tint
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF095A6D);

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D7895);
  static const Color headerActionBg = Color(0xFFEAEFF2);
  static const Color avatarNavy = Color(0xFF112836);

  // Semantic Status: Warning / Pending
  static const Color warning = Color(0xFFD97706);
  static const Color warningText = Color(0xFF92400E);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color warningAccent = Color(0xFFE4A144);

  // Semantic Status: Success / Synced
  static const Color success = Color(0xFF059669);
  static const Color successText = Color(0xFF065F46);
  static const Color successBackground = Color(0xFFECFDF5);

  // Semantic Status: Info
  static const Color info = Color(0xFF0284C7);
  static const Color infoBackground = Color(0xFFE0F2FE);

  // Semantic Status: Error / Danger / Rejected
  static const Color error = Color(0xFFDC2626);
  static const Color errorText = Color(0xFF991B1B);
  static const Color errorBackground = Color(0xFFFEE2E2);

  // Background & Surfaces
  static const Color background = Color(0xFFF7F9FA); // Very light cool grey
  static const Color surface = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceVariant = Color(0xFFF3F6F8);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E9EB); // Ultra-fine card border
  static const Color borderSubtle = Color(0xFFEEF1F3);
  static const Color divider = Color(0xFFF0F3F5);

  // Typography & Content
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverted = Color(0xFFFFFFFF);
}
