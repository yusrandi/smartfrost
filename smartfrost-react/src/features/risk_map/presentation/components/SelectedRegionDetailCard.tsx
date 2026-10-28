import React from 'react';
import type { RegionRiskSummary } from '../../data/models/risk_map_types';

interface SelectedRegionDetailCardProps {
  region: RegionRiskSummary;
}

export const SelectedRegionDetailCard: React.FC<SelectedRegionDetailCardProps> = ({ region }) => {
  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between">
      <div>
        <div className="flex items-center justify-between">
          <h3 className="text-base font-bold text-slate-900">
            Wilayah terpilih &bull; {region.name}
          </h3>
          <span
            className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
              region.highRiskCount > 0
                ? 'bg-rose-50 text-rose-700 border-rose-200'
                : region.mediumRiskCount > 0
                ? 'bg-amber-50 text-amber-700 border-amber-200'
                : 'bg-emerald-50 text-emerald-700 border-emerald-200'
            }`}
          >
            {region.dominantRisk === 'Tinggi'
              ? 'Risiko Tinggi'
              : region.dominantRisk === 'Perhatian'
              ? 'Perlu Perhatian'
              : 'Aman'}
          </span>
        </div>

        <div className="mt-4 space-y-3 text-xs">
          {/* Row 1: Total Muatan */}
          <div className="flex items-center justify-between pb-2.5 border-b border-slate-100">
            <span className="text-slate-500 font-medium">Total muatan</span>
            <span className="font-extrabold text-slate-900">
              {region.totalTonnageTon.toFixed(2).replace('.', ',')} ton &bull; {region.batchCount} batch
            </span>
          </div>

          {/* Row 2: Anomali Suhu */}
          <div className="flex items-center justify-between pb-2.5 border-b border-slate-100">
            <span className="text-slate-500 font-medium">Anomali suhu &gt;4°C</span>
            <span className="font-extrabold text-slate-900">
              {region.anomaliesCount} kejadian tercatat
            </span>
          </div>

          {/* Row 3: Batch Ditinjau */}
          <div className="flex items-center justify-between">
            <span className="text-slate-500 font-medium">Batch prioritas peninjauan</span>
            <span className="font-extrabold text-slate-900">
              <span className="text-sky-600 font-mono">{region.topBatchId}</span> &bull; skor {region.topScore}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-5 pt-3 border-t border-slate-100 text-[11px] text-slate-400 leading-snug">
        FrostScore dihitung dari telemetri sensor cold-chain IoT. Skor &ge;90 aman, &lt;60 menandakan risiko tinggi kerusakan termal.
      </div>
    </div>
  );
};
