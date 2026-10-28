import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/dispatch_item.dart';

/// Card showing outbound fish batch shipment details including sea route.
class DispatchItemCard extends StatelessWidget {
  const DispatchItemCard({super.key, required this.item, this.onTap});

  final DispatchItem item;
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
                LucideIcons.clock,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(item.formattedDate, style: AppTypography.batchCode),
              ),

              _buildStatusBadge(item.statusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Middle Row: Fish icon container + Details (Fish weight & Route) + Chevron
          Row(
            children: [
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.formattedFishWeight,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.routeDescription,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Divider
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Footer: Timestamp & Sync status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.box,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(item.batchCode, style: AppTypography.caption),
                ],
              ),
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

  Widget _buildStatusBadge(String status) {
    final sLower = status.toLowerCase();
    if (sLower.contains('tolak')) {
      return StatusBadge.error(label: status);
    } else if (sLower.contains('selesai') || sLower.contains('diterima')) {
      return StatusBadge.success(label: status);
    } else if (sLower.contains('selesai periksa')) {
      return StatusBadge(label: status, variant: StatusBadgeVariant.info);
    } else {
      return StatusBadge.warning(label: status);
    }
  }
}
