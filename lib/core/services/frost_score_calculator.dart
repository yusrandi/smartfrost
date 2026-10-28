import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Official 4-tier FrostScore risk categories according to
/// the SMART-FROST Cold Chain Engineering Specification:
/// - 90 - 100 : Sangat Baik (Aman)
/// - 75 - 89.9: Baik (Aman Terkendali)
/// - 60 - 74.9: Waspada (Perlu Perhatian)
/// -  0 - 59.9: Risiko Tinggi (Kritis)
enum FrostScoreCategory {
  sangatBaik('Sangat Baik'),
  baik('Baik'),
  waspada('Waspada'),
  risikoTinggi('Risiko Tinggi');

  const FrostScoreCategory(this.label);
  final String label;
}

class FrostScoreResult {
  const FrostScoreResult({
    required this.score,
    required this.pTotal,
    required this.pThermal,
    required this.pExposure,
    required this.pStability,
    required this.pAnomaly,
    required this.category,
  });

  final double score;
  final double pTotal;
  final double pThermal;
  final double pExposure;
  final double pStability;
  final double pAnomaly;
  final FrostScoreCategory category;

  int get scoreInt => score.round().clamp(0, 100);

  Color get statusColor {
    switch (category) {
      case FrostScoreCategory.sangatBaik:
        return const Color(0xFF0E8367); // Emerald Green
      case FrostScoreCategory.baik:
        return const Color(0xFF70A83B); // Lime Green
      case FrostScoreCategory.waspada:
        return const Color(0xFFD97706); // Amber / Orange
      case FrostScoreCategory.risikoTinggi:
        return const Color(0xFFDC2626); // Rose / Red
    }
  }

  Color get badgeBackground {
    switch (category) {
      case FrostScoreCategory.sangatBaik:
        return const Color(0xFFECFDF5);
      case FrostScoreCategory.baik:
        return const Color(0xFFF7FEE7);
      case FrostScoreCategory.waspada:
        return const Color(0xFFFFFBEB);
      case FrostScoreCategory.risikoTinggi:
        return const Color(0xFFFEF2F2);
    }
  }

  Color get badgeBorder {
    switch (category) {
      case FrostScoreCategory.sangatBaik:
        return const Color(0xFFA7F3D0);
      case FrostScoreCategory.baik:
        return const Color(0xFFD9F99D);
      case FrostScoreCategory.waspada:
        return const Color(0xFFFDE68A);
      case FrostScoreCategory.risikoTinggi:
        return const Color(0xFFFECACA);
    }
  }
}

class TemperatureSample {
  const TemperatureSample({
    required this.temp,
    this.anomalyScore = 0.0,
  });

  final double temp;
  final double anomalyScore;
}

class FrostScoreCalculator {
  static const double safeTempLimit = 4.0; // °C
  static const double thermalDoseLimit = 15.0; // °C·jam
  static const double varianceLimit = 4.0; // °C²
  static const int defaultIntervalMinutes = 5;

  static const double weightThermal = 0.40;
  static const double weightExposure = 0.25;
  static const double weightStability = 0.15;
  static const double weightAnomaly = 0.20;

