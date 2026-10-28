import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

/// 2x2 grid of metric counters for outbound dispatch.
class DispatchMetricsGrid extends StatelessWidget {
  const DispatchMetricsGrid({
    super.key,
    required this.totalShipments,
    required this.inTransitCount,
    required this.completedCount,
    required this.rejectedCount,
  });

  final int totalShipments;
  final int inTransitCount;
  final int completedCount;
  final int rejectedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total pengiriman & Sedang berjalan
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: LucideIcons.box,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryContainer,
                value: totalShipments.toString(),
                label: 'Total pengiriman',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricTile(
                icon: LucideIcons.ship,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryContainer,
                value: inTransitCount.toString(),
                label: 'Sedang berjalan',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Row 2: Selesai diterima & Pesanan ditolak
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: LucideIcons.circleCheck,
                iconColor: AppColors.success,
                iconBg: AppColors.successBackground,
                value: completedCount.toString(),
                label: 'Selesai diterima',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricTile(
                icon: LucideIcons.circleX,
                iconColor: const Color(0xFFDC2626),
                iconBg: const Color(0xFFFEF2F2),
                value: rejectedCount.toString(),
                label: 'Pesanan ditolak',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.metricStat),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.metricLabel),
        ],
      ),
    );
  }
}
