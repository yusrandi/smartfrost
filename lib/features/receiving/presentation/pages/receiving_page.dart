import 'package:flutter/material.dart';

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

/// The primary Receiving Screen (Penerimaan Ikan).
///
/// Cleanly assembles modular sections backed by mock operational data:
/// - Distributor overline and title header
/// - Hero inspection & QR scan action card
/// - Two-column status metric indicators
/// - "Perlu diperiksa" pending batch list
/// - Cold-chain FrostScore disclaimer note
class ReceivingPage extends StatelessWidget {
  const ReceivingPage({
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
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
          for (final item in pendingBatches) ...[
            BatchCheckItemCard(
              item: item,
              onTap: () => onBatchItemPressed?.call(item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Section 6: Cold-Chain Disclaimer Note
          const SizedBox(height: AppSpacing.xs),
          const FrostScoreDisclaimerCard(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
