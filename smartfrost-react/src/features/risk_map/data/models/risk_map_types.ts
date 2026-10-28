import type { GeoPoint } from '../../../../core/constants/locations';

export interface RegionRiskSummary {
  id: string;
  name: string;
  batchCount: number;
  totalTonnageTon: number;
  highRiskCount: number;
  mediumRiskCount: number;
  lowRiskCount: number;
  anomaliesCount: number;
  topBatchId: string;
  topScore: number;
  point: GeoPoint;
  dominantRisk: 'Tinggi' | 'Perhatian' | 'Rendah';
}

export const INITIAL_REGION_RISK_DATA: RegionRiskSummary[] = [
  {
    id: 'sarappo',
    name: 'Sarappo',
    batchCount: 36,
    totalTonnageTon: 2.52,
    highRiskCount: 2,
    mediumRiskCount: 4,
    lowRiskCount: 30,
    anomaliesCount: 6,
    topBatchId: 'SF-221026-017',
    topScore: 76,
    point: { lat: -4.887, lng: 119.262 },
    dominantRisk: 'Tinggi',
  },
  {
    id: 'salemo',
    name: 'Salemo',
    batchCount: 28,
    totalTonnageTon: 1.96,
    highRiskCount: 3,
    mediumRiskCount: 3,
    lowRiskCount: 22,
    anomaliesCount: 5,
    topBatchId: 'SF-221026-021',
    topScore: 72,
    point: { lat: -4.808, lng: 119.385 },
    dominantRisk: 'Tinggi',
  },
  {
    id: 'balang_lompo',
    name: 'Balang Lompo',
    batchCount: 40,
    totalTonnageTon: 2.8,
    highRiskCount: 0,
    mediumRiskCount: 3,
    lowRiskCount: 37,
    anomaliesCount: 3,
    topBatchId: 'SF-221026-019',
    topScore: 42,
    point: { lat: -4.935, lng: 119.362 },
    dominantRisk: 'Perhatian',
  },
  {
    id: 'sabutung',
    name: 'Sabutung',
    batchCount: 24,
    totalTonnageTon: 1.66,
    highRiskCount: 0,
    mediumRiskCount: 2,
    lowRiskCount: 22,
    anomaliesCount: 2,
    topBatchId: 'SF-221026-016',
    topScore: 36,
    point: { lat: -4.789, lng: 119.42 },
    dominantRisk: 'Perhatian',
  },
];

