import React from 'react';
import { Map, MapPin, Radio } from 'lucide-react';

interface RiskMetricsCardsProps {
  coveredRegionsCount: number;
  priorityRegionsText: string;
  delayedBatchesCount: number;
}

export const RiskMetricsCards: React.FC<RiskMetricsCardsProps> = ({
  coveredRegionsCount = 4,
  priorityRegionsText = 'Sarappo dan Salemo',
  delayedBatchesCount = 3,
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {/* 1. Wilayah Tercakup */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Wilayah tercakup</span>
          <div className="h-7 w-7 rounded-full bg-slate-50 text-slate-500 flex items-center justify-center">
            <Map className="h-4 w-4 text-sky-600" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {coveredRegionsCount}
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            Wilayah asal pengiriman
          </div>
        </div>
      </div>

      {/* 2. Prioritas Peninjauan */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Prioritas peninjauan</span>
          <div className="h-7 w-7 rounded-full bg-slate-50 text-slate-500 flex items-center justify-center">
            <MapPin className="h-4 w-4 text-teal-600" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            2 wilayah
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium truncate">
            {priorityRegionsText}
          </div>
        </div>
      </div>

      {/* 3. Data Lokasi Tertunda */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Data lokasi tertunda</span>
          <div className="h-7 w-7 rounded-full bg-slate-50 text-slate-500 flex items-center justify-center">
            <Radio className="h-4 w-4 text-amber-500" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {delayedBatchesCount} batch
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            Tidak ditampilkan sebagai lokasi terkini
          </div>
        </div>
      </div>
    </div>
  );
};

