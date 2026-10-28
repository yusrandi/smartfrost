import '../../../../core/services/frost_score_calculator.dart';

/// Model representing the latest coolbox temperature telemetry from RTDB `/suhu/$coolboxId/latest`.
class CoolboxTemperatureData {
  const CoolboxTemperatureData({
    required this.coolboxId,
    this.averageTemperatureC,
    this.airTemperatureC,
    this.waterTemperatureC,
    this.humidityPct,
    this.airQualityValue,
    this.timestamp,
    this.frostScore,
  });

  final String coolboxId;
  final double? averageTemperatureC;
  final double? airTemperatureC;
  final double? waterTemperatureC;
  final double? humidityPct;
  final double? airQualityValue;
  final DateTime? timestamp;
  final int? frostScore;

  factory CoolboxTemperatureData.fromMap(
    String coolboxId,
    Map<String, dynamic> map,
  ) {
    double? toDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    final avgTemp = toDouble(
      map['average_temperature_c'] ?? map['averageTemperatureC'],
    );
    final airTemp = toDouble(
      map['air_temperature_c'] ?? map['airTemperatureC'],
    );
    final waterTemp = toDouble(
      map['water_temperature_c'] ?? map['waterTemperatureC'],
    );
    final effectiveTemp = airTemp ?? avgTemp;

    int? parsedScore = map['frostScore'] is num
        ? (map['frostScore'] as num).toInt()
        : null;

    if (parsedScore == null && effectiveTemp != null) {
      parsedScore = FrostScoreCalculator.calculateSingleSnapshot(effectiveTemp).scoreInt;
    }

    return CoolboxTemperatureData(
      coolboxId: coolboxId,
      averageTemperatureC: avgTemp,
      airTemperatureC: airTemp,
      waterTemperatureC: waterTemp,
      humidityPct: toDouble(
        map['humidity_pct'] ?? map['humidityPct'],
      ),
      airQualityValue: toDouble(
        map['air_quality_value'] ?? map['airQualityValue'],
      ),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString())
          : null,
      frostScore: parsedScore,
    );
  }
}
