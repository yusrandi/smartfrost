import React from 'react';
import { Package, Thermometer, ShieldAlert, AlertTriangle } from 'lucide-react';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';

interface ReportPreviewCardProps {
  items: DispatchSummaryItem[];
  isLive: boolean;
}

export const ReportPreviewCard: React.FC<ReportPreviewCardProps> = ({ items, isLive }) => {
  // Compute real metrics from database items, or use the 128-batch design baseline
  const hasLiveDispatches = isLive && items.length >= 10;

  const totalShipments = hasLiveDispatches ? items.length : 128;
  const totalTonnage = hasLiveDispatches
    ? (items.reduce((acc, c) => acc + (c.weightKg || 0), 0) / 1000).toFixed(2).replace('.', ',')
    : '8,94';

  const anomalyCount = hasLiveDispatches
    ? items.filter((b) => b.lastTemp > 4 || b.frostScore >= 40).length
    : 11;
  const anomalyBatchesCount = hasLiveDispatches
    ? items.filter((b) => b.lastTemp > 4).length
    : 9;

  const highRiskCount = hasLiveDispatches
    ? items.filter((b) => b.frostScore >= 60 || b.riskLevel === 'Tinggi').length
    : 5;
  const midRiskCount = hasLiveDispatches
    ? items.filter((b) => (b.frostScore >= 30 && b.frostScore < 60) || b.riskLevel === 'Perhatian').length
    : 12;
  const lowRiskCount = totalShipments - highRiskCount - midRiskCount;

  const inTransitCount = hasLiveDispatches
    ? items.filter((b) => b.operationalStatus === 'Perjalanan' || b.operationalStatus === 'Menunggu').length
    : 9;
  const delayedCount = hasLiveDispatches
    ? items.filter((b) => b.syncStatus === 'Tertunda').length
    : 3;
  const syncedCount = totalShipments - delayedCount;

  const distinctOrigins = hasLiveDispatches
    ? new Set(items.map((b) => b.origin).filter((o) => o && o !== '-')).size
    : 4;

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-6 sm:p-7 shadow-2xs">
      {/* Header section */}
      <div className="flex flex-wrap items-start justify-between gap-3 border-b border-slate-100 pb-5">
        <div>
          <div className="text-[10.5px] font-extrabold uppercase tracking-widest text-sky-600">
            SMART-FROST / LAPORAN PEMANTAUAN
          </div>
          <h2 className="text-xl sm:text-2xl font-black text-slate-900 mt-1 tracking-tight">
            Distribusi ikan antarpulau
          </h2>
          <p className="text-xs text-slate-500 mt-0.5 font-medium">
            Kabupaten Pangkep &bull; 1–22 Oktober 2026
          </p>
        </div>

        <span className="inline-flex items-center gap-1.5 text-xs font-bold text-sky-700 bg-sky-50 px-3 py-1 rounded-full border border-sky-200/80">
          <span className="h-1.5 w-1.5 rounded-full bg-sky-600" />
          Pratinjau
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
              {totalTonnage} ton
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
              Pada {anomalyBatchesCount} batch
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
              FrostScore &ge;60
            </div>
          </div>
        </div>
      </div>

      {/* Ringkasan Temuan */}
      <div className="mt-6 pt-5 border-t border-slate-100">
        <h3 className="text-sm font-bold text-slate-900">Ringkasan temuan</h3>
        <p className="text-xs text-slate-600 mt-1 leading-relaxed">
          Sebanyak {totalShipments} pengiriman tercatat dari {distinctOrigins} wilayah asal. Terdapat {anomalyCount} kejadian anomali suhu pada {anomalyBatchesCount} batch, serta {highRiskCount} batch berisiko tinggi yang memerlukan peninjauan operasional.
        </p>

        {/* Detail rows */}
        <div className="mt-4 space-y-2.5 text-xs">
          <div className="flex items-center justify-between pb-2 border-b border-slate-100">
            <span className="text-slate-500">Rendah / perhatian</span>
            <span className="font-extrabold text-slate-900">
              {lowRiskCount} batch / {midRiskCount} batch
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
              {syncedCount} batch tersinkron; {delayedCount} belum lengkap
            </span>
          </div>

          <div className="flex items-center justify-between pb-1">
            <span className="text-slate-500">Sumber & waktu</span>
            <span className="font-extrabold text-slate-900">
              Data platform diterima hingga 22 Okt, 10.42 WITA
            </span>
          </div>
        </div>
      </div>

      {/* Keterbatasan Kelengkapan Data Banner */}
      <div className="mt-5 rounded-xl bg-amber-50/90 border border-amber-200/80 p-3.5 text-xs text-amber-950 flex items-start gap-2.5">
        <AlertTriangle className="h-4 w-4 text-amber-700 shrink-0 mt-0.5" />
        <div className="leading-snug">
          <span className="font-extrabold text-amber-900">Keterbatasan kelengkapan data</span> &mdash;{' '}
          {delayedCount} batch memiliki pembacaan tertunda. Nilai terbaru belum diketahui; agregasi menggunakan data terakhir yang diterima, bukan kondisi langsung.
        </div>
      </div>

      {/* Footnotes */}
      <div className="mt-5 pt-4 border-t border-slate-100 space-y-1 text-[11px] text-slate-400 leading-snug">
        <p>FrostScore adalah indikator risiko, bukan hasil laboratorium atau sertifikat keamanan pangan.</p>
        <p>Disusun oleh Rahmat Hidayat &bull; ID laporan RPT-221028-01 Data demonstrasi, bukan laporan resmi atau sertifikasi pangan.</p>
      </div>
    </div>
  );
};

