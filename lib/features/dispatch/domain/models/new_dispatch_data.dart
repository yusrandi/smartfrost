/// Domain model capturing dispatch creation data through the multi-step form.
class NewDispatchData {
  const NewDispatchData({
    this.coolboxId = '',
    this.coolboxIds = const [],
    this.senderName = '',
    this.fishType = '',
    this.weightRange = '',
    this.originLocation = '',
    this.destinationLocation = '',
    this.receiverName = '',
    this.batchId = '',
    this.dataStatus = 'Online • siap sinkron',
  });

  final String coolboxId;
  final List<String> coolboxIds;
  final String senderName;
  final String fishType;
  final String weightRange;
  final String originLocation;
  final String destinationLocation;
  final String receiverName;
  final String batchId;
  final String dataStatus;

  /// Generates a unique batch ID tied to the selected coolbox and current timestamp
  static String generateBatchId({String? coolboxId}) {
    final now = DateTime.now();
    final randomSuffix = (now.millisecondsSinceEpoch % 90000 + 10000)
        .toString();
    if (coolboxId != null && coolboxId.isNotEmpty) {
      final clean = coolboxId
          .toUpperCase()
          .replaceAll('SFR-', '')
          .replaceAll(RegExp(r'[^A-Z0-9]'), '');
      return 'SFR-$clean-$randomSuffix';
    }
    return 'SFR-BATCH-$randomSuffix';
  }

  bool get isFishDataComplete =>
      fishType.isNotEmpty &&
      weightRange.isNotEmpty &&
      originLocation.isNotEmpty &&
      destinationLocation.isNotEmpty &&
      receiverName.isNotEmpty;

  String get routeDisplay =>
      originLocation.isNotEmpty && destinationLocation.isNotEmpty
      ? '$originLocation → $destinationLocation'
      : 'Rute belum dipilih';

  String get cargoDisplay => fishType.isNotEmpty && weightRange.isNotEmpty
      ? '$fishType • $weightRange'
      : (fishType.isNotEmpty ? fishType : 'Muatan belum dipilih');

  NewDispatchData copyWith({
    String? coolboxId,
    List<String>? coolboxIds,
    String? senderName,
    String? fishType,
    String? weightRange,
    String? originLocation,
    String? destinationLocation,
    String? receiverName,
    String? batchId,
    String? dataStatus,
  }) {
    final effectiveCoolbox = coolboxId ?? this.coolboxId;
    return NewDispatchData(
      coolboxId: effectiveCoolbox,
      coolboxIds:
          coolboxIds ?? (coolboxId != null ? [coolboxId] : this.coolboxIds),
      senderName: senderName ?? this.senderName,
      fishType: fishType ?? this.fishType,
      weightRange: weightRange ?? this.weightRange,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      receiverName: receiverName ?? this.receiverName,
      batchId: batchId ?? this.batchId,
      dataStatus: dataStatus ?? this.dataStatus,
    );
  }
}
