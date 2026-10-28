/// Model representing an individual history reading from RTDB `/suhu/$coolboxId/history/$key`.
class CoolboxHistoryReading {
  const CoolboxHistoryReading({
    required this.key,
    required this.airTemperatureC,
    this.averageTemperatureC,
    this.waterTemperatureC,
    this.humidityPct,
    this.airQualityValue,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  final String key;
  final double airTemperatureC;
  final double? averageTemperatureC;
  final double? waterTemperatureC;
  final double? humidityPct;
  final double? airQualityValue;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  factory CoolboxHistoryReading.fromMap(String key, Map<String, dynamic> map) {
    double toDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    double? toDoubleNullable(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    final tsRaw = map['timestamp'];
    DateTime dt;
    if (tsRaw is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(tsRaw);
    } else if (tsRaw is String) {
      dt = DateTime.tryParse(tsRaw) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }

    return CoolboxHistoryReading(
      key: key,
      airTemperatureC: toDouble(
        map['air_temperature_c'] ?? map['airTemperatureC'],
      ),
      averageTemperatureC: toDoubleNullable(
        map['average_temperature_c'] ?? map['averageTemperatureC'],
      ),
      waterTemperatureC: toDoubleNullable(
        map['water_temperature_c'] ?? map['waterTemperatureC'],
      ),
      humidityPct: toDoubleNullable(
        map['humidity_pct'] ?? map['humidityPct'],
      ),
      airQualityValue: toDoubleNullable(
        map['air_quality_value'] ?? map['airQualityValue'],
      ),
      latitude: toDoubleNullable(map['latitude']),
      longitude: toDoubleNullable(map['longitude']),
      timestamp: dt,
    );
  }
}

