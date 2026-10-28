import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// The prominent Hero Card displaying the active batch count needing review
/// and the primary "Scan QR penerimaan" call-to-action button.
class ReceivingHeroCard extends StatelessWidget {
  const ReceivingHeroCard({
    super.key,
    required this.pendingCount,
    required this.actionPrompt,
    this.onScanTap,
  });

  final int pendingCount;
  final String actionPrompt;
  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          children: [
            // Top Section: Dark Petrol Navy Status Display
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              color: AppColors.primaryDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menunggu pemeriksaan',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFFA0C4D5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '$pendingCount batch',
                          style: AppTypography.heroStat,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          actionPrompt,
                          style: AppTypography.badge.copyWith(
                            color: AppColors.warningAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Clipboard with checkmark illustration container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B495F),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: const Color(0xFF2C6885),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.clipboardCheck,
                      size: 32,
                      color: Color(0xFF4EB8D4),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Docked Action Bar: Ocean Teal "Scan QR penerimaan"
            Material(
              color: AppColors.primary,
              child: InkWell(
                onTap: onScanTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md + 2,
                  ),
                  child: Row(
                    children: [
                      // QR icon container
                      const Icon(
                        LucideIcons.qrCode,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Text instructions
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan QR penerimaan',
                              style: AppTypography.cardTitle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ambil data dari coolbox pengirim',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFFD6EFF6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chevron Right
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
