import { ref, onValue, type DataSnapshot } from 'firebase/database';
import { rtdb } from '../../../../firebase';
import type { DashboardMetrics, DispatchSummaryItem, TemperatureDataPoint } from '../models/dashboard_types';
import { MOCK_DISPATCH_ITEMS, MOCK_METRICS } from '../mock/dashboard_mock_data';
import { FrostScoreCalculator, type FrostScoreResult } from '../../domain/services/frost_score_calculator';

export interface CoolboxSuhuState {
  coolboxId: string;
  latestAirTemp: number | null;
  averageTemp: number | null;
  waterTemp: number | null;
  humidityPct: number | null;
  lastTimestampStr: string;
  dataPoints: TemperatureDataPoint[];
  frostScore?: FrostScoreResult;
}

export function normalizeCoolboxCandidates(raw: string): string[] {
  const clean = raw.trim();
  const candidates = [clean];
  const match = clean.match(/(SFR-CB-|CB-|SFR-)?0*(\d+)/i);
  if (match) {
    const num = parseInt(match[2], 10);
    const pad2 = `SFR-CB-${String(num).padStart(2, '0')}`;
    const pad3 = `SFR-CB-${String(num).padStart(3, '0')}`;
    const pad4 = `SFR-CB-${String(num).padStart(4, '0')}`;
    const cbPad2 = `CB-${String(num).padStart(2, '0')}`;
    const cbPad3 = `CB-${String(num).padStart(3, '0')}`;
    for (const c of [pad2, pad3, pad4, cbPad2, cbPad3]) {
      if (!candidates.includes(c)) candidates.push(c);
    }
  }
  return candidates;
}

export function findCoolboxSuhu(
  suhuMap: Record<string, CoolboxSuhuState>,
  targetId: string
): CoolboxSuhuState | null {
  if (!targetId) return null;
  const candidates = normalizeCoolboxCandidates(targetId);
  for (const c of candidates) {
    if (suhuMap[c]) return suhuMap[c];
  }
  const lower = targetId.toLowerCase().trim();
  for (const key of Object.keys(suhuMap)) {
    if (key.toLowerCase().trim() === lower) return suhuMap[key];
  }
  const numMatch = targetId.match(/\d+/);
  if (numMatch) {
    const targetNum = parseInt(numMatch[0], 10);
    for (const [key, state] of Object.entries(suhuMap)) {
      const kMatch = key.match(/\d+/);
      if (kMatch && parseInt(kMatch[0], 10) === targetNum) {
        return state;
      }
    }
  }
  return null;
}

const STANDARD_REGIONS = ['Balang Lompo', 'Sarappo', 'Sabutung', 'Karanrang', 'Gondongbali', 'Kulambing', 'Pangkajene'];

// Helper to format Realtime Database timestamp (epoch ms), ISO string, or Firestore-like object
function formatTimestamp(ts: unknown): { dateStr: string; timeStr: string } {
  try {
    let date: Date | null = null;
    if (typeof ts === 'number') {
      date = new Date(ts);
    } else if (typeof ts === 'string') {
      const asNum = Number(ts);
      date = new Date(Number.isNaN(asNum) ? ts : asNum);
    } else if (ts && typeof (ts as { seconds?: number }).seconds === 'number') {
      date = new Date((ts as { seconds: number }).seconds * 1000);
    }

    if (date && !isNaN(date.getTime())) {
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      return {
        dateStr: `${date.getDate()} ${monthNames[date.getMonth()]} ${date.getFullYear()}`,
        timeStr: `${hours}.${minutes} WITA`,
      };
    }
  } catch {
    // fallback below
  }
  return { dateStr: '-', timeStr: '-' };
}

// Parse weight from weightKg / weight / weightRange ("80 - 100 kg" => 90)
function parseWeightKg(data: Record<string, unknown>): number {
  if (typeof data.weightKg === 'number' && data.weightKg > 0) return data.weightKg;
  if (typeof data.weight === 'number' && data.weight > 0) return data.weight;
  if (typeof data.weightRange === 'string') {
    const numbers = data.weightRange.match(/\d+(\.\d+)?/g);
    if (numbers && numbers.length > 0) {
      if (numbers.length >= 2) {
        return Math.round((parseFloat(numbers[0]) + parseFloat(numbers[1])) / 2);
      }
      return parseFloat(numbers[0]);
    }
  }
  return 0;
}

