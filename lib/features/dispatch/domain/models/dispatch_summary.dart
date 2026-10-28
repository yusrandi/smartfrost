/// Domain model representing outbound dispatch operations (Distributor A).
class DispatchSummary {
  const DispatchSummary({
    required this.distributorName,
    required this.greetingTitle,
    required this.greetingSubtitle,
    required this.frostScoreAverageLabel,
    required this.frostScoreStatusText,
    required this.totalShipments,
    required this.inTransitCount,
    required this.completedCount,
    required this.rejectedCount,
  });

  final String distributorName;
  final String greetingTitle;
  final String greetingSubtitle;
  final String frostScoreAverageLabel;
  final String frostScoreStatusText;
  final int totalShipments;
  final int inTransitCount;
  final int completedCount;
  final int rejectedCount;
}
