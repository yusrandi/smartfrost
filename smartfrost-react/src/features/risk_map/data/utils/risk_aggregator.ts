import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import type { RegionRiskSummary } from '../models/risk_map_types';
import type { RtdbDistributor } from '../datasources/distributor_rtdb_datasource';
import { findCoolboxSuhu, type CoolboxSuhuState } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator } from '../../../dashboard/domain/services/frost_score_calculator';

function normalizeName(raw: string): string {
  let s = raw.trim().toLowerCase();
  if (s.startsWith('pulau ')) s = s.substring(6).trim();
  if (s.startsWith('distributor ')) s = s.substring(12).trim();
  if (s.startsWith('dermaga ')) s = s.substring(8).trim();
  return s.replace(/[*]/g, '').trim();
}

/**
 * Builds regional risk summaries using ONLY real data from the `distributors` table
 * correlated with actual `dispatches` from Firebase Realtime Database and live `/suhu` telemetry.
 * No dummy or fictional locations are injected.
 */
export function aggregateDistributorsRisk(
  distributors: RtdbDistributor[],
  dispatches: DispatchSummaryItem[],
  suhuMap?: Record<string, CoolboxSuhuState>
): RegionRiskSummary[] {
  if (!distributors || distributors.length === 0) {
    return [];
  }

  // Deduplicate distributors by normalized key if any duplicate entries exist in database
  const uniqueDistributors = new Map<string, RtdbDistributor>();

  distributors.forEach((dist) => {
    const key = normalizeName(dist.name || dist.storeLocation);
    if (!uniqueDistributors.has(key)) {
      uniqueDistributors.set(key, dist);
    }
  });

  const result: RegionRiskSummary[] = Array.from(uniqueDistributors.values()).map((dist) => {
    const normKey = normalizeName(dist.name || dist.storeLocation);

    // Correlate with real dispatches strictly matching the SENDER (origin / pengirim).
    // The sender is the source of the batch; receivers are not attributed with shipment risk.
    const matchedBatches = dispatches.filter((b) => {
      const orig = normalizeName(b.origin || '');
      return (
        orig === normKey ||
        orig.includes(normKey) ||
        normKey.includes(orig)
      );
    });

    let liveHigh = 0;
    let liveMed = 0;
    let liveLow = 0;
    let liveAnomalies = 0;

    matchedBatches.forEach((b) => {
      const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, b.coolboxId) : null;
      const score = boxSuhu?.frostScore?.score ?? b.frostScore;
      const cat = FrostScoreCalculator.getCategory(score);

      if (cat === 'Risiko Tinggi' || score < 60 || b.riskLevel === 'Risiko Tinggi' || b.riskLevel === 'Tinggi') {
        liveHigh++;
      } else if (cat === 'Waspada' || (score >= 60 && score < 75) || b.riskLevel === 'Perhatian' || b.riskLevel === 'Waspada') {
        liveMed++;
      } else {
        liveLow++;
      }

      const tempVal = boxSuhu?.latestAirTemp ?? b.lastTemp;
      if ((typeof tempVal === 'number' && tempVal > 4.0) || score < 60) {
        liveAnomalies++;
      }
    });

    const liveKg = matchedBatches.reduce((acc, b) => acc + (b.weightKg || 0), 0);

    // Find most critical batch (lowest FrostScore)
    const sorted = [...matchedBatches].sort((a, b) => {
      const scoreA = (suhuMap ? findCoolboxSuhu(suhuMap, a.coolboxId)?.frostScore?.score : null) ?? a.frostScore;
      const scoreB = (suhuMap ? findCoolboxSuhu(suhuMap, b.coolboxId)?.frostScore?.score : null) ?? b.frostScore;
      return scoreA - scoreB;
    });
    const topLive = sorted[0];

    const batchCount = matchedBatches.length;
    const totalTonnageTon = parseFloat((liveKg / 1000).toFixed(2));
    const highRiskCount = liveHigh;
    const mediumRiskCount = liveMed;
    const lowRiskCount = liveLow;
    const anomaliesCount = liveAnomalies;

    const topBatchId = topLive ? topLive.batchId : '-';
    const topScore = topLive ? ((suhuMap ? findCoolboxSuhu(suhuMap, topLive.coolboxId)?.frostScore?.score : null) ?? topLive.frostScore) : 0;

    const dominantRisk: 'Tinggi' | 'Perhatian' | 'Rendah' =
      highRiskCount > 0 ? 'Tinggi' : mediumRiskCount > 0 ? 'Perhatian' : 'Rendah';

    return {
      id: dist.id || normKey,
      name: dist.name || dist.storeLocation,
      batchCount,
      totalTonnageTon,
      highRiskCount,
      mediumRiskCount,
      lowRiskCount,
      anomaliesCount,
      topBatchId,
      topScore,
      point: {
        lat: dist.latitude,
        lng: dist.longitude,
      },
      dominantRisk,
    };
  });

  // Sort: distributors with highest risk first, then by batch count, then alphabetically
  return result.sort((a, b) => {
    if (b.highRiskCount !== a.highRiskCount) return b.highRiskCount - a.highRiskCount;
    if (b.mediumRiskCount !== a.mediumRiskCount) return b.mediumRiskCount - a.mediumRiskCount;
    if (b.batchCount !== a.batchCount) return b.batchCount - a.batchCount;
    return a.name.localeCompare(b.name);
  });
}