function mapOperationalStatus(raw: string): DispatchSummaryItem['operationalStatus'] {
  const s = raw.toLowerCase();
  if (s.includes('tolak')) return 'Ditolak';
  if (s.includes('selesai periksa') || s.includes('periksa') || s.includes('pemeriksaan')) return 'Diperiksa';
  if (s.includes('diterima') || s.includes('selesai')) return 'Diterima';
  if (s.includes('menunggu')) return 'Menunggu';
  return 'Perjalanan';
}

export function buildDashboardData(snapshot: DataSnapshot) {
  const raw = snapshot.exists() ? (snapshot.val() as Record<string, Record<string, unknown>>) : {};

  const liveItems: DispatchSummaryItem[] = Object.entries(raw)
    .filter(([, v]) => v && typeof v === 'object')
    .map(([key, d], idx) => {
      const coolboxId = String(
        d.coolboxId || (Array.isArray(d.coolboxIds) && d.coolboxIds[0]) || `SFR-CB-${String(idx + 1).padStart(3, '0')}`
      );
      const batchId = String(d.batchId || d.dispatchId || key);
      let frostScore = typeof d.frostScore === 'number' ? d.frostScore : 90;
      frostScore = Math.max(0, Math.min(100, frostScore));

      // Official SMART-FROST Risk Category:
      // 90–100: Sangat Baik / Aman, 75–89: Baik, 60–74: Waspada, 0–59: Risiko Tinggi
      const riskLevel = FrostScoreCalculator.getCategory(frostScore);

      const { dateStr, timeStr } = formatTimestamp(d.createdAt ?? d.updatedAt);
      const lastTemp =
        typeof d.temperature === 'number' ? d.temperature : typeof d.lastTemp === 'number' ? d.lastTemp : 0;

      const weightDisplay =
        typeof d.weightRange === 'string' && d.weightRange.trim()
          ? d.weightRange.trim()
          : `${parseWeightKg(d)} kg`;

      return {
        id: key,
        batchId,
        coolboxId,
        commodity: String(d.fishType || d.commodity || '-'),
        weightKg: parseWeightKg(d),
        weightDisplay,
        origin: String(d.originLocation || d.origin || '-'),
        destination: String(d.destinationLocation || d.destination || '-'),
        dateStr,
        lastTemp,
        lastTempTime: timeStr,
        frostScore,
        riskLevel,
        syncStatus: (String(d.dataStatus || '').toLowerCase() === 'tertunda' ? 'Tertunda' : 'Tersinkron') as DispatchSummaryItem['syncStatus'],
        operationalStatus: mapOperationalStatus(String(d.status || 'Dalam Perjalanan')),
        _createdAt: typeof d.createdAt === 'number' ? d.createdAt : 0,
      } as DispatchSummaryItem & { _createdAt: number };
    });

  // Newest first (createdAt epoch), fallback to batchId
  (liveItems as Array<DispatchSummaryItem & { _createdAt: number }>).sort(
    (a, b) => b._createdAt - a._createdAt || b.batchId.localeCompare(a.batchId)
  );
  const items = liveItems.map((i) => {
    const { _createdAt, ...rest } = i as DispatchSummaryItem & { _createdAt: number };
    void _createdAt;
    return rest as DispatchSummaryItem;
  });

  const inTransit = items.filter((i) => i.operationalStatus === 'Perjalanan' || i.operationalStatus === 'Menunggu');
  const totalKg = items.reduce((acc, c) => acc + c.weightKg, 0);

  // Average FrostScore across all shipments
  const validScores = items.filter((i) => typeof i.frostScore === 'number');
  const averageFrostScore =
    validScores.length > 0
      ? Math.round(validScores.reduce((a, c) => a + c.frostScore, 0) / validScores.length)
      : 92;

  const metrics: DashboardMetrics = {
    totalShipments: items.length,
    totalTonnageKg: totalKg,
    inTransitCount: inTransit.length,
    inTransitSynced: inTransit.filter((i) => i.syncStatus === 'Tersinkron').length,
    inTransitDelayed: inTransit.filter((i) => i.syncStatus === 'Tertunda').length,
    averageFrostScore,
    highRiskBatchesCount: items.filter((i) => i.frostScore < 60).length,
  };

  const regionSet = new Set<string>(STANDARD_REGIONS);
  items.forEach((i) => {
    if (i.origin && i.origin !== '-') regionSet.add(i.origin);
    if (i.destination && i.destination !== '-') regionSet.add(i.destination);
  });

  return { items, metrics, isLiveFromFirestore: true, allRegions: Array.from(regionSet) };
}

/**
 * Subscribes to the Firebase Realtime Database `dispatches` node
 * (same node written by the SmartFrost Flutter mobile app, project `frost-score`).
 */
