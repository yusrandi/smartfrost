enum BatchInspectionStatus {
  pending('Menunggu periksa'),
  inspected('Selesai periksa'),
  received('Diterima'),
  rejected('Ditolak');

  const BatchInspectionStatus(this.label);
  final String label;
}

/// Domain model representing a fish batch item ready for inspection and handover.
class FishBatchItem {
  const FishBatchItem({
    required this.id,
    required this.batchCode,
    this.coolboxId = '',
    required this.fishType,
    required this.weightKg,
    required this.supplierName,
    required this.formattedDate,
    this.status = BatchInspectionStatus.pending,
    this.isSynchronized = true,
  });

  final String id;
  final String batchCode;
  final String coolboxId;
  final String fishType;
  final double weightKg;
  final String supplierName;
  final String formattedDate;
  final BatchInspectionStatus status;
  final bool isSynchronized;

  String get formattedFishWeight =>
      '$fishType • ${weightKg.toStringAsFixed(0)} kg';
}
