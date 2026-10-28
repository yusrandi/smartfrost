import '../../domain/models/history_batch_item.dart';
import '../../domain/models/history_filter.dart';

/// Mock dataset for Riwayat (History) matching both Pengiriman and Penerimaan screens.
abstract final class MockHistoryData {
  static const List<HistoryBatchItem> dispatchHistoryItems = [
    HistoryBatchItem(
      id: 'disp-hist-1',
      batchCode: 'SFR-KK-201',
      fishType: 'Ikan Bandeng',
      weightLabel: '80 - 90 kg',
      route: 'Dermaga Maccini Baji → Pulau Jangang-Jangangan',
      date: '26 Okt 2026, 09.46',
      statusLabel: 'Menunggu periksa',
      filterCategory: HistoryFilterStatus.active,
      isSynchronized: true,
    ),
    HistoryBatchItem(
      id: 'disp-hist-2',
      batchCode: 'SFR-PKP-240601',
      fishType: 'Kerapu',
      weightLabel: '85 kg',
      route: 'Pulau Balang Lompo → Pelabuhan Maccini Baji',
      date: '01 Jun 2025, 15.30',
      statusLabel: 'Menunggu periksa',
      filterCategory: HistoryFilterStatus.active,
      isSynchronized: true,
    ),
  ];

  static const List<HistoryBatchItem> receivingHistoryItems = [
    HistoryBatchItem(
      id: 'recv-hist-1',
      batchCode: 'SFR-KK-201',
      fishType: 'Ikan Bandeng',
      weightLabel: '80 - 90 kg',
      supplier: 'Bahari Sejahtera',
      date: '26 Okt 2026, 09.46',
      statusLabel: 'Menunggu periksa',
      filterCategory: HistoryFilterStatus.active,
      isSynchronized: true,
    ),
    HistoryBatchItem(
      id: 'recv-hist-2',
      batchCode: 'SFR-PKP-240601',
      fishType: 'Kerapu',
      weightLabel: '85 kg',
      supplier: 'Bahari Sejahtera',
      date: '01 Jun 2025, 15.30',
      statusLabel: 'Menunggu periksa',
      filterCategory: HistoryFilterStatus.active,
      isSynchronized: true,
    ),
  ];
}
