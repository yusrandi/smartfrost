/**
 * Official FrostScore (Cold Chain Integrity Score) Calculator
 * Based on the SMART-FROST Cold Chain Engineering Specification.
 *
 * Master Formula:
 *   FrostScore = max(0, 100 - P_total)
 *   P_total = 0.40 * P_thermal + 0.25 * P_exposure + 0.15 * P_stability + 0.20 * P_anomaly
 *
 * Official Categorization:
 *   90 – 100 : Sangat Baik / Aman (Hijau)
 *   75 – 89.99: Baik (Kuning-Hijau)
 *   60 – 74.99: Waspada (Kuning / Oranye)
 *    0 – 59.99: Risiko Tinggi (Merah)
 */

export type FrostScoreCategory = 'Sangat Baik' | 'Baik' | 'Waspada' | 'Risiko Tinggi';

export interface FrostScoreResult {
  score: number;          // 0 - 100
  pTotal: number;         // 0 - 100 (Total penalty)
  pThermal: number;       // 0 - 100 (Dosis termal kumulatif)
  pExposure: number;      // 0 - 100 (Durasi paparan kritis)
  pStability: number;     // 0 - 100 (Fluktuasi / variansi suhu)
  pAnomaly: number;       // 0 - 100 (Anomali AI/Edge)
  status: FrostScoreCategory;
  badgeStyle: {
    badgeClass: string;
    dotClass: string;
    textClass: string;
  };
}

export interface TemperatureSample {
  temp: number;
  anomalyScore?: number; // 0: Normal, 10: Ringan, 15: Sedang, 25: Ekstrem
}

export class FrostScoreCalculator {
  static readonly SAFE_TEMP_LIMIT = 4.0;         // Batas suhu aman (°C)
  static readonly THERMAL_DOSE_LIMIT = 15.0;     // Batas toleransi termal (°C·jam)
  static readonly VARIANCE_LIMIT = 4.0;          // Batas variansi maksimum (°C²)
  static readonly DEFAULT_INTERVAL_MINUTES = 5;  // 5 menit per interval

  static readonly WEIGHT_THERMAL = 0.40;
  static readonly WEIGHT_EXPOSURE = 0.25;
  static readonly WEIGHT_STABILITY = 0.15;
  static readonly WEIGHT_ANOMALY = 0.20;

  /**
   * Calculates FrostScore from a list of temperature samples.
   */
  static calculate(samples: TemperatureSample[]): FrostScoreResult {
    if (!samples || samples.length === 0) {
      return this._formatResult(0, 0, 0, 0, 100);
    }

    const k = samples.length;
    let accumulatedDH = 0;
    let exposureViolations = 0;
    let anomalyTotal = 0;

    // 1. P_thermal & P_exposure & P_anomaly accumulation
    for (let i = 0; i < k; i++) {
      const s = samples[i];
      const temp = s.temp;

      // P_thermal: Delta T > 4°C
      const deltaT = Math.max(0, temp - this.SAFE_TEMP_LIMIT);
      const deltaDH = deltaT * (this.DEFAULT_INTERVAL_MINUTES / 60);
      accumulatedDH += deltaDH;

      // P_exposure: Count intervals where temp > 4°C
      if (temp > this.SAFE_TEMP_LIMIT) {
        exposureViolations++;
      }

      // P_anomaly: Accumulate AI/Edge anomalies
      if (typeof s.anomalyScore === 'number' && s.anomalyScore > 0) {
        anomalyTotal += s.anomalyScore;
      }
    }

    // 2. Compute individual penalties
    // P_thermal = min(100, (DH_k / 15) * 100)
    const pThermal = Math.min(100, (accumulatedDH / this.THERMAL_DOSE_LIMIT) * 100);

    // P_exposure = (E_k / k) * 100
    const pExposure = k > 0 ? (exposureViolations / k) * 100 : 0;

    // 3. P_stability: Mean & Variance across all readings
    let pStability = 0;
    if (k > 1) {
      const mean = samples.reduce((acc, curr) => acc + curr.temp, 0) / k;
      const variance =
        samples.reduce((acc, curr) => acc + Math.pow(curr.temp - mean, 2), 0) / k;
      // P_stability = min(100, (variance / 4) * 100)
      pStability = Math.min(100, (variance / this.VARIANCE_LIMIT) * 100);
    }

    // P_anomaly = min(100, accumulated)
    const pAnomaly = Math.min(100, anomalyTotal);

    // 4. P_total = 0.40 * Pthermal + 0.25 * Pexposure + 0.15 * Pstability + 0.20 * Panomaly
    const pTotal =
      this.WEIGHT_THERMAL * pThermal +
      this.WEIGHT_EXPOSURE * pExposure +
      this.WEIGHT_STABILITY * pStability +
      this.WEIGHT_ANOMALY * pAnomaly;

    // 5. FrostScore = max(0, 100 - P_total)
    const rawScore = 100 - pTotal;
    const finalScore = Math.max(0, Math.min(100, Number(rawScore.toFixed(1))));

    return this._formatResult(pThermal, pExposure, pStability, pAnomaly, finalScore);
  }

  /**
   * Determines status category and badge styling based on official threshold.
   */
  static getCategory(score: number): FrostScoreCategory {
    if (score >= 90) return 'Sangat Baik';
    if (score >= 75) return 'Baik';
    if (score >= 60) return 'Waspada';
    return 'Risiko Tinggi';
  }

  static getBadgeStyle(score: number): {
    badgeClass: string;
    dotClass: string;
    textClass: string;
  } {
    const status = this.getCategory(score);
    if (status === 'Sangat Baik') {
      return {
        badgeClass: 'bg-emerald-50 text-emerald-700 border-emerald-200/60',
        dotClass: 'bg-emerald-500',
        textClass: 'text-emerald-700',
      };
    }
    if (status === 'Baik') {
      return {
        badgeClass: 'bg-lime-50 text-lime-700 border-lime-200/60',
        dotClass: 'bg-lime-500',
        textClass: 'text-lime-700',
      };
    }
    if (status === 'Waspada') {
      return {
        badgeClass: 'bg-amber-50 text-amber-700 border-amber-200/60',
        dotClass: 'bg-amber-500',
        textClass: 'text-amber-700',
      };
    }
    return {
      badgeClass: 'bg-rose-50 text-rose-700 border-rose-200/60',
      dotClass: 'bg-rose-500',
      textClass: 'text-rose-700',
    };
  }

  private static _formatResult(
    pThermal: number,
    pExposure: number,
    pStability: number,
    pAnomaly: number,
    score: number
  ): FrostScoreResult {
    const pTotal =
      this.WEIGHT_THERMAL * pThermal +
      this.WEIGHT_EXPOSURE * pExposure +
      this.WEIGHT_STABILITY * pStability +
      this.WEIGHT_ANOMALY * pAnomaly;

    const status = this.getCategory(score);
    const badgeStyle = this.getBadgeStyle(score);

    return {
      score,
      pTotal: Number(pTotal.toFixed(2)),
      pThermal: Number(pThermal.toFixed(2)),
      pExposure: Number(pExposure.toFixed(2)),
      pStability: Number(pStability.toFixed(2)),
      pAnomaly: Number(pAnomaly.toFixed(2)),
      status,
      badgeStyle,
    };
  }
}
