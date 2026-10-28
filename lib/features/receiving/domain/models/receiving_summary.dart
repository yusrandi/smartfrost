/// Domain model representing the summary metrics of fish receiving operations.
class ReceivingSummary {
  const ReceivingSummary({
    required this.distributorName,
    required this.pendingBatchCount,
    required this.receivedBatchCount,
    required this.actionPrompt,
  });

  final String distributorName;
  final int pendingBatchCount;
  final int receivedBatchCount;
  final String actionPrompt;
}
