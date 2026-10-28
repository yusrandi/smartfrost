/// Domain entity for an outbound fish shipment item.
class DispatchItem {
  const DispatchItem({
    required this.id,
    required this.batchCode,
    required this.fishType,
    required this.weightKg,
    required this.origin,
    required this.destination,
    required this.formattedDate,
    this.statusLabel = 'Menunggu periksa',
    this.isSynchronized = true,
  });

  final String id;
  final String batchCode;
  final String fishType;
  final double weightKg;
  final String origin;
  final String destination;
  final String formattedDate;
  final String statusLabel;
  final bool isSynchronized;

  String get formattedFishWeight =>
      '$fishType • ${weightKg.toStringAsFixed(0)} kg';
  String get routeDescription => '$origin → $destination';
}
