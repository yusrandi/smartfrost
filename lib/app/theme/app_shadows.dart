import 'package:flutter/material.dart';

/// Shadow styles for cards and floating elements in SmartFrost.
///
/// Designed with subtle, soft ambient shadows to maintain
/// a crisp, clean, and professional appearance.
abstract final class AppShadows {
  /// Subtle card shadow (elevation 1 equivalent)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 10,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Soft raised shadow for active elements or elevated modals
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x0C0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// None
  static const List<BoxShadow> none = [];
}
