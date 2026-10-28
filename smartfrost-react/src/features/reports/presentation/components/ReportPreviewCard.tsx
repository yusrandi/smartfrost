import React, { useMemo } from 'react';
import { Package, Thermometer, ShieldAlert, AlertTriangle, CheckCircle2 } from 'lucide-react';
import {
  findCoolboxSuhu,
  type CoolboxSuhuState,
} from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';

interface ReportPreviewCardProps {
  items: DispatchSummaryItem[];
  isLive: boolean;
  suhuMap?: Record<string, CoolboxSuhuState>;
}

export const ReportPreviewCard: React.FC<ReportPreviewCardProps> = ({ items, isLive, suhuMap }) => {
  // Pure live data computation with fallback to design baseline only if no items
  const resolvedItems = useMemo(() => {
    return items.map((b) => {
      const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, b.coolboxId) : null;
      const effectiveTemp = boxSuhu?.latestAirTemp != null ? boxSuhu.latestAirTemp : b.lastTemp;
      const effectiveScore = boxSuhu?.frostScore?.score != null ? boxSuhu.frostScore.score : b.frostScore;
      const effectiveCategory = boxSuhu?.frostScore?.status ?? b.riskLevel;

      // Official thresholds: Safe temp <= 4.0°C; High risk: score < 60
      const isAnomaly = effectiveTemp > 4.0;
      const isHighRisk = effectiveScore < 60 || effectiveCategory === 'Risiko Tinggi' || effectiveCategory === 'Tinggi';
      const isWarning = (effectiveScore >= 60 && effectiveScore < 75) || effectiveCategory === 'Waspada' || effectiveCategory === 'Perhatian';
      const isGood = effectiveScore >= 75 || effectiveCategory === 'Sangat Baik' || effectiveCategory === 'Baik' || effectiveCategory === 'Rendah';

      return {
        ...b,
        effectiveTemp,
        effectiveScore,
        effectiveCategory,
        isAnomaly,
        isHighRisk,
        isWarning,
        isGood,
      };
    });
  }, [items, suhuMap]);

  const totalShipments = resolvedItems.length;
  const totalWeightKg = resolvedItems.reduce((acc, c) => acc + (c.weightKg || 0), 0);
  const totalTonnage = totalWeightKg >= 1000
    ? (totalWeightKg / 1000).toFixed(2).replace('.', ',')
    : (totalWeightKg / 1000).toFixed(3).replace('.', ',');

  const anomalyCount = resolvedItems.filter((b) => b.isAnomaly).length;
  const anomalyBatchesCount = anomalyCount;

  const highRiskCount = resolvedItems.filter((b) => b.isHighRisk).length;
  const midRiskCount = resolvedItems.filter((b) => b.isWarning).length;
  const lowRiskCount = resolvedItems.filter((b) => b.isGood).length;

  const inTransitCount = resolvedItems.filter(
    (b) => b.operationalStatus === 'Perjalanan' || b.operationalStatus === 'Menunggu'
  ).length;
  const delayedCount = resolvedItems.filter((b) => b.syncStatus === 'Tertunda').length;
  const syncedCount = Math.max(0, totalShipments - delayedCount);

  // Strictly attribute regions to sender origin
  const distinctOrigins = new Set(
    resolvedItems.map((b) => b.origin).filter((o) => o && o !== '-')
  ).size || 1;

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-6 sm:p-7 shadow-2xs">
      {/* Header section */}
      <div className="flex flex-wrap items-start justify-between gap-3 border-b border-slate-100 pb-5">
        <div>
          <div className="text-[10.5px] font-extrabold uppercase tracking-widest text-sky-600">
            SMART-FROST / LAPORAN PEMANTAUAN
          </div>
          <h2 className="text-xl sm:text-2xl font-black text-slate-900 mt-1 tracking-tight">
            Distribusi komoditas perikanan rantai dingin
          </h2>
          <p className="text-xs text-slate-500 mt-0.5 font-medium">
            Kabupaten Pangkajene dan Kepulauan &bull; Pemantauan IoT Realtime
          </p>
        </div>

        <span className="inline-flex items-center gap-1.5 text-xs font-bold text-sky-700 bg-sky-50 px-3 py-1 rounded-full border border-sky-200/80">
          <span className="h-1.5 w-1.5 rounded-full bg-sky-600" />
          {isLive ? 'Data Realtime Terverifikasi' : 'Pratinjau Laporan'}
        </span>
      </div>

      {/* 3 Metric Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-5">
        {/* Card 1: Pengiriman */}
        <div className="rounded-xl bg-slate-50/70 border border-slate-200/70 p-4">
          <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
            <span>Pengiriman</span>
            <Package className="h-4 w-4 text-slate-500" />
          </div>
          <div className="mt-2">
            <div className="text-3xl font-black text-slate-900 tracking-tight">
              {totalShipments}
            </div>
            <div className="text-xs text-slate-400 mt-0.5 font-medium">
              {totalTonnage} ton ({totalWeightKg} kg)
            </div>
          </div>
        </div>

        {/* Card 2: Anomali Suhu */}
        <div className="rounded-xl bg-slate-50/70 border border-slate-200/70 p-4">
          <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
            <span>Anomali suhu</span>
            <Thermometer className="h-4 w-4 text-sky-600" />
          </div>
          <div className="mt-2">
            <div className="text-3xl font-black text-slate-900 tracking-tight">
              {anomalyCount}
            </div>
            <div className="text-xs text-slate-400 mt-0.5 font-medium">
              Suhu sensor &gt;4,0°C ({anomalyBatchesCount} batch)
            </div>
          </div>
        </div>

        {/* Card 3: Risiko Tinggi */}
        <div className="rounded-xl bg-slate-50/70 border border-slate-200/70 p-4">
          <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
            <span>Risiko tinggi</span>
            <ShieldAlert className="h-4 w-4 text-rose-500" />
          </div>
          <div className="mt-2">
            <div className="text-3xl font-black text-slate-900 tracking-tight">
              {highRiskCount}
            </div>
            <div className="text-xs text-slate-400 mt-0.5 font-medium">
              FrostScore &lt;60 (Kritis)
            </div>
          </div>
        </div>
      </div>

      {/* Ringkasan Temuan */}
      <div className="mt-6 pt-5 border-t border-slate-100">
        <h3 className="text-sm font-bold text-slate-900">Ringkasan temuan</h3>
        <p className="text-xs text-slate-600 mt-1 leading-relaxed">
          Sebanyak <strong className="text-slate-800">{totalShipments} pengiriman</strong> tercatat dari <strong className="text-slate-800">{distinctOrigins} wilayah asal pengirim</strong>. Terdeteksi <strong className="text-slate-800">{anomalyCount} batch</strong> mengalami anomali suhu di atas ambang batas aman 4°C, serta <strong className="text-slate-800">{highRiskCount} batch</strong> berada dalam kategori risiko tinggi (FrostScore &lt;60) yang memerlukan tindakan mitigasi rantai dingin.
        </p>

        {/* Detail rows */}
        <div className="mt-4 space-y-2.5 text-xs">
          <div className="flex items-center justify-between pb-2 border-b border-slate-100">
            <span className="text-slate-500">Kondisi aman / waspada</span>
            <span className="font-extrabold text-slate-900">
              {lowRiskCount} batch aman (≥75) &bull; {midRiskCount} batch waspada (60–74)
            </span>
          </div>

          <div className="flex items-center justify-between pb-2 border-b border-slate-100">
            <span className="text-slate-500">Perjalanan aktif</span>
            <span className="font-extrabold text-slate-900">
              {inTransitCount} batch &bull; {delayedCount} data tertunda
            </span>
          </div>

          <div className="flex items-center justify-between pb-2 border-b border-slate-100">
            <span className="text-slate-500">Cakupan sensor</span>
            <span className="font-extrabold text-slate-900">
              {syncedCount} batch tersinkron real-time; {delayedCount} tertunda
            </span>
          </div>

          <div className="flex items-center justify-between pb-1">
            <span className="text-slate-500">Sumber & integritas data</span>
            <span className="font-extrabold text-slate-900">
              Sensor IoT Realtime Database SMART-FROST
            </span>
          </div>
        </div>
      </div>

      {/* Kelengkapan Data Banner */}
      {delayedCount > 0 ? (
        <div className="mt-5 rounded-xl bg-amber-50/90 border border-amber-200/80 p-3.5 text-xs text-amber-950 flex items-start gap-2.5">
          <AlertTriangle className="h-4 w-4 text-amber-700 shrink-0 mt-0.5" />
          <div className="leading-snug">
            <span className="font-extrabold text-amber-900">Keterbatasan kelengkapan data</span> &mdash;{' '}
            {delayedCount} batch memiliki pembacaan sensor yang tertunda akibat konektivitas kepulauan. Agregasi menghitung telemetry terakhir yang tercatat di sistem.
          </div>
        </div>
      ) : (
        <div className="mt-5 rounded-xl bg-emerald-50/90 border border-emerald-200/80 p-3.5 text-xs text-emerald-950 flex items-start gap-2.5">
          <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0 mt-0.5" />
          <div className="leading-snug">
            <span className="font-extrabold text-emerald-900">Kelengkapan data 100%</span> &mdash;{' '}
            Seluruh batch pengiriman saat ini tersinkronisasi penuh dengan sensor IoT telemetry suhu udara & GPS tanpa kendala komunikasi.
          </div>
        </div>
      )}

      {/* Footnotes */}
      <div className="mt-5 pt-4 border-t border-slate-100 space-y-1 text-[11px] text-slate-400 leading-snug">
        <p>FrostScore dihitung dengan formula resmi SMART-FROST berbasis penalti deviasi suhu (suhu aman ≤4,0°C), durasi anomali, variabilitas, dan keterlambatan.</p>
        <p>Kategori: &ge;90 Sangat Baik &bull; 75–89 Baik &bull; 60–74 Waspada &bull; &lt;60 Risiko Tinggi &bull; Kabupaten Pangkajene dan Kepulauan</p>
      </div>
    </div>
  );
};

