import { ref, onValue } from 'firebase/database';
import { rtdb } from '../../../../firebase';
import { buildDashboardData } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { resolveLocation, type GeoPoint } from '../../../../core/constants/locations';
import type { MonitoringBatch, TrackingLog } from '../models/monitoring_types';

const num = (v: unknown): number | null => (typeof v === 'number' && Number.isFinite(v) ? v : null);

function point(lat: unknown, lng: unknown): GeoPoint | null {
  const la = num(lat);
  const ln = num(lng);
  return la !== null && ln !== null ? { lat: la, lng: ln } : null;
}

function timeLabel(ts: number): string {
  if (!ts) return '-';
  const d = new Date(ts);
  return `${String(d.getHours()).padStart(2, '0')}.${String(d.getMinutes()).padStart(2, '0')}`;
}

function parseLogs(raw: unknown): TrackingLog[] {
  if (!raw || typeof raw !== 'object') return [];
  return Object.entries(raw as Record<string, Record<string, unknown>>)
    .filter(([, v]) => v && typeof v === 'object')
    .map(([id, v]) => {
      const ts = num(v.timestamp) ?? 0;
      return {
        id,
        ts,
        timeLabel: timeLabel(ts),
        point: point(v.latitude, v.longitude),
        temperature: num(v.temperature),
        label: String(v.status || v.locationName || ''),
      };
    })
    .sort((a, b) => a.ts - b.ts);
}

/**
 * Live monitoring feed from Realtime Database `dispatches`
 * (including `currentLatitude/currentLongitude` and `tracking_logs`).
 */
export class MonitoringRtdbDatasource {
  static subscribe(onData: (batches: MonitoringBatch[], isLive: boolean) => void, onError: (e: unknown) => void) {
    try {
      return onValue(
        ref(rtdb, 'dispatches'),
        (snapshot) => {
          const raw = snapshot.exists() ? (snapshot.val() as Record<string, Record<string, unknown>>) : {};
          const { items } = buildDashboardData(snapshot);
          const batches: MonitoringBatch[] = items.map((summary) => {
            const d = raw[summary.id] ?? {};
            const originPoint =
              point(d.originLatitude, d.originLongitude) ?? resolveLocation(String(d.originLocation ?? summary.origin));
            const destinationPoint =
              point(d.destinationLatitude, d.destinationLongitude) ??
              resolveLocation(String(d.destinationLocation ?? summary.destination));
            return {
              summary,
              senderName: String(d.senderName || d.distributorName || '-'),
              receiverName: String(d.receiverName || '-'),
              originPoint,
              destinationPoint,
              currentPoint: point(d.currentLatitude, d.currentLongitude),
              reportedDistance: typeof d.distanceRemaining === 'string' ? d.distanceRemaining : undefined,
              updatedAt: num(d.updatedAt) ?? 0,
              logs: parseLogs(d.tracking_logs),
            };
          });
          onData(batches, true);
        },
        (err) => {
          console.error('Monitoring listener failed:', err);
          onError(err);
          onData([], false);
        }
      );
    } catch (err) {
      onError(err);
      onData([], false);
      return () => {};
    }
  }
}

