import { haversineKm } from '../../../../core/constants/locations';
import type { MonitoringBatch } from '../../data/models/monitoring_types';

/** Assumed average vessel speed used for live ETA estimates. */
export const AVG_SPEED_KMH = 15;

export type EtaState = 'arrived' | 'rejected' | 'no-gps' | 'moving';

export interface EtaResult {
  state: EtaState;
  distanceKm: number | null;
  totalKm: number | null;
  progress: number; // 0..1
  label: string;
  detail: string;
}

export function formatDuration(hours: number): string {
  const totalMin = Math.max(1, Math.round(hours * 60));
  if (totalMin < 60) return `±${totalMin} menit`;
  const h = Math.floor(totalMin / 60);
  const m = totalMin % 60;
  return m === 0 ? `±${h} jam` : `±${h} jam ${m} menit`;
}

export function computeEta(b: MonitoringBatch): EtaResult {
  const status = b.summary.operationalStatus;
  const total = b.originPoint && b.destinationPoint ? haversineKm(b.originPoint, b.destinationPoint) : null;

  if (status === 'Diterima') {
    return { state: 'arrived', distanceKm: 0, totalKm: total, progress: 1, label: 'Telah tiba', detail: 'Batch sudah diterima distributor tujuan.' };
  }
  if (status === 'Ditolak') {
    return { state: 'rejected', distanceKm: null, totalKm: total, progress: 1, label: 'Ditolak', detail: 'Penerimaan ditolak oleh distributor tujuan.' };
  }
  if (!b.currentPoint || !b.destinationPoint) {
    return { state: 'no-gps', distanceKm: null, totalKm: total, progress: 0, label: 'Menunggu GPS', detail: 'Koordinat GPS nyata belum diterima.' };
  }

  const remaining = haversineKm(b.currentPoint, b.destinationPoint);
  const progress = total && total > 0 ? Math.min(1, Math.max(0, 1 - remaining / total)) : 0;
  if (remaining < 0.2) {
    return { state: 'arrived', distanceKm: remaining, totalKm: total, progress: 1, label: 'Hampir tiba', detail: 'Posisi sudah di sekitar tujuan.' };
  }
  return {
    state: 'moving',
    distanceKm: remaining,
    totalKm: total,
    progress,
    label: formatDuration(remaining / AVG_SPEED_KMH),
    detail: `${remaining.toFixed(1).replace('.', ',')} km lagi • kecepatan rata-rata ${AVG_SPEED_KMH} km/jam`,
  };
}

