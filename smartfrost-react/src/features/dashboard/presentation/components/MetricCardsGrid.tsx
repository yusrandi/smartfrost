import React from 'react';
import { Box, Ship, Gauge, AlertTriangle } from 'lucide-react';
import type { DashboardMetrics } from '../../data/models/dashboard_types';

interface MetricCardsGridProps {
  metrics: DashboardMetrics;
}

export const MetricCardsGrid: React.FC<MetricCardsGridProps> = ({ metrics }) => {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {/* Card 1: Total Pengiriman (Dark navy card) */}
      <div className="rounded-2xl bg-[#0F223A] border border-slate-800 p-5 shadow-sm text-white flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-semibold text-slate-300">
            Total pengiriman
          </span>
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-white/10 text-cyan-400">
            <Box className="h-4 w-4" />
          </div>
        </div>
        <div className="my-2.5">
          <div className="text-3xl font-black tracking-tight text-white">
            {metrics.totalShipments}
          </div>
        </div>
        <div className="text-[11.5px] text-slate-400">
          1–22 Oktober • {(metrics.totalTonnageKg / 1000).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ton
        </div>
      </div>

      {/* Card 2: Dalam perjalanan */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-semibold text-slate-500">
            Dalam perjalanan
          </span>
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-sky-50 text-sky-600">
            <Ship className="h-4 w-4" />
          </div>
        </div>
        <div className="my-2.5">
          <div className="text-3xl font-black tracking-tight text-slate-900">
            {metrics.inTransitCount}
          </div>
        </div>
        <div className="text-[11.5px] text-slate-500">
          {metrics.inTransitSynced} sinkron • {metrics.inTransitDelayed} data tertunda
        </div>
      </div>

      {/* Card 3: FrostScore rata-rata */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-semibold text-slate-500">
            FrostScore rata-rata
          </span>
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-sky-50 text-sky-600">
            <Gauge className="h-4 w-4" />
          </div>
        </div>
        <div className="my-2.5">
          <div className="text-3xl font-black tracking-tight text-slate-900">
            {metrics.averageFrostScore} <span className="text-xl font-bold text-slate-400">/ 100</span>
          </div>
        </div>
        <div className="text-[11.5px] text-slate-500">
          Indikator risiko • lebih rendah lebih baik
        </div>
      </div>

      {/* Card 4: Risiko tinggi */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-semibold text-slate-500">
            Risiko tinggi
          </span>
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-sky-50 text-sky-600">
            <AlertTriangle className="h-4 w-4" />
          </div>
        </div>
        <div className="my-2.5">
          <div className="text-3xl font-black tracking-tight text-slate-900">
            {metrics.highRiskBatchesCount} <span className="text-lg font-bold text-slate-500">batch</span>
          </div>
        </div>
        <div className="text-[11.5px] text-slate-500">
          Skor ≥60 • perlu ditinjau
        </div>
      </div>
    </div>
  );
};
