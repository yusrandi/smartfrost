import type { DispatchSummaryItem, TemperatureDataPoint } from '../../../dashboard/data/models/dashboard_types';
import type { GeoPoint } from '../../../../core/constants/locations';

export interface TrackingLog {
  id: string;
  ts: number;
  timeLabel: string;
  point: GeoPoint | null;
  temperature: number | null;
  label: string;
}

export interface MonitoringBatch {
  summary: DispatchSummaryItem;
  senderName: string;
  receiverName: string;
  originPoint: GeoPoint | null;
  destinationPoint: GeoPoint | null;
  /** Live GPS position (null when no real coordinate was received). */
  currentPoint: GeoPoint | null;
  /** Distance remaining as reported by the mobile app, if any. */
  reportedDistance?: string;
  updatedAt: number;
  logs: TrackingLog[];
}

export type TemperatureSeries = TemperatureDataPoint[];

