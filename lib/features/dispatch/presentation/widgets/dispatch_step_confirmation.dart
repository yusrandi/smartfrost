import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/new_dispatch_data.dart';

/// Step 3: Final confirmation review before dispatch submission.
class DispatchStepConfirmation extends StatelessWidget {
  const DispatchStepConfirmation({
    super.key,
    required this.data,
    required this.onEditData,
    required this.onConfirmSend,
  });

  final NewDispatchData data;
  final VoidCallback onEditData;
  final VoidCallback onConfirmSend;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered Check Icon Avatar
          Center(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F7F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    size: 28,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Konfirmasi pengiriman',
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Periksa kembali sebelum data dibagikan kepada penerima.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 1. Shipment Summary Specs Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                _SpecRow(label: 'ID Batch', value: data.batchId, isFirst: true),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _SpecRow(label: 'Pengirim', value: data.senderName),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _SpecRow(label: 'Muatan', value: data.cargoDisplay),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _SpecRow(label: 'Rute', value: data.routeDisplay),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _SpecRow(label: 'Penerima', value: data.receiverName),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _SpecRow(
                  label: 'Status data',
                  value: data.dataStatus,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Sensor Suhu Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: SENSOR SUHU + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SENSOR SUHU',
                      style: AppTypography.overline.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: AppRadius.radiusPill,
                      ),
                      child: Text(
                        'Menunggu sensor',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Riwayat suhu',
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Center Pending State
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        LucideIcons.thermometer,
                        size: 32,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Menunggu data sensor',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Diagram dan angka suhu akan diperbarui saat sensor terhubung.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. FrostScore Pending Notice Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFBF2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFFF7E6B8), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Gauge column
                SizedBox(
                  width: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'FROSTSCORE',
                        style: AppTypography.overline.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF92400E),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Menunggu\nsensor',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 64,
                  color: const Color(0xFFE5D5A4),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),

                // Right Explanations column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum dapat dihitung',
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Empat komponen penalti memerlukan data sensor perjalanan.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bukan hasil laboratorium atau sertifikat keamanan pangan.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons: Ubah data vs Konfirmasi kirim ✓
          Row(
            children: [
              // Ubah data
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: onEditData,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(
                      color: Color(0xFFD0D7DE),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Ubah data',
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Konfirmasi kirim ✓
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: onConfirmSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Konfirmasi kirim',
                        style: AppTypography.cardTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(LucideIcons.check, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: isFirst ? AppSpacing.md : AppSpacing.sm + 2,
        bottom: isLast ? AppSpacing.md : AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
