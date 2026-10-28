import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../../dispatch/data/services/firestore_dispatch_service.dart';
import '../../../dispatch/presentation/widgets/dispatch_tracking_map_card.dart';

/// Full-screen Detail Batch view for the Receiving (Penerimaan) module.
///
/// Implements the complete design specification including:
/// 1. Hero Navy Header Card with Coolbox ID, Fish Species, Weight & Sea Route
/// 2. Trip Information (Informasi Perjalanan) key-value table
/// 3. IoT Temperature Telemetry & Interactive Timeline Chart (Sensor Suhu)
/// 4. Real-time FrostScore Gauge, Metric Penalties & 4-Tier Risk Scale
/// 5. Visual Sea Journey GPS Tracking with Island Waypoints (Pelacakan Perjalanan)
/// 6. Physical Inspection Decision Card (Keputusan Penerimaan: Tolak vs Terima)
class ReceivingDetailPage extends StatefulWidget {
  const ReceivingDetailPage({
    super.key,
    required this.batchId,
    required this.coolboxId,
    required this.fishType,
    required this.weightKg,
    required this.supplierName,
    required this.originLocation,
    required this.destinationLocation,
    this.temperature = -2.4,
    this.frostScore = 75,
    this.initialStatus = 'Menunggu periksa',
    this.formattedDate = 'Hari ini',
    this.receiverName,
    this.receiverLocation,
    this.onStatusChanged,
  });

  final String batchId;
  final String coolboxId;
  final String fishType;
  final double weightKg;
  final String supplierName;
  final String originLocation;
  final String destinationLocation;
  final double temperature;
  final int frostScore;
  final String initialStatus;
  final String formattedDate;
  final String? receiverName;
  final String? receiverLocation;
  final VoidCallback? onStatusChanged;

  @override
  State<ReceivingDetailPage> createState() => _ReceivingDetailPageState();
}

class _ReceivingDetailPageState extends State<ReceivingDetailPage> {
  late String _currentStatus;
  late double _currentTemperature;
  late int _currentFrostScore;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _currentTemperature = widget.temperature;
    _currentFrostScore = widget.frostScore;
  }

  bool get _isDecided {
    final s = _currentStatus.toLowerCase();
    return s.contains('diterima') ||
        s.contains('selesai') ||
        s.contains('ditolak');
  }

  bool get _isAccepted {
    final s = _currentStatus.toLowerCase();
    return s.contains('diterima') || s.contains('selesai');
  }

  bool get _isRejected {
    final s = _currentStatus.toLowerCase();
    return s.contains('ditolak');
  }

  Future<void> _handleAccept() async {
    setState(() => _isProcessing = true);

    final user = AuthSession.instance.currentUser;
    final success =
        await FirestoreDispatchService.instance.confirmReceivingBatch(
      batchId: widget.batchId,
      coolboxId: widget.coolboxId,
      receiverName: widget.receiverName ?? user?.name ?? 'Penerima',
      locationName: widget.receiverLocation ??
          user?.storeLocation ??
          widget.destinationLocation,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() => _currentStatus = 'Diterima');
      widget.onStatusChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.circleCheck,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Batch ${widget.batchId} berhasil diterima!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0D7A5F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gagal mengonfirmasi penerimaan. Periksa koneksi internet.',
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  Future<void> _handleReject([String? reason]) async {
    setState(() => _isProcessing = true);
    final user = AuthSession.instance.currentUser;
    final success =
        await FirestoreDispatchService.instance.rejectReceivingBatch(
      batchId: widget.batchId,
      coolboxId: widget.coolboxId,
      receiverName: widget.receiverName ?? user?.name ?? 'Penerima',
      locationName: widget.receiverLocation ??
          user?.storeLocation ??
          widget.destinationLocation,
      reason: reason ?? 'Kondisi fisik ikan tidak memenuhi standar',
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      setState(() => _currentStatus = 'Ditolak');
      widget.onStatusChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.circleX,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Batch ${widget.batchId} telah ditolak.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSession.instance.currentUser;
    final initials = user != null && user.name.isNotEmpty
        ? (user.name.trim().split(RegExp(r'\s+')).length >= 2
            ? '${user.name.trim().split(RegExp(r'\s+'))[0][0]}${user.name.trim().split(RegExp(r'\s+'))[1][0]}'
                .toUpperCase()
            : user.name
                .substring(0, user.name.length >= 2 ? 2 : 1)
                .toUpperCase())
        : 'DA';

    Stream<DatabaseEvent>? stream;
    try {
      if (Firebase.apps.isNotEmpty) {
        stream = FirebaseDatabase.instance
            .ref('dispatches/${widget.batchId}')
            .onValue;
      }
    } catch (_) {}

    Widget buildScaffold() {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F7F9),
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
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
            'Detail batch penerimaan',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
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
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.avatarNavy,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dark Petrol Navy Batch Hero Card
              _HeaderBatchCard(
                batchId: widget.batchId,
                coolboxId: widget.coolboxId,
                fishType: widget.fishType,
                weightKg: widget.weightKg,
                supplierName: widget.supplierName,
                originLocation: widget.originLocation,
                destinationLocation: widget.destinationLocation,
                status: _currentStatus,
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Trip Information (Informasi Perjalanan) Card
              _TripInfoCard(
                formattedDate: widget.formattedDate,
                supplierName: widget.supplierName,
                receiverName: widget.receiverName ??
                    user?.organization ??
                    user?.name ??
                    'CV Laut Segar',
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Sensor Suhu Card with Timeline Line Chart
              _TemperatureSectionCard(
                currentTemperature: _currentTemperature,
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. FrostScore Real-Time Analysis Card
              _FrostScoreAnalysisCard(
                frostScore: _currentFrostScore,
              ),
              const SizedBox(height: AppSpacing.md),

              // 5. GPS Real-time Journey Tracking Map Card (Live Leaflet/FlutterMap)
              DispatchTrackingMapCard(
                batchId: widget.batchId,
                originLocation: widget.originLocation,
                destinationLocation: widget.destinationLocation,
                receiverName: widget.receiverName ?? user?.name ?? 'Penerima',
                isSender: false,
              ),
              const SizedBox(height: AppSpacing.md),

              // 6. Decision Card (Keputusan Penerimaan: Tolak vs Terima)
              _PemeriksaanKondisiCard(
                coolboxId: widget.coolboxId.isNotEmpty
                    ? widget.coolboxId
                    : widget.batchId,
                isDecided: _isDecided,
                isAccepted: _isAccepted,
                isRejected: _isRejected,
                isProcessing: _isProcessing,
                onConfirmAccept: _handleAccept,
                onConfirmReject: _handleReject,
              ),
              const SizedBox(height: AppSpacing.md),

              // 7. Bottom Footnote Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.info,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Expanded(
                      child: Text(
                        'FrostScore adalah indikator risiko rantai dingin, bukan hasil laboratorium atau sertifikat keamanan pangan.',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      );
    }

    if (stream != null) {
      return StreamBuilder<DatabaseEvent>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.exists) {
            final val = snapshot.data!.snapshot.value;
            if (val is Map) {
              final data = Map<String, dynamic>.from(val);
              _currentStatus = data['status'] as String? ?? _currentStatus;
              _currentTemperature =
                  (data['temperature'] as num?)?.toDouble() ??
                      _currentTemperature;
              _currentFrostScore =
                  (data['frostScore'] as num?)?.toInt() ?? _currentFrostScore;
            }
          }
          return buildScaffold();
        },
      );
    }

    return buildScaffold();
  }
}