export class DashboardRtdbDatasource {
  static subscribeToDashboardData(
    onSuccess: (data: {
      items: DispatchSummaryItem[];
      metrics: DashboardMetrics;
      isLiveFromFirestore: boolean;
      allRegions: string[];
    }) => void,
    onError: (err: unknown) => void
  ) {
    const fallback = () =>
      onSuccess({
        items: MOCK_DISPATCH_ITEMS,
        metrics: MOCK_METRICS,
        isLiveFromFirestore: false,
        allRegions: STANDARD_REGIONS,
      });

    try {
      return onValue(
        ref(rtdb, 'dispatches'),
        (snapshot) => onSuccess(buildDashboardData(snapshot)),
        (error) => {
          console.error('Realtime Database listener failed:', error);
          onError(error);
          fallback();
        }
      );
    } catch (err) {
      onError(err);
      fallback();
      return () => {};
    }
  }

  /**
   * Subscribes to the Firebase Realtime Database `suhu` node
   * mapping coolbox IoT history & latest telemetry.
   */
  static subscribeToSuhuData(
    onData: (suhuMap: Record<string, CoolboxSuhuState>) => void,
    onError?: (err: unknown) => void
  ) {
    try {
      return onValue(
        ref(rtdb, 'suhu'),
        (snapshot) => {
          if (!snapshot.exists()) {
            onData({});
            return;
          }
          const raw = snapshot.val() as Record<string, Record<string, unknown>>;
          const map: Record<string, CoolboxSuhuState> = {};

          for (const [coolboxKey, boxData] of Object.entries(raw)) {
            if (!boxData || typeof boxData !== 'object' || coolboxKey === 'sync_meta') continue;

            const latest = (boxData.latest as Record<string, unknown>) || {};
            const history = (boxData.history as Record<string, Record<string, unknown>>) || {};

            const latestAirTemp = typeof latest.air_temperature_c === 'number' ? latest.air_temperature_c : null;
            const averageTemp = typeof latest.average_temperature_c === 'number' ? latest.average_temperature_c : null;
            const waterTemp = typeof latest.water_temperature_c === 'number' ? latest.water_temperature_c : null;
            const humidityPct = typeof latest.humidity_pct === 'number' ? latest.humidity_pct : null;

            let lastTimestampStr = '';
            if (latest.timestamp) {
              const { timeStr } = formatTimestamp(latest.timestamp);
              lastTimestampStr = timeStr;
            }

            // Parse history points
            const pointsWithTs: Array<{ time: string; temp: number; ts: number }> = [];

            if (history && typeof history === 'object') {
              for (const entry of Object.values(history)) {
                if (!entry || typeof entry !== 'object') continue;
                const tempVal =
                  typeof entry.air_temperature_c === 'number'
                    ? entry.air_temperature_c
                    : typeof entry.average_temperature_c === 'number'
                      ? entry.average_temperature_c
                      : null;

                if (tempVal !== null) {
                  let epoch = 0;
                  let timeLabel = '--:--';
                  if (typeof entry.timestamp === 'number') {
                    epoch = entry.timestamp;
                    const d = new Date(epoch);
                    timeLabel = `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
                  } else if (typeof entry.timestamp === 'string') {
                    const parsed = Date.parse(entry.timestamp);
                    if (!isNaN(parsed)) {
                      epoch = parsed;
                      const d = new Date(parsed);
                      timeLabel = `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
                    } else {
                      timeLabel = entry.timestamp;
                    }
                  }

                  pointsWithTs.push({
                    time: timeLabel,
                    temp: Number(tempVal.toFixed(1)),
                    ts: epoch,
                  });
                }
              }
            }

            // Sort chronologically (earliest to latest)
            pointsWithTs.sort((a, b) => a.ts - b.ts);

            const dataPoints: TemperatureDataPoint[] = pointsWithTs.map((p) => ({
              time: p.time,
              temp: p.temp,
            }));

            // Official SMART-FROST Calculation from IoT Sensor History
            const frostScore = FrostScoreCalculator.calculate(
              pointsWithTs.map((p) => ({ temp: p.temp }))
            );

            map[coolboxKey] = {
              coolboxId: coolboxKey,
              latestAirTemp,
              averageTemp,
              waterTemp,
              humidityPct,
              lastTimestampStr,
              dataPoints,
              frostScore,
            };
          }

          onData(map);
        },
        (error) => {
          console.error('Realtime Database /suhu listener error:', error);
          onError?.(error);
        }
      );
    } catch (err) {
      console.error('Failed to attach /suhu listener:', err);
      onError?.(err);
      return () => {};
    }
  }
}

