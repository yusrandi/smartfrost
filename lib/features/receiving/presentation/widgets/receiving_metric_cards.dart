import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

/// Two-column metric summary row displaying "Menunggu" and "Diterima" counters.
class ReceivingMetricCards extends StatelessWidget {
  const ReceivingMetricCards({
    super.key,
    required this.pendingCount,
    required this.receivedCount,
  });

  final int pendingCount;
  final int receivedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card 1: Menunggu
        Expanded(
          child: _MetricItemCard(
            icon: LucideIcons.clock,
            iconColor: AppColors.warning,
            iconBackgroundColor: AppColors.warningBackground,
            value: pendingCount.toString(),
            label: 'Menunggu',
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Card 2: Diterima
        Expanded(
          child: _MetricItemCard(
            icon: LucideIcons.box,
            iconColor: AppColors.success,
            iconBackgroundColor: AppColors.successBackground,
            value: receivedCount.toString(),
            label: 'Diterima',
          ),
        ),
      ],
    );
  }
}

class _MetricItemCard extends StatelessWidget {
  const _MetricItemCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.md),

          // Big Metric Number
          Text(value, style: AppTypography.metricStat),
          const SizedBox(height: 2),

          // Label
          Text(label, style: AppTypography.metricLabel),
        ],
      ),
    );
  }
}
