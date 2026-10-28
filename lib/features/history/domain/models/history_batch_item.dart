import 'history_filter.dart';

/// Entity representing an archival or active fish batch record in history.
class HistoryBatchItem {
  const HistoryBatchItem({
    required this.id,
    required this.batchCode,
    required this.fishType,
    required this.weightLabel,
    required this.date,
    this.route,
    this.supplier,
    this.statusLabel = 'Menunggu periksa',
    this.filterCategory = HistoryFilterStatus.active,
    this.isSynchronized = true,
  });

  final String id;
  final String batchCode;
  final String fishType;
  final String weightLabel;
  final String? route;
  final String? supplier;
  final String date;
  final String statusLabel;
  final HistoryFilterStatus filterCategory;
  final bool isSynchronized;

  String get formattedFishWeight => '$fishType • $weightLabel';
}
