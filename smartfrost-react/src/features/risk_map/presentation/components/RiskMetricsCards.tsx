import React from 'react';
import { Map, MapPin, Radio } from 'lucide-react';

interface RiskMetricsCardsProps {
  coveredRegionsCount: number;
  priorityRegionsText: string;
  delayedBatchesCount: number;
  priorityRegionsCount?: number;
}

export const RiskMetricsCards: React.FC<RiskMetricsCardsProps> = ({
  coveredRegionsCount = 4,
  priorityRegionsText = 'Semua wilayah aman',
  delayedBatchesCount = 0,
  priorityRegionsCount = 0,
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {/* 1. Wilayah Tercakup */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Wilayah pangkalan distributor</span>
          <div className="h-7 w-7 rounded-full bg-sky-50 text-sky-600 flex items-center justify-center">
            <Map className="h-4 w-4 text-sky-600" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {coveredRegionsCount} <span className="text-lg font-bold text-slate-500">wilayah</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            Pangkalan kepulauan terhubung
          </div>
        </div>
      </div>

      {/* 2. Prioritas Peninjauan (Dihitung dinamis) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Prioritas peninjauan risiko</span>
          <div className={`h-7 w-7 rounded-full flex items-center justify-center ${
            priorityRegionsCount > 0 ? 'bg-rose-50 text-rose-600' : 'bg-emerald-50 text-emerald-600'
          }`}>
            <MapPin className="h-4 w-4" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {priorityRegionsCount} <span className="text-lg font-bold text-slate-500">wilayah</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium truncate">
            {priorityRegionsText}
          </div>
        </div>
      </div>

      {/* 3. Data Lokasi Tertunda */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Data telemetri tertunda</span>
          <div className="h-7 w-7 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center">
            <Radio className="h-4 w-4 text-amber-500" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {delayedBatchesCount} <span className="text-lg font-bold text-slate-500">batch</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {delayedBatchesCount > 0 ? 'Menunggu pembaruan transmisi' : 'Semua data tersinkron'}
          </div>
        </div>
      </div>
    </div>
  );
};
