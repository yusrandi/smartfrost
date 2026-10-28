import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

enum StatusBadgeVariant { warning, success, info, neutral, error }

/// Compact pill status badge used for batch tags, counters, and process indicators.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.warning,
    this.showDot = false,
  });

  /// Factory for warning / pending state (e.g. "Menunggu periksa")
  const StatusBadge.warning({
    super.key,
    required this.label,
    this.showDot = true,
  }) : variant = StatusBadgeVariant.warning;

  /// Factory for counter / batch summary pill (e.g. "1 batch")
  const StatusBadge.count({super.key, required this.label})
    : variant = StatusBadgeVariant.warning,
      showDot = false;

  /// Factory for success state (e.g. "Tersinkron")
  const StatusBadge.success({
    super.key,
    required this.label,
    this.showDot = false,
  }) : variant = StatusBadgeVariant.success;

  /// Factory for error / rejected state (e.g. "Ditolak")
  const StatusBadge.error({
    super.key,
    required this.label,
    this.showDot = true,
  }) : variant = StatusBadgeVariant.error;

  final String label;
  final StatusBadgeVariant variant;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final (bg, text, dot) = switch (variant) {
      StatusBadgeVariant.warning => (
        AppColors.warningBackground,
        AppColors.warningText,
        AppColors.warning,
      ),
      StatusBadgeVariant.success => (
        AppColors.successBackground,
        AppColors.successText,
        AppColors.success,
      ),
      StatusBadgeVariant.info => (
        AppColors.infoBackground,
        AppColors.info,
        AppColors.info,
      ),
      StatusBadgeVariant.neutral => (
        AppColors.surfaceVariant,
        AppColors.textSecondary,
        AppColors.textTertiary,
      ),
      StatusBadgeVariant.error => (
        AppColors.errorBackground,
        AppColors.errorText,
        AppColors.error,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.radiusPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs + 1),
          ],
          Text(label, style: AppTypography.badge.copyWith(color: text)),
        ],
      ),
    );
  }
}
