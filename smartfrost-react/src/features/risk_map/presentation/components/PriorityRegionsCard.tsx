import React from 'react';
import type { RegionRiskSummary } from '../../data/models/risk_map_types';

interface PriorityRegionsCardProps {
  regions: RegionRiskSummary[];
  selectedId: string;
  onSelect: (id: string) => void;
}

export const PriorityRegionsCard: React.FC<PriorityRegionsCardProps> = ({
  regions,
  selectedId,
  onSelect,
}) => {
  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs">
      <div className="border-b border-slate-100 pb-3">
        <h3 className="text-base font-bold text-slate-900">Wilayah prioritas</h3>
      </div>

      <div className="mt-3 divide-y divide-slate-100 max-h-[320px] overflow-y-auto pr-1">
        {regions.map((region) => {
          const isSelected = region.id === selectedId;

          return (
            <div
              key={region.id}
              onClick={() => onSelect(region.id)}
              className={`py-3 px-3 -mx-1.5 rounded-xl transition-all cursor-pointer ${
                isSelected
                  ? 'bg-sky-50/80 border border-sky-300 shadow-2xs ring-1 ring-sky-400/30'
                  : 'hover:bg-slate-50'
              }`}
            >
              <div className="flex items-center justify-between">
                <span className={`text-sm font-extrabold ${isSelected ? 'text-sky-950' : 'text-slate-900'}`}>
                  {region.name}
                </span>
                <span className="text-xs font-semibold text-slate-500">
                  {region.batchCount} batch
                </span>
              </div>

              <div className="mt-1 text-xs font-semibold flex items-center gap-1.5">
                <span className={region.highRiskCount > 0 ? 'text-rose-600' : 'text-slate-400'}>
                  {region.highRiskCount} tinggi
                </span>
                <span className="text-slate-300">&bull;</span>
                <span className={region.mediumRiskCount > 0 ? 'text-amber-600' : 'text-slate-400'}>
                  {region.mediumRiskCount} perhatian
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

