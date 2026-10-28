import '../../domain/models/dispatch_item.dart';
import '../../domain/models/dispatch_summary.dart';

/// Mock data for outbound dispatch (Distributor A).
abstract final class MockDispatchData {
  static const DispatchSummary defaultSummary = DispatchSummary(
    distributorName: 'DISTRIBUTOR A',
    greetingTitle: 'Selamat pagi, Bahari.',
    greetingSubtitle: 'Siapkan dan pantau pengiriman hari ini.',
    frostScoreAverageLabel: 'FrostScore rata-rata',
    frostScoreStatusText: 'Belum ada data sensor terverifikasi',
    totalShipments: 1,
    inTransitCount: 1,
    completedCount: 0,
    rejectedCount: 0,
  );

  static const List<DispatchItem> recentShipments = [
    DispatchItem(
      id: 'dispatch-001',
      batchCode: 'SFR-PKP-240601',
      fishType: 'Kerapu',
      weightKg: 85.0,
      origin: 'Pulau Balang Lompo',
      destination: 'Pelabuhan Maccini Baji',
      formattedDate: '01 Jun 2025, 15.30',
      statusLabel: 'Menunggu periksa',
      isSynchronized: true,
    ),
  ];
}
