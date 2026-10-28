import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../features/dispatch/data/services/firestore_master_data_service.dart';

/// Modal bottom sheet presenting a real-time hardware camera QR scanner
/// with manual fallback selection of coolbox IDs for receiving/dispatch.
class SmartQrScannerSheet extends StatefulWidget {
  const SmartQrScannerSheet({
    super.key,
    this.title = 'Scan QR Coolbox',
    this.subtitle = 'Arahkan kamera ke kode QR pada coolbox ikan',
    this.coolboxOptions,
    this.initialCoolboxId,
  });

  final String title;
  final String subtitle;
  final List<String>? coolboxOptions;
  final String? initialCoolboxId;

  /// Convenience helper to display the scanner modal
  static Future<String?> show(
    BuildContext context, {
    String title = 'Scan QR Coolbox',
    String subtitle = 'Arahkan kamera ke kode QR pada coolbox ikan',
    List<String>? coolboxOptions,
    String? initialCoolboxId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmartQrScannerSheet(
        title: title,
        subtitle: subtitle,
        coolboxOptions: coolboxOptions,
        initialCoolboxId: initialCoolboxId,
      ),
    );
  }

  @override
  State<SmartQrScannerSheet> createState() => _SmartQrScannerSheetState();
}

class _SmartQrScannerSheetState extends State<SmartQrScannerSheet> {
  late final MobileScannerController _controller;
  bool _isScanned = false;
  String? _selectedCoolboxId;

  @override
  void initState() {
    super.initState();
    _selectedCoolboxId = widget.initialCoolboxId;
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _isScanned = true;
        Navigator.of(context).pop(code);
        break;
      }
    }
  }

  void _onManualSelect(String id) {
    if (_isScanned) return;
    _isScanned = true;
    Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.90,
      ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with title, subtitle and close button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
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
              ),
              const SizedBox(height: AppSpacing.xs),

              // Camera Viewport
              Container(
                height: 230,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.cameraOff,
                                  size: 36,
                                  color: Colors.white70,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Kamera tidak aktif atau tidak diizinkan',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gunakan opsi pilih ID coolbox di bawah',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: const Color(0xFF64D2EC),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Viewfinder Frame Brackets
                    Positioned(
                      top: 24,
                      left: 28,
                      right: 28,
                      bottom: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00A9CE).withValues(alpha: 0.8),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),

                    // Controls Overlay: Torch & Camera flip
                    Positioned(
                      bottom: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _controller.toggleTorch(),
                            icon: const Icon(
                              LucideIcons.zap,
                              color: Colors.white,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          IconButton(
                            onPressed: () => _controller.switchCamera(),
                            icon: const Icon(
                              LucideIcons.switchCamera,
                              color: Colors.white,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              minimumSize: const Size(36, 36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Divider with "atau pilih ID coolbox secara manual"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        'atau pilih ID coolbox secara manual',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Manual Coolbox Selection Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: StreamBuilder<List<String>>(
                  stream: FirestoreMasterDataService.instance.streamCoolboxes(),
                  initialData: widget.coolboxOptions ??
                      FirestoreMasterDataService.defaultCoolboxes,
                  builder: (context, snapshot) {
                    final List<String> uniqueOptions;
                    if (widget.coolboxOptions != null) {
                      // Strictly use incoming options without leaking other unassociated master coolboxes
                      uniqueOptions = widget.coolboxOptions!.toSet().toList();
                    } else {
                      final streamCoolboxes = snapshot.data ??
                          FirestoreMasterDataService.defaultCoolboxes;
                      uniqueOptions = streamCoolboxes.toSet().toList();
                      if (uniqueOptions.isEmpty) {
                        uniqueOptions.addAll(
                          FirestoreMasterDataService.defaultCoolboxes,
                        );
                      }
                    }

                    final bool hasOptions = uniqueOptions.isNotEmpty;

                    // Ensure selected value is valid in options
                    String? currentSelected = _selectedCoolboxId;
                    if (currentSelected != null &&
                        !uniqueOptions.contains(currentSelected)) {
                      currentSelected = hasOptions ? uniqueOptions.first : null;
                    } else if (currentSelected == null && hasOptions) {
                      currentSelected = uniqueOptions.first;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID Coolbox',
                              style: AppTypography.badge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              hasOptions
                                  ? 'Pilih jika QR tidak dapat dipindai'
                                  : 'Tidak ada dalam penerimaan',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        if (!hasOptions) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.info,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Tidak ada coolbox dalam pengiriman menuju lokasi Anda saat ini.',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ] else ...[
                          // Dropdown selection card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: currentSelected,
                                isExpanded: true,
                                icon: const Icon(
                                  LucideIcons.chevronDown,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                items: uniqueOptions.map((id) {
                                  return DropdownMenuItem<String>(
                                    value: id,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F7FA),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            LucideIcons.box,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          id,
                                          style: AppTypography.body.copyWith(
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCoolboxId = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Submit / Select Coolbox Button
                        ElevatedButton(
                          onPressed: (hasOptions && currentSelected != null)
                              ? () => _onManualSelect(currentSelected!)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFE2E8F0),
                            disabledForegroundColor: const Color(0xFF94A3B8),
                            minimumSize: const Size.fromHeight(48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.checkCheck, size: 18),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Pilih ID Coolbox Ini',
                                style: AppTypography.cardTitle.copyWith(
                                  color: (hasOptions && currentSelected != null)
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
