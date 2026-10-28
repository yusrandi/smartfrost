import { ref, onValue, type DataSnapshot } from 'firebase/database';
import { rtdb } from '../../../../firebase';
import type { DashboardMetrics, DispatchSummaryItem } from '../models/dashboard_types';
import { MOCK_DISPATCH_ITEMS, MOCK_METRICS } from '../mock/dashboard_mock_data';

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
      let frostScore = typeof d.frostScore === 'number' ? d.frostScore : 0;
      frostScore = Math.max(0, Math.min(100, frostScore));

      let riskLevel: DispatchSummaryItem['riskLevel'] = 'Rendah';
      if (frostScore >= 60) riskLevel = 'Tinggi';
      else if (frostScore >= 40) riskLevel = 'Perhatian';

      const { dateStr, timeStr } = formatTimestamp(d.createdAt ?? d.updatedAt);
      const lastTemp =
        typeof d.temperature === 'number' ? d.temperature : typeof d.lastTemp === 'number' ? d.lastTemp : 0;

      return {
        id: key,
        batchId,
        coolboxId,
        commodity: String(d.fishType || d.commodity || '-'),
        weightKg: parseWeightKg(d),
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
  const metrics: DashboardMetrics = {
    totalShipments: items.length,
    totalTonnageKg: totalKg,
    inTransitCount: inTransit.length,
    inTransitSynced: inTransit.filter((i) => i.syncStatus === 'Tersinkron').length,
    inTransitDelayed: inTransit.filter((i) => i.syncStatus === 'Tertunda').length,
    averageFrostScore: items.length > 0 ? Math.round(items.reduce((a, c) => a + c.frostScore, 0) / items.length) : 0,
    highRiskBatchesCount: items.filter((i) => i.riskLevel === 'Tinggi').length,
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
}

