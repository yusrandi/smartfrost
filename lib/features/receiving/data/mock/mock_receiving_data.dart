import '../../domain/models/fish_batch_item.dart';
import '../../domain/models/receiving_summary.dart';

/// Explicit Mock Data Source for the Receiving / Beranda screen.
///
/// Separated clearly to facilitate seamless replacement with real API repositories in future phases.
abstract final class MockReceivingData {
  static const ReceivingSummary defaultSummary = ReceivingSummary(
    distributorName: 'DISTRIBUTOR B',
    pendingBatchCount: 1,
    receivedBatchCount: 0,
    actionPrompt: 'Perlu tindakan Anda',
  );

  static const List<FishBatchItem> pendingBatches = [
    FishBatchItem(
      id: 'batch-001',
      batchCode: 'SFR-PKP-240601',
      fishType: 'Kerapu',
      weightKg: 85.0,
      supplierName: 'Bahari Sejahtera',
      formattedDate: '01 Jun 2025, 15.30',
      status: BatchInspectionStatus.pending,
      isSynchronized: true,
    ),
  ];
}
