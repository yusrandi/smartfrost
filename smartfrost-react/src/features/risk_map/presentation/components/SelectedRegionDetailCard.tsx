import React from 'react';
import type { RegionRiskSummary } from '../../data/models/risk_map_types';

interface SelectedRegionDetailCardProps {
  region: RegionRiskSummary;
}

export const SelectedRegionDetailCard: React.FC<SelectedRegionDetailCardProps> = ({ region }) => {
  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between">
      <div>
        <h3 className="text-base font-bold text-slate-900">
          Wilayah terpilih &bull; {region.name}
        </h3>

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
            <span className="text-slate-500 font-medium">Anomali suhu</span>
            <span className="font-extrabold text-slate-900">
              {region.anomaliesCount} kejadian tercatat
            </span>
          </div>

          {/* Row 3: Batch Ditinjau */}
          <div className="flex items-center justify-between">
            <span className="text-slate-500 font-medium">Batch ditinjau</span>
            <span className="font-extrabold text-slate-900">
              <span className="text-sky-600">{region.topBatchId}</span> &bull; skor {region.topScore}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-5 pt-3 border-t border-slate-100 text-[11px] text-slate-400 leading-snug">
        FrostScore adalah indikator risiko, bukan hasil laboratorium atau sertifikat keamanan pangan.
      </div>
    </div>
  );
};

