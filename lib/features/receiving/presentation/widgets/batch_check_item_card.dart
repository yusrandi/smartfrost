import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/fish_batch_item.dart';

/// Detailed inspection card for a fish batch awaiting reception.
class BatchCheckItemCard extends StatelessWidget {
  const BatchCheckItemCard({super.key, required this.item, this.onTap});

  final FishBatchItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Box icon + Batch Code + Status Badge
          Row(
            children: [
              const Icon(
                LucideIcons.box,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(item.batchCode, style: AppTypography.batchCode),
              ),
              switch (item.status) {
                BatchInspectionStatus.received =>
                  StatusBadge.success(label: item.status.label),
                BatchInspectionStatus.rejected =>
                  StatusBadge.error(label: item.status.label),
                BatchInspectionStatus.inspected =>
                  StatusBadge(
                    label: item.status.label,
                    variant: StatusBadgeVariant.info,
                  ),
                BatchInspectionStatus.pending =>
                  StatusBadge.warning(label: item.status.label),
              },
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Middle Row: Fish icon container + Details + Chevron
          Row(
            children: [
              // Fish icon inside soft teal rounded square
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  LucideIcons.fish,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Fish weight & supplier details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.formattedFishWeight,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(item.supplierName, style: AppTypography.cardSubtitle),
                  ],
                ),
              ),

              // Chevron Right indicator
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Fine Divider
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Footer Row: Timestamp & Sync Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timestamp
              Row(
                children: [
                  const Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(item.formattedDate, style: AppTypography.caption),
                ],
              ),

              // Sync status
              if (item.isSynchronized)
                Row(
                  children: [
                    const Icon(
                      LucideIcons.circleCheck,
                      size: 15,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Tersinkron',
                      style: AppTypography.badge.copyWith(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
