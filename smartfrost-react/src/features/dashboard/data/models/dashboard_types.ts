export interface DispatchSummaryItem {
  id: string;
  batchId: string;
  coolboxId: string;
  commodity: string;
  weightKg: number;
  origin: string;
  destination: string;
  dateStr: string;
  lastTemp: number;
  lastTempTime: string;
  frostScore: number;
  riskLevel: 'Rendah' | 'Perhatian' | 'Tinggi';
  syncStatus: 'Tersinkron' | 'Tertunda';
  syncTime?: string;
  operationalStatus: 'Menunggu' | 'Perjalanan' | 'Diperiksa' | 'Diterima' | 'Ditolak';
}

export interface DashboardMetrics {
  totalShipments: number;
  totalTonnageKg: number;
  inTransitCount: number;
  inTransitSynced: number;
  inTransitDelayed: number;
  averageFrostScore: number;
  highRiskBatchesCount: number;
}

export interface TemperatureDataPoint {
  time: string;
  temp: number;
}

export interface FrostScoreDataPoint {
  date: string;
  score: number;
}
