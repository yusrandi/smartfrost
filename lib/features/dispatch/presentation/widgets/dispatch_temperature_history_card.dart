import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/services/firestore_dispatch_service.dart';
import '../../domain/models/coolbox_history_reading.dart';

/// Card that streams and visualizes air temperature history (`air_temperature_c`)
/// over time (`timestamp`) from RTDB `/suhu/$coolboxId/history`.
class DispatchTemperatureHistoryCard extends StatelessWidget {
  const DispatchTemperatureHistoryCard({
    super.key,
    required this.coolboxId,
    this.batchId = '',
    this.isReceiver = false,
  });

  final String coolboxId;
  final String batchId;
  final bool isReceiver;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoolboxHistoryReading>>(
      stream: FirestoreDispatchService.instance.streamCoolboxTemperatureHistory(
        coolboxId,
        batchId: batchId,
        isReceiver: isReceiver,
      ),
      builder: (context, snapshot) {
        final readings = snapshot.data ?? const [];

        if (readings.isEmpty) {
          // Waiting / Empty State Card
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
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
          );
        }

        // Active State with Line Chart
        final latest = readings.last;
        final timeStr =
            '${latest.timestamp.hour.toString().padLeft(2, '0')}:${latest.timestamp.minute.toString().padLeft(2, '0')} WITA';

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live • ${readings.length} logs',
                          style: const TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
              const SizedBox(height: AppSpacing.md),

              // Latest Temperature Banner Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0284C7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${latest.airTemperatureC.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Suhu udara • $timeStr',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'air_temperature_c',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Sumbu Y & Sumbu X Line Chart
              Container(
                height: 175,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: CustomPaint(
                  painter: _AirTemperatureChartPainter(readings),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Footnote & Axis Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.info,
                    size: 13,
                    color: Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sumbu Y: Suhu udara (air_temperature_c) • Sumbu X: Waktu sensor (timestamp)',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AirTemperatureChartPainter extends CustomPainter {
  const _AirTemperatureChartPainter(this.readings);

  final List<CoolboxHistoryReading> readings;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    const leftPadding = 38.0;
    const rightPadding = 16.0;
    const bottomPadding = 24.0;
    const topPadding = 12.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // 1. Determine Min & Max Temperature for Y-axis scaling
    double minTemp = readings.map((r) => r.airTemperatureC).reduce(math.min);
    double maxTemp = readings.map((r) => r.airTemperatureC).reduce(math.max);

    if (minTemp == maxTemp) {
      minTemp -= 2.0;
      maxTemp += 2.0;
    } else {
      final range = maxTemp - minTemp;
      minTemp -= range * 0.15;
      maxTemp += range * 0.15;
    }

    final tempRange = maxTemp - minTemp;

    // 2. Draw Horizontal Grid Lines & Y-Axis Labels
    const gridCount = 3;
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= gridCount; i++) {
      final ratio = i / gridCount;
      final y = topPadding + chartHeight * (1.0 - ratio);
      final tempVal = minTemp + tempRange * ratio;

      // Grid line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      // Y-Axis Label
      final labelText = '${tempVal.toStringAsFixed(1)}°';
      final span = TextSpan(
        text: labelText,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      );
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, y - tp.height / 2));
    }

    // 3. Compute Data Points (x, y)
    final points = <Offset>[];
    for (int i = 0; i < readings.length; i++) {
      final x = readings.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (i / (readings.length - 1)) * chartWidth;
      final tempNorm = (readings[i].airTemperatureC - minTemp) / tempRange;
      final y = topPadding + chartHeight * (1.0 - tempNorm.clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    // 4. Draw Gradient Fill Under the Line
    if (points.length >= 2) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, topPadding + chartHeight);
      fillPath.lineTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      fillPath.lineTo(points.last.dx, topPadding + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0284C7).withValues(alpha: 0.28),
            const Color(0xFF0284C7).withValues(alpha: 0.02),
          ],
        ).createShader(
          Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
        );

      canvas.drawPath(fillPath, fillPaint);
    }

    // 5. Draw Smooth Stroke Line
    final linePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // 6. Draw Circular Node Markers
    for (int i = 0; i < points.length; i++) {
      final isLast = (i == points.length - 1);
      final haloPaint = Paint()
        ..color =
            const Color(0xFF0284C7).withValues(alpha: isLast ? 0.35 : 0.20)
        ..style = PaintingStyle.fill;

      final dotPaint = Paint()
        ..color = isLast ? const Color(0xFF0284C7) : Colors.white
        ..style = PaintingStyle.fill;

      final strokeDotPaint = Paint()
        ..color = const Color(0xFF0284C7)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(points[i], isLast ? 8 : 6, haloPaint);
      canvas.drawCircle(points[i], isLast ? 4.5 : 3.5, dotPaint);
      if (!isLast) {
        canvas.drawCircle(points[i], 3.5, strokeDotPaint);
      }
    }

    // 7. Draw X-Axis Time Labels
    // Pick up to 5 representative points evenly spaced so text doesn't overlap
    final labelIndices = <int>{};
    if (readings.length <= 5) {
      for (int i = 0; i < readings.length; i++) {
        labelIndices.add(i);
      }
    } else {
      labelIndices.add(0);
      labelIndices.add(readings.length ~/ 4);
      labelIndices.add(readings.length ~/ 2);
      labelIndices.add((readings.length * 3) ~/ 4);
      labelIndices.add(readings.length - 1);
    }

    for (final idx in labelIndices) {
      final reading = readings[idx];
      final dt = reading.timestamp;
      final timeStr =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      final span = TextSpan(
        text: timeStr,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      );
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[idx].dx - (tp.width / 2), topPadding + chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AirTemperatureChartPainter oldDelegate) {
    return oldDelegate.readings != readings;
  }
}

