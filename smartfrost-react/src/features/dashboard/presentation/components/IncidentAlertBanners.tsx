import React from 'react';
import { AlertTriangle, CheckCircle2, ShieldCheck } from 'lucide-react';
import {
  findCoolboxSuhu,
  type CoolboxSuhuState,
} from '../../data/datasources/dashboard_rtdb_datasource';
import type { DispatchSummaryItem } from '../../data/models/dashboard_types';

interface IncidentAlertBannersProps {
  items?: DispatchSummaryItem[];
  suhuMap?: Record<string, CoolboxSuhuState>;
  onSelectBatch?: (batch: DispatchSummaryItem) => void;
}

export const IncidentAlertBanners: React.FC<IncidentAlertBannersProps> = ({
  items = [],
  suhuMap,
  onSelectBatch,
}) => {
  // 1. Identify delayed telemetry batches
  const delayedBatches = items.filter((b) => b.syncStatus === 'Tertunda');
  const topDelayed = delayedBatches.length > 0 ? delayedBatches[0] : null;

  // 2. Identify batches with temperature anomalies (>4°C) or critical risk (FrostScore <60)
  const evaluatedBatches = items.map((b) => {
    const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, b.coolboxId) : null;
    const currentTemp = boxSuhu?.latestAirTemp != null ? boxSuhu.latestAirTemp : b.lastTemp;
    const currentScore = boxSuhu?.frostScore?.score != null ? boxSuhu.frostScore.score : b.frostScore;
    const isTempAnomaly = currentTemp > 4.0;
    const isRiskCritical = currentScore < 60 || b.riskLevel === 'Risiko Tinggi' || b.riskLevel === 'Tinggi';

    return {
      batch: b,
      currentTemp,
      currentScore,
      isTempAnomaly,
      isRiskCritical,
      hasIssue: isTempAnomaly || isRiskCritical,
    };
  });

  // Sort critical batches by lowest FrostScore first (highest risk first)
  const criticalBatches = evaluatedBatches
    .filter((e) => e.hasIssue)
    .sort((a, b) => a.currentScore - b.currentScore);

  const topCritical = criticalBatches.length > 0 ? criticalBatches[0] : null;

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {/* Alert 1: Data Tertunda / Sinkronisasi Telemetri */}
      {delayedBatches.length > 0 ? (
        <div
          onClick={() => topDelayed && onSelectBatch?.(topDelayed)}
          className={`rounded-xl border border-amber-200 bg-amber-50/70 p-4 flex items-start gap-3 text-xs shadow-2xs transition-all ${
            onSelectBatch ? 'cursor-pointer hover:bg-amber-100/70 hover:border-amber-300' : ''
          }`}
        >
          <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0 mt-0.5" />
          <div className="space-y-1">
            <h4 className="font-bold text-amber-950">
              {delayedBatches.length} perjalanan memiliki data tertunda
            </h4>
            <p className="text-amber-900/80 leading-relaxed text-[11.5px]">
              Pembacaan terakhir tidak mewakili kondisi langsung. {topDelayed?.batchId} terakhir sinkron{' '}
              {topDelayed?.lastTempTime || 'beberapa waktu lalu'}; sinyal telemetri kepulauan tertunda.
            </p>
          </div>
        </div>
      ) : (
        <div className="rounded-xl border border-teal-200 bg-teal-50/70 p-4 flex items-start gap-3 text-xs shadow-2xs">
          <CheckCircle2 className="h-4 w-4 text-teal-600 shrink-0 mt-0.5" />
          <div className="space-y-1">
            <h4 className="font-bold text-teal-950">
              Seluruh telemetri tersinkronisasi
            </h4>
            <p className="text-teal-900/80 leading-relaxed text-[11.5px]">
              Semua sensor IoT coolbox aktif terhubung ke Realtime Database SMART-FROST ({items.length} batch). Suhu dan status diperbarui tanpa kendala jaringan.
            </p>
          </div>
        </div>
      )}

      {/* Alert 2: Anomali Suhu & Risiko Mutu Cold Chain */}
      {topCritical ? (
        <div
          onClick={() => onSelectBatch?.(topCritical.batch)}
          className={`rounded-xl border border-rose-200 bg-rose-50/70 p-4 flex items-start gap-3 text-xs shadow-2xs transition-all ${
            onSelectBatch ? 'cursor-pointer hover:bg-rose-100/70 hover:border-rose-300' : ''
          }`}
        >
          <AlertTriangle className="h-4 w-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="space-y-1">
            <h4 className="font-bold text-rose-950">
              {topCritical.batch.batchId} &bull; {topCritical.isTempAnomaly ? 'anomali suhu' : 'risiko mutu tinggi'}
            </h4>
            <p className="text-rose-900/80 leading-relaxed text-[11.5px]">
              {topCritical.isTempAnomaly ? (
                <>
                  Suhu terdeteksi <strong className="text-rose-950">{topCritical.currentTemp.toFixed(1)} °C</strong> (melebihi batas aman ≤4,0 °C). FrostScore {topCritical.currentScore}. Asal pengirim: {topCritical.batch.origin}.
                </>
              ) : (
                <>
                  FrostScore <strong className="text-rose-950">{topCritical.currentScore}</strong> (Risiko Tinggi). Komoditas {topCritical.batch.commodity} dari {topCritical.batch.origin}. Perlu peninjauan operasional.
                </>
              )}
            </p>
          </div>
        </div>
      ) : (
        <div className="rounded-xl border border-sky-200 bg-sky-50/70 p-4 flex items-start gap-3 text-xs shadow-2xs">
          <ShieldCheck className="h-4 w-4 text-sky-600 shrink-0 mt-0.5" />
          <div className="space-y-1">
            <h4 className="font-bold text-sky-950">
              Rantai dingin aman terkendali
            </h4>
            <p className="text-sky-900/80 leading-relaxed text-[11.5px]">
              Semua komoditas perikanan berada di bawah ambang batas aman (≤4,0 °C) dengan indikator FrostScore dalam kategori baik.
            </p>
          </div>
        </div>
      )}
    </div>
  );
};
