import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/main_shell_layout.dart';
import '../../../../core/widgets/segmented_tab_bar.dart';
import '../../../../core/widgets/smart_qr_scanner_sheet.dart';
import '../../../auth/domain/services/auth_session.dart';
import '../../../dispatch/data/mock/mock_dispatch_data.dart';
import '../../../dispatch/data/services/firestore_dispatch_service.dart';
import '../../../dispatch/domain/models/dispatch_item.dart';
import '../../../dispatch/domain/models/dispatch_summary.dart';
import '../../../dispatch/domain/models/new_dispatch_data.dart';
import '../../../dispatch/presentation/pages/dispatch_tracking_page.dart';
import '../../../dispatch/presentation/pages/dispatch_view.dart';
import '../../../dispatch/presentation/pages/new_dispatch_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../receiving/data/mock/mock_receiving_data.dart';
import '../../../receiving/domain/models/fish_batch_item.dart';
import '../../../receiving/domain/models/receiving_summary.dart';
import '../../../receiving/presentation/pages/receiving_detail_page.dart';
import '../../../receiving/presentation/pages/receiving_view.dart';

/// Unified Hub for SmartFrost managing primary bottom navigation
/// and shared operational role state (Pengiriman vs Penerimaan).
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialRoleIndex = 0,
    this.initialNavIndex = 0,
  });

  final int initialRoleIndex;
  final int initialNavIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _activeRoleIndex;
  late int _selectedNavIndex;

  @override
  void initState() {
    super.initState();
    _activeRoleIndex = widget.initialRoleIndex;
    _selectedNavIndex = widget.initialNavIndex;
  }

  void _handleRoleChanged(int index) {
    if (_activeRoleIndex != index) {
      setState(() => _activeRoleIndex = index);
    }
  }

  void _handleNavSelected(int index) {
    setState(() => _selectedNavIndex = index);
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(isDispatch: _activeRoleIndex == 0),
      ),
    );
  }

  void _openNewDispatch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewDispatchPage()));
  }

  void _openDispatchDetail(DispatchItem item) {
    final user = AuthSession.instance.currentUser;
    final dispatchData = NewDispatchData(
      batchId: item.batchCode,
      coolboxId:
          'CB-${item.batchCode.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}',
      senderName: user?.name ?? '-',
      fishType: item.fishType,
      weightRange: '${item.weightKg.toStringAsFixed(0)} kg',
      originLocation: item.origin,
      destinationLocation: item.destination,
      receiverName: 'Penerima Pulau',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DispatchTrackingPage(data: dispatchData),
      ),
    );
  }

  String _computeInitials(bool isDispatch) {
    final user = AuthSession.instance.currentUser;
    if (user != null &&
        user.name.isNotEmpty &&
        user.name.toLowerCase() != 'sasa') {
      final parts = user.name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts[0].length >= 2) {
        return parts[0].substring(0, 2).toUpperCase();
      } else {
        return parts[0].toUpperCase();
      }
    }
    return isDispatch ? 'DA' : 'DB';
  }

  String _getGreetingTitle() {
    final user = AuthSession.instance.currentUser;
    final rawName = (user != null && user.name.isNotEmpty)
        ? user.name
        : 'Bahari';
    final name = rawName.toLowerCase() == 'sasa' ? 'Bahari' : rawName;

    final hour = DateTime.now().hour;
    final String greeting;
    if (hour >= 4 && hour < 11) {
      greeting = 'Selamat pagi';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'Selamat siang';
    } else if (hour >= 15 && hour < 19) {
      greeting = 'Selamat sore';
    } else {
      greeting = 'Selamat malam';
    }

    return '$greeting, $name.';
  }

  String _getGreetingSubtitle() {
    final user = AuthSession.instance.currentUser;
    final store = (user != null && user.storeLocation.isNotEmpty)
        ? user.storeLocation
        : 'Dermaga Maccini Baji';
    return '$store • Siapkan dan pantau pengiriman hari ini.';
  }

  Future<void> _openReceivingScanner() async {
    final user = AuthSession.instance.currentUser;

    // Fetch only coolboxes that are actually incoming/in-transit to this receiver
    final incomingCoolboxes = await FirestoreDispatchService.instance
        .getIncomingCoolboxIds(user: user);

    if (!mounted) return;

    final scannedCode = await SmartQrScannerSheet.show(
      context,
      title: 'Scan QR Penerimaan',
      subtitle: 'Pindai barcode pada coolbox atau pilih ID coolbox yang tiba',
      coolboxOptions: incomingCoolboxes,
    );
    if (scannedCode != null && mounted) {
      // Find matching dispatch by coolbox ID or batch ID strictly for this receiver
      final dispatchData = await FirestoreDispatchService.instance
          .findReceivingDispatchByCoolboxOrBatch(scannedCode, user: user);

      if (!mounted) return;

      if (dispatchData != null) {
        final batchId = dispatchData['batchId'] as String? ?? scannedCode;
        final coolboxId = dispatchData['coolboxId'] as String? ?? scannedCode;
        final fishType = dispatchData['fishType'] as String? ?? 'Ikan Campur';
        final weightRange = dispatchData['weightRange'] as String? ?? '85 kg';
        final weightMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(weightRange);
        final weightVal = weightMatch != null
            ? double.tryParse(weightMatch.group(1)!) ?? 85.0
            : 85.0;
        final senderName = dispatchData['senderName'] as String? ?? '-';
        final origin = dispatchData['originLocation'] as String? ?? '-';
        final dest =
            dispatchData['destinationLocation'] as String? ??
            (user?.storeLocation ?? 'Pulau Karanrang');
        final temp = (dispatchData['temperature'] as num?)?.toDouble() ?? -2.4;
        final frostScore = (dispatchData['frostScore'] as num?)?.toInt() ?? 96;
        final status = dispatchData['status'] as String? ?? 'Dalam Perjalanan';

        String formattedDate = 'Hari ini';
        final createdAt = dispatchData['createdAt'];
        DateTime? dt;
        if (createdAt is int) {
          dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
        } else if (createdAt is String) {
          dt = DateTime.tryParse(createdAt);
        } else if (createdAt is DateTime) {
          dt = createdAt;
        } else if (createdAt != null) {
          try {
            dt = (createdAt as dynamic).toDate() as DateTime?;
          } catch (_) {}
        }
        if (dt != null) {
          formattedDate =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReceivingDetailPage(
              batchId: batchId,
              coolboxId: coolboxId,
              fishType: fishType,
              weightKg: weightVal,
              supplierName: senderName,
              originLocation: origin,
              destinationLocation: dest,
              temperature: temp,
              frostScore: frostScore,
              initialStatus: status,
              formattedDate: formattedDate,
              receiverName: user?.name,
              receiverLocation: user?.storeLocation,
            ),
          ),
        );
      } else {
        // Validation check: Check if present in mock data for mock/demo accounts
        final mockMatch = (user?.email == 'sasa@smartfrost.id')
            ? MockReceivingData.pendingBatches
                  .cast<FishBatchItem?>()
                  .firstWhere(
                    (b) =>
                        b?.batchCode == scannedCode ||
                        b?.coolboxId == scannedCode,
                    orElse: () => null,
                  )
            : null;

        if (mockMatch != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReceivingDetailPage(
                batchId: mockMatch.batchCode,
                coolboxId: mockMatch.coolboxId.isNotEmpty
                    ? mockMatch.coolboxId
                    : scannedCode,
                fishType: mockMatch.fishType,
                weightKg: mockMatch.weightKg,
                supplierName: mockMatch.supplierName,
                originLocation: 'Dermaga Maccini Baji',
                destinationLocation: user?.storeLocation ?? 'Pulau Karanrang',
                temperature: -2.4,
                frostScore: 96,
                initialStatus: mockMatch.status.label,
                formattedDate: mockMatch.formattedDate,
                receiverName: user?.name,
                receiverLocation: user?.storeLocation,
              ),
            ),
          );
        } else {
          // Reject invalid or unassigned coolbox
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Coolbox $scannedCode tidak ada dalam daftar penerimaan lokasi Anda.',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
    }
  }

  Future<void> _openReceivingDetail(FishBatchItem item) async {
    final user = AuthSession.instance.currentUser;
    final dispatchData = await FirestoreDispatchService.instance
        .findDispatchByCoolboxOrBatch(item.batchCode);

    if (!mounted) return;

    if (dispatchData != null) {
      final batchId = dispatchData['batchId'] as String? ?? item.batchCode;
      final coolboxId = dispatchData['coolboxId'] as String? ?? item.coolboxId;
      final fishType = dispatchData['fishType'] as String? ?? item.fishType;
      final weightRange =
          dispatchData['weightRange'] as String? ??
          '${item.weightKg.toStringAsFixed(0)} kg';
      final weightMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(weightRange);
      final weightVal = weightMatch != null
          ? double.tryParse(weightMatch.group(1)!) ?? item.weightKg
          : item.weightKg;
      final senderName =
          dispatchData['senderName'] as String? ?? item.supplierName;
      final origin =
          dispatchData['originLocation'] as String? ?? 'Dermaga Maccini Baji';
      final dest =
          dispatchData['destinationLocation'] as String? ??
          (user?.storeLocation ?? 'Pulau Karanrang');
      final temp = (dispatchData['temperature'] as num?)?.toDouble() ?? -2.4;
      final frostScore = (dispatchData['frostScore'] as num?)?.toInt() ?? 96;
      final status = dispatchData['status'] as String? ?? item.status.label;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceivingDetailPage(
            batchId: batchId,
            coolboxId: coolboxId.isNotEmpty ? coolboxId : batchId,
            fishType: fishType,
            weightKg: weightVal,
            supplierName: senderName,
            originLocation: origin,
            destinationLocation: dest,
            temperature: temp,
            frostScore: frostScore,
            initialStatus: status,
            formattedDate: item.formattedDate,
            receiverName: user?.name,
            receiverLocation: user?.storeLocation,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceivingDetailPage(
            batchId: item.batchCode,
            coolboxId: item.coolboxId.isNotEmpty
                ? item.coolboxId
                : item.batchCode,
            fishType: item.fishType,
            weightKg: item.weightKg,
            supplierName: item.supplierName,
            originLocation: 'Dermaga Maccini Baji',
            destinationLocation: user?.storeLocation ?? 'Pulau Karanrang',
            temperature: -2.4,
            frostScore: 96,
            initialStatus: item.status.label,
            formattedDate: item.formattedDate,
            receiverName: user?.name,
            receiverLocation: user?.storeLocation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        final isDispatch = _activeRoleIndex == 0;
        final user = AuthSession.instance.currentUser;

        Widget bodyContent;

        switch (_selectedNavIndex) {
          case 1:
            // Tab 1: Riwayat
            bodyContent = HistoryPage(
              initialRoleIndex: _activeRoleIndex,
              onRoleChanged: _handleRoleChanged,
              user: user,
            );
          case 0:
          default:
            // Tab 0: Beranda
            bodyContent = SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Role Switcher: [ 📦 Pengiriman ]  [ 📥 Penerimaan ]
                  SegmentedTabBar(
                    selectedIndex: _activeRoleIndex,
                    onTabChanged: _handleRoleChanged,
                    tabs: const [
                      SegmentTabItem(
                        label: 'Pengiriman',
                        icon: LucideIcons.send,
                      ),
                      SegmentTabItem(
                        label: 'Penerimaan',
                        icon: LucideIcons.inbox,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Animated view transition between Dispatch and Receiving
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: isDispatch
                        ? StreamBuilder<List<DispatchItem>>(
                            key: ValueKey(
                              'dispatch_view_stream_${user?.email}',
                            ),
                            stream: FirestoreDispatchService.instance
                                .streamDispatchItems(user: user),
                            builder: (context, snapshot) {
                              final realItems = snapshot.data ?? const [];
                              final hasData = snapshot.hasData;
                              final itemsToDisplay = hasData
                                  ? realItems
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockDispatchData.recentShipments
                                        : const <DispatchItem>[]);

                              final totalCount = hasData
                                  ? realItems.length
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockDispatchData
                                              .defaultSummary
                                              .totalShipments
                                        : 0);
                              final inTransitCount = hasData
                                  ? realItems
                                        .where(
                                          (d) =>
                                              d.statusLabel ==
                                              'Dalam Perjalanan',
                                        )
                                        .length
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockDispatchData
                                              .defaultSummary
                                              .inTransitCount
                                        : 0);
                              final completedCount = hasData
                                  ? realItems
                                        .where(
                                          (d) =>
                                              d.statusLabel == 'Selesai' ||
                                              d.statusLabel == 'Diterima',
                                        )
                                        .length
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockDispatchData
                                              .defaultSummary
                                              .completedCount
                                        : 0);
                              final rejectedCount = hasData
                                  ? realItems
                                        .where(
                                          (d) => d.statusLabel == 'Ditolak',
                                        )
                                        .length
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockDispatchData
                                              .defaultSummary
                                              .rejectedCount
                                        : 0);

                              final summary = DispatchSummary(
                                distributorName:
                                    user?.organization ?? 'DISTRIBUTOR A',
                                greetingTitle: _getGreetingTitle(),
                                greetingSubtitle: _getGreetingSubtitle(),
                                frostScoreAverageLabel: 'FrostScore rata-rata',
                                frostScoreStatusText: realItems.isNotEmpty
                                    ? '${realItems.length} batch tercatat di cloud'
                                    : 'Belum ada pengiriman aktif',
                                totalShipments: totalCount,
                                inTransitCount: inTransitCount,
                                completedCount: completedCount,
                                rejectedCount: rejectedCount,
                              );

                              return DispatchView(
                                summary: summary,
                                recentShipments: itemsToDisplay,
                                onCreateShipmentPressed: _openNewDispatch,
                                onViewAllPressed: () => _handleNavSelected(1),
                                onItemPressed: _openDispatchDetail,
                              );
                            },
                          )
                        : StreamBuilder<List<FishBatchItem>>(
                            key: ValueKey(
                              'receiving_view_stream_${user?.email}',
                            ),
                            stream: FirestoreDispatchService.instance
                                .streamReceivingBatches(user: user),
                            builder: (context, snapshot) {
                              final realBatches = snapshot.data ?? const [];
                              final hasData = snapshot.hasData;
                              final batchesToDisplay = hasData
                                  ? realBatches
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockReceivingData.pendingBatches
                                        : const <FishBatchItem>[]);

                              final pendingCount = hasData
                                  ? realBatches
                                        .where(
                                          (b) =>
                                              b.status ==
                                              BatchInspectionStatus.pending,
                                        )
                                        .length
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockReceivingData
                                              .defaultSummary
                                              .pendingBatchCount
                                        : 0);

                              final receivedCount = hasData
                                  ? realBatches
                                        .where(
                                          (b) =>
                                              b.status ==
                                              BatchInspectionStatus.received,
                                        )
                                        .length
                                  : (user?.email == 'sasa@smartfrost.id'
                                        ? MockReceivingData
                                              .defaultSummary
                                              .receivedBatchCount
                                        : 0);

                              final summary = ReceivingSummary(
                                distributorName:
                                    user?.organization ?? 'DISTRIBUTOR B',
                                pendingBatchCount: pendingCount,
                                receivedBatchCount: receivedCount,
                                actionPrompt:
                                    'Pindai coolbox tiba untuk mulai verifikasi suhu & kondisi',
                              );

                              return ReceivingView(
                                summary: summary,
                                pendingBatches: batchesToDisplay,
                                onScanPressed: _openReceivingScanner,
                                onBatchItemPressed: _openReceivingDetail,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
        }

        return MainShellLayout(
          currentIndex: _selectedNavIndex,
          userInitials: _computeInitials(isDispatch),
          scanLabel: isDispatch ? 'Kirim' : 'Scan QR',
          onTabSelected: _handleNavSelected,
          onScanPressed: isDispatch ? _openNewDispatch : _openReceivingScanner,
          onProfilePressed: _openProfile,
          child: bodyContent,
        );
      },
    );
  }
}
