import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import type { RegionRiskSummary } from '../models/risk_map_types';
import type { RtdbDistributor } from '../datasources/distributor_rtdb_datasource';

function normalizeName(raw: string): string {
  let s = raw.trim().toLowerCase();
  if (s.startsWith('pulau ')) s = s.substring(6).trim();
  if (s.startsWith('distributor ')) s = s.substring(12).trim();
  if (s.startsWith('dermaga ')) s = s.substring(8).trim();
  return s.replace(/[*]/g, '').trim();
}

/**
 * Builds regional risk summaries using ONLY real data from the `distributors` table
 * correlated with actual `dispatches` from Firebase Realtime Database.
 * No dummy or fictional locations are injected.
 */
export function aggregateDistributorsRisk(
  distributors: RtdbDistributor[],
  dispatches: DispatchSummaryItem[]
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

    // Correlate with real dispatches in the database matching this distributor
    const matchedBatches = dispatches.filter((b) => {
      const orig = normalizeName(b.origin || '');
      const dest = normalizeName(b.destination || '');
      return (
        orig === normKey ||
        orig.includes(normKey) ||
        normKey.includes(orig) ||
        dest === normKey ||
        dest.includes(normKey) ||
        normKey.includes(dest)
      );
    });

    const liveHigh = matchedBatches.filter(
      (b) => b.frostScore >= 60 || b.riskLevel === 'Tinggi'
    ).length;
    const liveMed = matchedBatches.filter(
      (b) => (b.frostScore >= 30 && b.frostScore < 60) || b.riskLevel === 'Perhatian'
    ).length;
    const liveLow = matchedBatches.filter(
      (b) => b.frostScore < 30 && b.riskLevel === 'Rendah'
    ).length;

    const liveKg = matchedBatches.reduce((acc, b) => acc + (b.weightKg || 0), 0);
    const liveAnomalies = matchedBatches.filter(
      (b) => b.lastTemp > 4 || b.frostScore >= 40
    ).length;

    // Find highest risk batch in database
    const sorted = [...matchedBatches].sort((a, b) => b.frostScore - a.frostScore);
    const topLive = sorted[0];

    const batchCount = matchedBatches.length;
    const totalTonnageTon = parseFloat((liveKg / 1000).toFixed(2));
    const highRiskCount = liveHigh;
    const mediumRiskCount = liveMed;
    const lowRiskCount = liveLow;
    const anomaliesCount = liveAnomalies;

    const topBatchId = topLive ? topLive.batchId : '-';
    const topScore = topLive ? topLive.frostScore : 0;

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
