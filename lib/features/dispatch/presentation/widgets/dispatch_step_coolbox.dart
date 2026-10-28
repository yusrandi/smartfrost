import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/services/firestore_master_data_service.dart';

/// Step 1: Real-time hardware camera QR scanner & manual fallback ID selection.
class DispatchStepCoolbox extends StatefulWidget {
  const DispatchStepCoolbox({
    super.key,
    required this.selectedCoolboxId,
    required this.onCoolboxChanged,
    required this.onNext,
  });

  final String selectedCoolboxId;
  final ValueChanged<String> onCoolboxChanged;
  final VoidCallback onNext;

  @override
  State<DispatchStepCoolbox> createState() => _DispatchStepCoolboxState();
}

class _DispatchStepCoolboxState extends State<DispatchStepCoolbox> {
  bool _isCameraActive = false;
  MobileScannerController? _scannerController;
  String? _detectedCode;

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _toggleCamera() {
    setState(() {
      _isCameraActive = !_isCameraActive;
      if (_isCameraActive) {
        _scannerController ??= MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        );
      } else {
        _scannerController?.dispose();
        _scannerController = null;
      }
    });
  }

  void _handleBarcodeDetect(BarcodeCapture capture) {
    if (!_isCameraActive) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        setState(() {
          _detectedCode = rawValue;
        });

        widget.onCoolboxChanged(rawValue);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'QR Coolbox Terdeteksi: $rawValue',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: FirestoreMasterDataService.instance.streamCoolboxes(),
      initialData: FirestoreMasterDataService.defaultCoolboxes,
      builder: (context, snapshot) {
        final coolboxes =
            snapshot.data ?? FirestoreMasterDataService.defaultCoolboxes;
        final effectiveId = _detectedCode ?? widget.selectedCoolboxId;
        final options = coolboxes.contains(effectiveId)
            ? coolboxes
            : [effectiveId, ...coolboxes];

        return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with QR icon, Title and Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  LucideIcons.qrCode,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan QR coolbox',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pastikan QR terlihat jelas di dalam bingkai.',
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
          const SizedBox(height: AppSpacing.lg),

          // Viewfinder Camera Viewport (Hardware camera or Standby preview)
          Container(
            height: 220,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3F6),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFFD6E6EB), width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Real camera stream when active
                if (_isCameraActive && _scannerController != null)
                  MobileScanner(
                    controller: _scannerController!,
                    onDetect: _handleBarcodeDetect,
                    errorBuilder: (context, error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.cameraOff,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Kamera tidak dapat diakses.\nSilakan gunakan pilihan ID Coolbox manual di bawah.',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  // Watermark QR Icon in center when standby
                  Icon(
                    LucideIcons.qrCode,
                    size: 64,
                    color: const Color(0xFF8AAAB7).withValues(alpha: 0.5),
                  ),

                // Corner viewfinder brackets
                const Positioned(
                  top: 32,
                  left: 48,
                  child: _BracketCorner(isTop: true, isLeft: true),
                ),
                const Positioned(
                  top: 32,
                  right: 48,
                  child: _BracketCorner(isTop: true, isLeft: false),
                ),
                const Positioned(
                  bottom: 48,
                  left: 48,
                  child: _BracketCorner(isTop: false, isLeft: true),
                ),
                const Positioned(
                  bottom: 48,
                  right: 48,
                  child: _BracketCorner(isTop: false, isLeft: false),
                ),

                // Torch & Switch camera controls when hardware camera is active
                if (_isCameraActive && _scannerController != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _scannerController?.toggleTorch(),
                          icon: const Icon(
                            LucideIcons.zap,
                            size: 18,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () => _scannerController?.switchCamera(),
                          icon: const Icon(
                            LucideIcons.switchCamera,
                            size: 18,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Status pill badge at bottom of viewport
                Positioned(
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isCameraActive
                          ? AppColors.successText
                          : const Color(0xFF4A5568),
                      borderRadius: AppRadius.radiusPill,
                    ),
                    child: Text(
                      _isCameraActive
                          ? (_detectedCode != null
                                ? 'Terdeteksi: $_detectedCode'
                                : 'Kamera aktif • Arahkan ke QR')
                          : 'Kamera belum aktif',
                      style: AppTypography.badge.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Outline Button: "Aktifkan kamera" / "Nonaktifkan kamera"
          OutlinedButton.icon(
            onPressed: _toggleCamera,
            icon: Icon(
              _isCameraActive ? LucideIcons.cameraOff : LucideIcons.qrCode,
              size: 18,
            ),
            label: Text(
              _isCameraActive ? 'Nonaktifkan kamera' : 'Aktifkan kamera',
              style: AppTypography.badge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              side: const BorderSide(color: Color(0xFFD0D7DE), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Divider with "atau pilih ID coolbox"
          Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'atau pilih ID coolbox',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Dropdown Field: ID Coolbox
          Text(
            'ID Coolbox',
            style: AppTypography.badge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options.contains(effectiveId) ? effectiveId : null,
                isExpanded: true,
                icon: const Icon(
                  LucideIcons.chevronDown,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                items: options.toSet().map((id) {
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(
                      id,
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _detectedCode = val);
                    widget.onCoolboxChanged(val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Primary Button: "Lanjutkan →"
          ElevatedButton(
            onPressed: widget.onNext,
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
                  'Lanjutkan',
                  style: AppTypography.cardTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(LucideIcons.arrowRight, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
}
}

/// Viewfinder corner bracket widget for scanner frame
class _BracketCorner extends StatelessWidget {
  const _BracketCorner({required this.isTop, required this.isLeft});

  final bool isTop;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    const thickness = 2.8;
    const color = Color(0xFF00A9CE);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Horizontal line
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: 0,
            right: 0,
            child: Container(height: thickness, color: color),
          ),
          // Vertical line
          Positioned(
            top: 0,
            bottom: 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: thickness, color: color),
          ),
        ],
      ),
    );
  }
}
