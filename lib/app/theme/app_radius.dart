import 'package:flutter/material.dart';

/// Corner radius constants for cards, pills, buttons, and containers.
abstract final class AppRadius {
  /// 6.0
  static const double xs = 6.0;

  /// 8.0
  static const double sm = 8.0;

  /// 12.0
  static const double md = 12.0;

  /// 16.0 - Standard card corner radius
  static const double lg = 16.0;

  /// 20.0 - Large hero card corner radius
  static const double xl = 20.0;

  /// 24.0
  static const double xxl = 24.0;

  /// 999.0 - Full pill / rounded badges
  static const double full = 999.0;

  // BorderRadius helpers
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusPill = BorderRadius.all(
    Radius.circular(full),
  );
}
