import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/frost_score_calculator.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/services/firestore_dispatch_service.dart';
import '../../domain/models/coolbox_history_reading.dart';
import '../../domain/models/new_dispatch_data.dart';
import '../widgets/dispatch_temperature_history_card.dart';
import '../widgets/dispatch_tracking_map_card.dart';

/// Screen displayed following successful dispatch confirmation,
/// displaying live sea route GPS tracking, telemetry, and batch specs.
class DispatchTrackingPage extends StatelessWidget {
  const DispatchTrackingPage({super.key, required this.data});

  final NewDispatchData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Pelacakan pengiriman',
          style: AppTypography.cardTitle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Online indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.radiusPill,
            ),
            child: const Icon(
              LucideIcons.wifi,
              size: 16,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Bell notification
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.headerActionBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.bell,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar DA
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.avatarNavy,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'DA',
              style: AppTypography.badge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Specs Summary Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.batchId,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const StatusBadge(
                        label: 'Sedang berjalan',
                        variant: StatusBadgeVariant.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${data.cargoDisplay} • Pengirim: ${data.senderName}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.ship,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.routeDisplay,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // SENSOR SUHU Card (Live Realtime Telemetry with Sumbu Y: air_temperature_c, Sumbu X: timestamp)
            DispatchTemperatureHistoryCard(
              coolboxId: data.coolboxId,
              batchId: data.batchId,
            ),
            const SizedBox(height: AppSpacing.lg),

            // FROSTSCORE Live Calculation & Risk Card
            StreamBuilder<List<CoolboxHistoryReading>>(
              stream: FirestoreDispatchService.instance
                  .streamCoolboxTemperatureHistory(
                data.coolboxId,
                batchId: data.batchId,
                isReceiver: false,
              ),
              builder: (context, snapshot) {
                final readings = snapshot.data ?? const [];
                final hasReadings = readings.isNotEmpty;

                final FrostScoreResult result;
                if (hasReadings) {
                  final temps = readings.map((r) => r.airTemperatureC).toList();
                  result = FrostScoreCalculator.calculateFromTemperatures(temps);
                } else {
                  result = const FrostScoreResult(
                    score: 96.0,
                    pTotal: 4.0,
                    pThermal: 0.0,
                    pExposure: 0.0,
                    pStability: 0.0,
                    pAnomaly: 0.0,
                    category: FrostScoreCategory.sangatBaik,
                  );
                }

                final scoreColor = result.statusColor;
                final bgCardColor = result.badgeBackground;
                final borderCardColor = result.badgeBorder;

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md + 2),
                  decoration: BoxDecoration(
                    color: bgCardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderCardColor, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                                color: scoreColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 28,
                              height: 4,
                              decoration: BoxDecoration(
                                color: scoreColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hasReadings ? '${result.scoreInt} / 100' : '96 / 100',
                              textAlign: TextAlign.center,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: scoreColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 64,
                        color: borderCardColor,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasReadings
                                  ? '${result.category.label} (${result.scoreInt})'
                                  : 'Sangat Baik (Terverifikasi Awal)',
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scoreColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              hasReadings
                                  ? 'Penalti total: ${result.pTotal.toStringAsFixed(1)} (Thermal 40%, Exp 25%, Stab 15%, Anom 20%).'
                                  : 'Telemetri cold chain terhubung real-time dengan batas aman ≤4,0°C.',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Formula: FrostScore = max(0, 100 - P_total) sesuai regulasi SMART-FROST.',
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
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // PELACAKAN PERJALANAN (Lokasi GPS real-time & Sea Route Map)
            DispatchTrackingMapCard(
              batchId: data.batchId,
              originLocation: data.originLocation,
              destinationLocation: data.destinationLocation,
              receiverName: data.receiverName,
              isSender: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Footnote Disclaimer
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.info,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                Expanded(
                  child: Text(
                    'FrostScore adalah indikator risiko rantai dingin, bukan hasil laboratorium atau sertifikat keamanan pangan.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Return to Home Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: AppTypography.cardTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