  /// Calculates FrostScore according to official SMART-FROST master formula:
  /// FrostScore = max(0, 100 - P_total)
  /// P_total = 0.40 * P_thermal + 0.25 * P_exposure + 0.15 * P_stability + 0.20 * P_anomaly
  static FrostScoreResult calculate(List<TemperatureSample> samples) {
    if (samples.isEmpty) {
      return _formatResult(0, 0, 0, 0, 100.0);
    }

    final k = samples.length;
    double accumulatedDh = 0.0;
    int exposureViolations = 0;
    double anomalyTotal = 0.0;

    for (int i = 0; i < k; i++) {
      final s = samples[i];
      final temp = s.temp;

      // P_thermal: Delta T > 4°C
      final deltaT = math.max(0.0, temp - safeTempLimit);
      final deltaDh = deltaT * (defaultIntervalMinutes / 60.0);
      accumulatedDh += deltaDh;

      // P_exposure: Violations above 4°C
      if (temp > safeTempLimit) {
        exposureViolations++;
      }

      // P_anomaly: AI/Edge detected anomalies
      if (s.anomalyScore > 0) {
        anomalyTotal += s.anomalyScore;
      }
    }

    // 1. P_thermal = min(100, (DH / 15) * 100)
    final pThermal = math.min(100.0, (accumulatedDh / thermalDoseLimit) * 100.0);

    // 2. P_exposure = (E_k / k) * 100
    final pExposure = k > 0 ? (exposureViolations / k) * 100.0 : 0.0;

    // 3. P_stability: Variance across all readings
    double pStability = 0.0;
    if (k > 1) {
      final mean = samples.fold<double>(0.0, (sum, curr) => sum + curr.temp) / k;
      final variance = samples.fold<double>(
            0.0,
            (sum, curr) => sum + math.pow(curr.temp - mean, 2),
          ) /
          k;
      pStability = math.min(100.0, (variance / varianceLimit) * 100.0);
    }

    // 4. P_anomaly = min(100, anomalyTotal)
    final pAnomaly = math.min(100.0, anomalyTotal);

    // 5. P_total = 0.40 * Pth + 0.25 * Pexp + 0.15 * Pstab + 0.20 * Panom
    final pTotal = (weightThermal * pThermal) +
        (weightExposure * pExposure) +
        (weightStability * pStability) +
        (weightAnomaly * pAnomaly);

    final rawScore = 100.0 - pTotal;
    final finalScore = math.max(0.0, math.min(100.0, rawScore));

    return _formatResult(pThermal, pExposure, pStability, pAnomaly, finalScore);
  }

  /// Convenience method when only temperature values are known.
  static FrostScoreResult calculateFromTemperatures(List<double> temperatures) {
    final samples = temperatures.map((t) => TemperatureSample(temp: t)).toList();
    return calculate(samples);
  }

  /// Calculates a single-point snapshot or estimate from current temperature.
  /// If temperature <= 4°C, FrostScore remains optimal (e.g. 96-100).
  /// If temperature > 4°C, progressive thermal penalty is assessed.
  static FrostScoreResult calculateSingleSnapshot(double temp) {
    if (temp <= safeTempLimit) {
      // Safe cold chain baseline (e.g. -2°C to 4°C)
      return _formatResult(0, 0, 0, 0, 96.0);
    }

    // Above safe limit:
    // e.g. 8.1°C -> deltaT = 4.1°C
    final deltaT = temp - safeTempLimit;
    final pThermal = math.min(100.0, (deltaT / 4.0) * 60.0);
    final pExposure = 70.0;
    final pStability = math.min(100.0, (deltaT / 2.0) * 30.0);
    final pAnomaly = 25.0;

    final pTotal = (weightThermal * pThermal) +
        (weightExposure * pExposure) +
        (weightStability * pStability) +
        (weightAnomaly * pAnomaly);

    final finalScore = math.max(0.0, math.min(100.0, 100.0 - pTotal));
    return _formatResult(pThermal, pExposure, pStability, pAnomaly, finalScore);
  }

  static FrostScoreCategory getCategory(num score) {
    if (score >= 90) return FrostScoreCategory.sangatBaik;
    if (score >= 75) return FrostScoreCategory.baik;
    if (score >= 60) return FrostScoreCategory.waspada;
    return FrostScoreCategory.risikoTinggi;
  }

  static Color getStatusColor(num score) {
    final cat = getCategory(score);
    switch (cat) {
      case FrostScoreCategory.sangatBaik:
        return const Color(0xFF0E8367);
      case FrostScoreCategory.baik:
        return const Color(0xFF70A83B);
      case FrostScoreCategory.waspada:
        return const Color(0xFFD97706);
      case FrostScoreCategory.risikoTinggi:
        return const Color(0xFFDC2626);
    }
  }

  static FrostScoreResult _formatResult(
    double pThermal,
    double pExposure,
    double pStability,
    double pAnomaly,
    double score,
  ) {
    final pTotal = (weightThermal * pThermal) +
        (weightExposure * pExposure) +
        (weightStability * pStability) +
        (weightAnomaly * pAnomaly);

    final category = getCategory(score);

    return FrostScoreResult(
      score: double.parse(score.toStringAsFixed(1)),
      pTotal: double.parse(pTotal.toStringAsFixed(2)),
      pThermal: double.parse(pThermal.toStringAsFixed(2)),
      pExposure: double.parse(pExposure.toStringAsFixed(2)),
      pStability: double.parse(pStability.toStringAsFixed(2)),
      pAnomaly: double.parse(pAnomaly.toStringAsFixed(2)),
      category: category,
    );
  }
}

