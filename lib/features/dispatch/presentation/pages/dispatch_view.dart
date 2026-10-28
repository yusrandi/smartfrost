import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/mock/mock_dispatch_data.dart';
import '../../domain/models/dispatch_item.dart';
import '../../domain/models/dispatch_summary.dart';
import '../widgets/dispatch_action_card.dart';
import '../widgets/dispatch_hero_card.dart';
import '../widgets/dispatch_item_card.dart';
import '../widgets/dispatch_metrics_grid.dart';

/// Presentation View for the Outbound Dispatch role (Distributor A).
class DispatchView extends StatelessWidget {
  const DispatchView({
    super.key,
    this.summary = MockDispatchData.defaultSummary,
    this.recentShipments = MockDispatchData.recentShipments,
    this.onCreateShipmentPressed,
    this.onViewAllPressed,
    this.onItemPressed,
  });

  final DispatchSummary summary;
  final List<DispatchItem> recentShipments;
  final VoidCallback? onCreateShipmentPressed;
  final VoidCallback? onViewAllPressed;
  final ValueChanged<DispatchItem>? onItemPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Header Context
        Text(summary.greetingTitle, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(summary.greetingSubtitle, style: AppTypography.pageSubtitle),
        const SizedBox(height: AppSpacing.lg),

        // Section 2: FrostScore Hero Card
        DispatchHeroCard(
          title: summary.frostScoreAverageLabel,
          statusText: summary.frostScoreStatusText,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Section 3: 2x2 Metric Counters
        DispatchMetricsGrid(
          totalShipments: summary.totalShipments,
          inTransitCount: summary.inTransitCount,
          completedCount: summary.completedCount,
          rejectedCount: summary.rejectedCount,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Section 4: Action Card "Buat pengiriman baru"
        DispatchActionCard(onTap: onCreateShipmentPressed),
        const SizedBox(height: AppSpacing.xl),

        // Section 5: "Pengiriman terbaru" header with "Lihat semua >"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pengiriman terbaru', style: AppTypography.sectionTitle),
            InkWell(
              onTap: onViewAllPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Lihat semua >',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Section 6: Recent Shipment Cards
        if (recentShipments.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 40,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Belum ada pengiriman aktif',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pengiriman yang Anda buat dari dermaga atau toko akan tercatat di sini.',
                  textAlign: TextAlign.center,
                  style: AppTypography.cardSubtitle,
                ),
              ],
            ),
          ),
        ] else ...[
          for (final item in recentShipments) ...[
            DispatchItemCard(item: item, onTap: () => onItemPressed?.call(item)),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
