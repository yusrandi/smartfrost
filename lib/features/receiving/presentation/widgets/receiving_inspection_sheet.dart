import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../dispatch/data/services/firestore_dispatch_service.dart';
import '../../../dispatch/domain/models/new_dispatch_data.dart';
import '../../../dispatch/presentation/pages/dispatch_tracking_page.dart';

/// Interactive modal bottom sheet for inspecting incoming coolbox cold-chain
/// telemetry, fish weight, and officially confirming fish reception.
class ReceivingInspectionSheet extends StatefulWidget {
  const ReceivingInspectionSheet({
    super.key,
    required this.batchId,
    required this.coolboxId,
    required this.fishType,
    required this.weightKg,
    required this.supplierName,
    required this.originLocation,
    required this.destinationLocation,
    required this.temperature,
    required this.frostScore,
    required this.status,
    required this.dateFormatted,
    this.receiverName,
    this.receiverLocation,
    this.onConfirmed,
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
  final String status;
  final String dateFormatted;
  final String? receiverName;
  final String? receiverLocation;
  final VoidCallback? onConfirmed;

  /// Convenience show method
  static Future<bool?> show(
    BuildContext context, {
    required String batchId,
    required String coolboxId,
    required String fishType,
    required double weightKg,
    required String supplierName,
    required String originLocation,
    required String destinationLocation,
    required double temperature,
    required int frostScore,
    required String status,
    required String dateFormatted,
    String? receiverName,
    String? receiverLocation,
    VoidCallback? onConfirmed,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceivingInspectionSheet(
        batchId: batchId,
        coolboxId: coolboxId,
        fishType: fishType,
        weightKg: weightKg,
        supplierName: supplierName,
        originLocation: originLocation,
        destinationLocation: destinationLocation,
        temperature: temperature,
        frostScore: frostScore,
        status: status,
        dateFormatted: dateFormatted,
        receiverName: receiverName,
        receiverLocation: receiverLocation,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<ReceivingInspectionSheet> createState() =>
      _ReceivingInspectionSheetState();
}

class _ReceivingInspectionSheetState extends State<ReceivingInspectionSheet> {
  bool _isLoading = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  bool get _isAlreadyReceived {
    final s = _currentStatus.toLowerCase();
    return s.contains('diterima') || s.contains('selesai');
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final success = await FirestoreDispatchService.instance
        .confirmReceivingBatch(
      batchId: widget.batchId,
      coolboxId: widget.coolboxId,
      receiverName: widget.receiverName,
      locationName: widget.receiverLocation,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentStatus = 'Diterima');
      widget.onConfirmed?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Coolbox ${widget.coolboxId} berhasil diterima!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal mengonfirmasi penerimaan. Periksa koneksi internet.',
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DispatchTrackingPage(
          data: NewDispatchData(
            batchId: widget.batchId,
            coolboxId: widget.coolboxId,
            coolboxIds: [widget.coolboxId],
            fishType: widget.fishType,
            weightRange: '${widget.weightKg.toStringAsFixed(0)} kg',
            originLocation: widget.originLocation,
            destinationLocation: widget.destinationLocation,
            senderName: widget.supplierName,
            receiverName: widget.receiverName ?? 'Penerima',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      LucideIcons.packageCheck,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemeriksaan Penerimaan Ikan',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verifikasi fisik dan kondisi cold-chain coolbox',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 20),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Main Batch Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Batch & Coolbox Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.box,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.coolboxId,
                              style: AppTypography.badge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (_isAlreadyReceived)
                          StatusBadge.success(label: 'Diterima')
                        else
                          StatusBadge.warning(label: _currentStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Batch: ${widget.batchId}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),

                    // Fish Details
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7FA),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            LucideIcons.fish,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.fishType} • ${widget.weightKg.toStringAsFixed(0)} kg',
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pengirim: ${widget.supplierName}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Sea Route Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 14,
                            color: Color(0xFF00A9CE),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${widget.originLocation} → ${widget.destinationLocation}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // IoT Telemetry Cards (Suhu & FrostScore)
              Row(
                children: [
                  // Temperature Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.thermometerSnowflake,
                                size: 16,
                                color: Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Suhu Box',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF166534),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.temperature.toStringAsFixed(1)}°C',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kondisi beku optimal',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF166534),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // FrostScore Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.shieldCheck,
                                size: 16,
                                color: Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FrostScore',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF075985),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.frostScore}%',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0369A1),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Integritas rantai dingin',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF075985),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              if (!_isAlreadyReceived) ...[
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.checkCheck, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Konfirmasi Penerimaan Ikan',
                              style: AppTypography.cardTitle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Button to view real-time tracking route
              OutlinedButton(
                onPressed: _openTracking,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.navigation,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Lihat Rute Tracking',
                      style: AppTypography.badge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
