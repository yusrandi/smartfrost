import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/mock/mock_receiving_data.dart';
import '../../domain/models/fish_batch_item.dart';
import '../../domain/models/receiving_summary.dart';
import '../widgets/batch_check_item_card.dart';
import '../widgets/frost_score_disclaimer_card.dart';
import '../widgets/receiving_header_section.dart';
import '../widgets/receiving_hero_card.dart';
import '../widgets/receiving_metric_cards.dart';

/// Presentation View for the Inbound Receiving role (Distributor B).
class ReceivingView extends StatelessWidget {
  const ReceivingView({
    super.key,
    this.summary = MockReceivingData.defaultSummary,
    this.pendingBatches = MockReceivingData.pendingBatches,
    this.onScanPressed,
    this.onBatchItemPressed,
  });

  final ReceivingSummary summary;
  final List<FishBatchItem> pendingBatches;
  final VoidCallback? onScanPressed;
  final ValueChanged<FishBatchItem>? onBatchItemPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Header Context
        const ReceivingHeaderSection(),
        const SizedBox(height: AppSpacing.lg),

        // Section 2: Hero Action Card
        ReceivingHeroCard(
          pendingCount: summary.pendingBatchCount,
          actionPrompt: summary.actionPrompt,
          onScanTap: onScanPressed,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Section 3: Summary Metric Cards (Menunggu & Diterima)
        ReceivingMetricCards(
          pendingCount: summary.pendingBatchCount,
          receivedCount: summary.receivedBatchCount,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Section 4: "Perlu diperiksa" Header with batch badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Perlu diperiksa', style: AppTypography.sectionTitle),
            StatusBadge.count(label: '${pendingBatches.length} batch'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Section 5: Batch Checklist Item Cards
        if (pendingBatches.isEmpty) ...[
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
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tidak ada penerimaan ikan',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pengiriman ikan dari distributor lain yang ditujukan ke lokasi Anda akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: AppTypography.cardSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else ...[
          for (final item in pendingBatches) ...[
            BatchCheckItemCard(
              item: item,
              onTap: () => onBatchItemPressed?.call(item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],

        // Section 6: Cold-Chain Disclaimer Note
        const SizedBox(height: AppSpacing.xs),
        const FrostScoreDisclaimerCard(),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