// ============================================================================
// 1. HEADER HERO BATCH CARD (DARK PETROL NAVY)
// ============================================================================
class _HeaderBatchCard extends StatelessWidget {
  const _HeaderBatchCard({
    required this.batchId,
    required this.coolboxId,
    required this.fishType,
    required this.weightKg,
    required this.supplierName,
    required this.originLocation,
    required this.destinationLocation,
    required this.status,
  });

  final String batchId;
  final String coolboxId;
  final String fishType;
  final double weightKg;
  final String supplierName;
  final String originLocation;
  final String destinationLocation;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF144E63), // Dark teal navy
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF144E63).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Cube icon + Batch ID, and Status pill on the right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.box,
                    size: 17,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    batchId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: status.toLowerCase().contains('tolak')
                            ? const Color(0xFFEF4444)
                            : (status.toLowerCase().contains('selesai') ||
                                    status.toLowerCase().contains('diterima'))
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Fish Species Title & Weight + Supplier
          Text(
            fishType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${weightKg.toStringAsFixed(0)} kg • $supplierName',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sea Route Visualizer
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 15,
                color: Color(0xFF67E8F9),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      originLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    _buildDottedDash(),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.ship,
                      size: 18,
                      color: Color(0xFF67E8F9),
                    ),
                    const SizedBox(width: 4),
                    _buildDottedDash(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      destinationLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                LucideIcons.mapPin,
                size: 15,
                color: Color(0xFF67E8F9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDottedDash() {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          5,
          (_) => Container(
            width: 4,
            height: 1.5,
            color: const Color(0xFF67E8F9).withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. TRIP INFORMATION (INFORMASI PERJALANAN) CARD
// ============================================================================
class _TripInfoCard extends StatelessWidget {
  const _TripInfoCard({
    required this.formattedDate,
    required this.supplierName,
    required this.receiverName,
  });

  final String formattedDate;
  final String supplierName;
  final String receiverName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi perjalanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Dibuat', formattedDate),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildRow('Pengirim', supplierName),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildRow('Penerima', receiverName),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildRow('Sinkronisasi', 'Tersinkron', isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF0F172A),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3. SENSOR SUHU CARD WITH INTERACTIVE LINE CHART
// ============================================================================
class _TemperatureSectionCard extends StatelessWidget {
  const _TemperatureSectionCard({
    required this.currentTemperature,
  });

  final double currentTemperature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: SENSOR SUHU + Live Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SENSOR SUHU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0891B2),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Riwayat suhu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Current Temp Display Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currentTemperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Suhu terakhir • 00:45',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Zona aman',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Custom Temperature Curve Chart
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: CustomPaint(
              painter: _TemperatureChartPainter(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Footnote
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                LucideIcons.info,
                size: 13,
                color: Color(0xFF0891B2),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Riwayat tersimpan bersama batch dan diperbarui setiap kali sensor coldbox mengirim data.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
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

class _TemperatureChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 24;
    final w = size.width;

    // Grid horizontal reference dashed line for "Batas aman 4°C"
    final safeY = chartHeight * 0.45;
    final dashPaint = Paint()
      ..color = const Color(0xFFFB923C)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double curX = 0;
    while (curX < w) {
      canvas.drawLine(
        Offset(curX, safeY),
        Offset(math.min(curX + 6, w), safeY),
        dashPaint,
      );
      curX += 10;
    }

    // Text label for "Batas aman 4°C"
    const textSpan = TextSpan(
      text: 'Batas aman 4°C',
      style: TextStyle(
        color: Color(0xFFEA580C),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(w - textPainter.width - 4, safeY - 14));

    // Points on the line chart (4 intervals: 00:00, 00:15, 00:30, 00:45)
    final points = [
      Offset(w * 0.12, chartHeight * 0.45), // 00:00 -> 4.0°C
      Offset(w * 0.38, chartHeight * 0.30), // 00:15 -> 4.6°C (anomaly)
      Offset(w * 0.65, chartHeight * 0.65), // 00:30 -> 2.5°C
      Offset(w * 0.90, chartHeight * 0.45), // 00:45 -> 4.0°C
    ];

    // Draw connecting path
    final linePaint = Paint()
      ..color = const Color(0xFF0891B2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw Data Point Nodes
    for (int i = 0; i < points.length; i++) {
      final isAnomaly = (i == 1);
      final dotPaint = Paint()
        ..color = isAnomaly ? const Color(0xFFEF4444) : const Color(0xFF0891B2)
        ..style = PaintingStyle.fill;

      // Outer halo
      final haloPaint = Paint()
        ..color = (isAnomaly ? const Color(0xFFEF4444) : const Color(0xFF0891B2))
            .withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i], 7, haloPaint);
      canvas.drawCircle(points[i], 4, dotPaint);
    }

    // X-Axis Time Labels
    final times = ['00:00', '00:15', '00:30', '00:45'];
    for (int i = 0; i < times.length; i++) {
      final tSpan = TextSpan(
        text: times[i],
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final tPainter = TextPainter(
        text: tSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tPainter.paint(
        canvas,
        Offset(points[i].dx - (tPainter.width / 2), chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 4. FROSTSCORE REAL-TIME ANALYSIS CARD
// ============================================================================
class _FrostScoreAnalysisCard extends StatelessWidget {
  const _FrostScoreAnalysisCard({
    required this.frostScore,
  });

  final int frostScore;

  @override
  Widget build(BuildContext context) {
    final penalty = (100 - frostScore).toDouble();
    String qualityText = 'Baik';
    if (frostScore >= 90) {
      qualityText = 'Sangat Baik';
    } else if (frostScore >= 75) {
      qualityText = 'Baik';
    } else if (frostScore >= 60) {
      qualityText = 'Waspada';
    } else {
      qualityText = 'Risiko Tinggi';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Progress Gauge Header
          Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: CustomPaint(
                  painter: _FrostScoreGaugePainter(score: frostScore),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$frostScore',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: '/100',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FROSTSCORE • REAL-TIME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0891B2),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      qualityText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '100 - ${penalty.toStringAsFixed(2)} total penalti',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 4 Grid Metric Penalty Cards (Thermal, Exposure, Stability, Anomaly)
          Row(
            children: [
              _buildPenaltyCard('Thermal', '40%', '20.00'),
              const SizedBox(width: 6),
              _buildPenaltyCard('Exposure', '25%', '25.00'),
              const SizedBox(width: 6),
              _buildPenaltyCard('Stability', '15%', '26.67'),
              const SizedBox(width: 6),
              _buildPenaltyCard('Anomaly', '20%', '33.33'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Formula Box (Ptotal)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0F2FE)),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Ptotal  ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                  TextSpan(
                    text:
                        '(0,40 × 20) + (0,25 × 25) + (0,15 × 26.67) + (0,20 × 33.33) = ${penalty.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4-Color Category Range Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                _buildRangeSegment(
                  'Sangat Baik',
                  '90-100',
                  const Color(0xFF0E8367),
                ),
                _buildRangeSegment(
                  'Baik',
                  '75-89',
                  const Color(0xFF70A83B),
                ),
                _buildRangeSegment(
                  'Waspada',
                  '60-74',
                  const Color(0xFFD97706),
                ),
                _buildRangeSegment(
                  'Risiko Tinggi',
                  '0-59',
                  const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Footnote
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                LucideIcons.info,
                size: 13,
                color: Color(0xFF0891B2),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Dihitung ulang otomatis dari kondisi suhu coldbox terbaru. Indikator risiko, bukan sertifikat keamanan pangan.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyCard(String title, String weight, String score) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  weight,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF0891B2),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              score,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSegment(String label, String range, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        color: color,
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            Text(
              range,
              style: TextStyle(
                fontSize: 7.5,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostScoreGaugePainter extends CustomPainter {
  _FrostScoreGaugePainter({required this.score});

  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = const Color(0xFF0891B2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FrostScoreGaugePainter oldDelegate) =>
      oldDelegate.score != score;
}

// ============================================================================
// 6. PEMERIKSAAN KONDISI (KEPUTUSAN PENERIMAAN) CARD
// ============================================================================
class _PemeriksaanKondisiCard extends StatefulWidget {
  const _PemeriksaanKondisiCard({
    required this.coolboxId,
    required this.isDecided,
    required this.isAccepted,
    required this.isRejected,
    required this.isProcessing,
    required this.onConfirmAccept,
    required this.onConfirmReject,
  });

  final String coolboxId;
  final bool isDecided;
  final bool isAccepted;
  final bool isRejected;
  final bool isProcessing;
  final VoidCallback onConfirmAccept;
  final ValueChanged<String> onConfirmReject;

  @override
  State<_PemeriksaanKondisiCard> createState() =>
      _PemeriksaanKondisiCardState();
}

enum _DecisionMode { idle, confirmAccept, confirmReject }

class _PemeriksaanKondisiCardState extends State<_PemeriksaanKondisiCard> {
  _DecisionMode _mode = _DecisionMode.idle;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitReject() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan penolakan wajib diisi.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    widget.onConfirmReject(reason);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PEMERIKSAAN KONDISI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0891B2),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Keputusan penerimaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pastikan kondisi fisik ikan telah diperiksa langsung.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (widget.isDecided) ...[
            // Status Banner if transaction already has decision
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: widget.isAccepted
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: widget.isAccepted
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isAccepted
                        ? LucideIcons.circleCheck
                        : LucideIcons.circleX,
                    color: widget.isAccepted
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.isAccepted
                        ? 'Batch telah dikonfirmasi Diterima'
                        : 'Batch telah ditandai Ditolak',
                    style: TextStyle(
                      color: widget.isAccepted
                          ? const Color(0xFF065F46)
                          : const Color(0xFF991B1B),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_mode == _DecisionMode.confirmAccept) ...[
            // Flow 1: Konfirmasi TERIMA (Green Banner + Batal + Simpan Keputusan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7EE), // soft mint green
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terima coolbox ${widget.coolboxId}?',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Keputusan akan tersimpan bersama waktu transaksi.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.isProcessing
                      ? null
                      : () => setState(() => _mode = _DecisionMode.idle),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed:
                      widget.isProcessing ? null : widget.onConfirmAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7A5F), // Deep teal green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                  child: widget.isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Simpan keputusan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ] else if (_mode == _DecisionMode.confirmReject) ...[
            // Flow 2: Konfirmasi TOLAK (Red Banner + Alasan Penolakan* + Batal + Simpan Keputusan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC), // soft red pink
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tolak coolbox ${widget.coolboxId}?',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Keputusan akan tersimpan bersama waktu transaksi.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: const [
                Text(
                  'Alasan penolakan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _reasonController,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
                decoration: const InputDecoration(
                  hintText: 'Jelaskan kondisi ikan atau kendala lainnya',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.isProcessing
                      ? null
                      : () => setState(() => _mode = _DecisionMode.idle),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: widget.isProcessing ? null : _submitReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8383B), // Dark brick red
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                  child: widget.isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Simpan keputusan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ] else ...[
            // State Idle: [ Tolak ]  and  [ Terima ]
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isProcessing
                        ? null
                        : () => setState(
                              () => _mode = _DecisionMode.confirmReject,
                            ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.2,
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          LucideIcons.circleX,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Tolak',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isProcessing
                        ? null
                        : () => setState(
                              () => _mode = _DecisionMode.confirmAccept,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D7A5F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          LucideIcons.circleCheck,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Terima',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
