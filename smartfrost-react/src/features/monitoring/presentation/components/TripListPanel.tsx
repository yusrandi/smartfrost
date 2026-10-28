import React from 'react';
import { ArrowRight, Thermometer, ShieldCheck, MapPin } from 'lucide-react';
import type { MonitoringBatch } from '../../data/models/monitoring_types';

interface TripListPanelProps {
  batches: MonitoringBatch[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}

const STATUS_CONFIG: Record<
  string,
  { label: string; bg: string; text: string; border: string; dot: string }
> = {
  Menunggu: {
    label: 'Menunggu',
    bg: 'bg-amber-50',
    text: 'text-amber-700',
    border: 'border-amber-200/80',
    dot: 'bg-amber-500',
  },
  Perjalanan: {
    label: 'Perjalanan',
    bg: 'bg-sky-50',
    text: 'text-sky-700',
    border: 'border-sky-200/80',
    dot: 'bg-sky-500',
  },
  Diperiksa: {
    label: 'Diperiksa',
    bg: 'bg-purple-50',
    text: 'text-purple-700',
    border: 'border-purple-200/80',
    dot: 'bg-purple-500',
  },
  Diterima: {
    label: 'Diterima',
    bg: 'bg-emerald-50',
    text: 'text-emerald-700',
    border: 'border-emerald-200/80',
    dot: 'bg-emerald-500',
  },
  Ditolak: {
    label: 'Ditolak',
    bg: 'bg-rose-50',
    text: 'text-rose-700',
    border: 'border-rose-200/80',
    dot: 'bg-rose-500',
  },
};

export const TripListPanel: React.FC<TripListPanelProps> = ({ batches, selectedId, onSelect }) => {
  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs h-full flex flex-col justify-between">
      <div>
        {/* Header */}
        <div className="flex items-start justify-between gap-2 border-b border-slate-100 pb-3">
          <div>
            <h3 className="text-base font-bold text-slate-900">Daftar perjalanan</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Klik perjalanan untuk menyorot rute & trackline di peta
            </p>
          </div>
          <span className="text-xs font-bold text-sky-700 bg-sky-50 px-2.5 py-0.5 rounded-full border border-sky-200/60">
            {batches.length} rute
          </span>
        </div>

        {/* List of Journeys */}
        <div className="mt-3 space-y-2.5 overflow-y-auto max-h-[490px] pr-1">
          {batches.length === 0 ? (
            <div className="text-center py-10 text-xs text-slate-400">
              Tidak ada data perjalanan yang sesuai filter.
            </div>
          ) : (
            batches.map((batch) => {
              const item = batch.summary;
              const isSelected = item.id === selectedId;
              const statusCfg = STATUS_CONFIG[item.operationalStatus] || {
                label: item.operationalStatus,
                bg: 'bg-slate-50',
                text: 'text-slate-700',
                border: 'border-slate-200',
                dot: 'bg-slate-400',
              };

              return (
                <div
                  key={item.id}
                  onClick={() => onSelect(item.id)}
                  className={`group relative rounded-xl p-3.5 transition-all cursor-pointer border ${
                    isSelected
                      ? 'border-sky-500 border-l-[6px] border-l-sky-600 bg-gradient-to-r from-sky-50/90 via-sky-50/40 to-white ring-2 ring-sky-500/25 shadow-md shadow-sky-100/60'
                      : 'border-slate-200/80 bg-white hover:border-slate-300 hover:bg-slate-50/70'
                  }`}
                >
                  {/* Top line: Batch ID & Status Badge */}
                  <div className="flex items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className={`text-xs font-black transition-colors ${isSelected ? 'text-sky-950' : 'text-slate-900 group-hover:text-sky-700'}`}>
                        {item.batchId}
                      </span>
                      {isSelected && (
                        <span className="inline-flex items-center gap-1.5 text-[10px] font-extrabold text-sky-800 bg-white px-2 py-0.5 rounded-full border border-sky-300 shadow-2xs">
                          <span className="relative flex h-2 w-2">
                            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"></span>
                            <span className="relative inline-flex rounded-full h-2 w-2 bg-sky-600"></span>
                          </span>
                          Disorot di peta
                        </span>
                      )}
                    </div>

                    <span
                      className={`inline-flex items-center gap-1.5 text-[10.5px] font-bold px-2 py-0.5 rounded-full border ${statusCfg.bg} ${statusCfg.text} ${statusCfg.border}`}
                    >
                      <span className={`h-1.5 w-1.5 rounded-full ${statusCfg.dot}`} />
                      {statusCfg.label}
                    </span>
                  </div>

                  {/* Route: Origin -> Destination */}
                  <div className="mt-2.5 flex items-center gap-2 text-xs font-bold text-slate-800">
                    <span className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md ${isSelected ? 'bg-emerald-50 text-emerald-900 border border-emerald-200/80' : 'text-slate-700'}`}>
                      <MapPin className="h-3 w-3 text-emerald-600 shrink-0" />
                      {item.origin}
                      {isSelected && <span className="text-[9px] font-extrabold text-emerald-600 uppercase ml-0.5">Asal</span>}
                    </span>
                    <ArrowRight className="h-3.5 w-3.5 text-slate-400 shrink-0" />
                    <span className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md ${isSelected ? 'bg-sky-50 text-sky-950 border border-sky-200/80' : 'text-slate-900'}`}>
                      <MapPin className="h-3 w-3 text-sky-600 shrink-0" />
                      {item.destination}
                      {isSelected && <span className="text-[9px] font-extrabold text-sky-600 uppercase ml-0.5">Tujuan</span>}
                    </span>
                  </div>

                  {/* Commodity & Meta */}
                  <div className="mt-2 text-[11px] text-slate-500 flex items-center justify-between">
                    <span>
                      {item.commodity} &bull; {item.weightKg} kg
                    </span>
                    <span className="text-slate-400 text-[10.5px]">
                      {item.dateStr.includes('•') ? item.dateStr.split('•')[1]?.trim() : item.dateStr}
                    </span>
                  </div>

                  {/* Metrics Pills: Last Temp & FrostScore */}
                  <div className="mt-2.5 pt-2 border-t border-slate-100 flex items-center justify-between text-[11px]">
                    <div className="inline-flex items-center gap-1 text-slate-600 font-medium">
                      <Thermometer className="h-3.5 w-3.5 text-sky-500" />
                      <span>{item.lastTemp.toFixed(1).replace('.', ',')} °C</span>
                    </div>

                    <div className="inline-flex items-center gap-1 text-slate-600 font-medium">
                      <ShieldCheck className="h-3.5 w-3.5 text-teal-600" />
                      <span>
                        FrostScore <strong className="text-slate-800">{item.frostScore}</strong>
                      </span>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Footer helper */}
      <div className="pt-3 border-t border-slate-100 text-[11px] text-slate-400 flex items-center justify-between">
        <span>Menampilkan rute logistik antarpulau</span>
        <span className="font-medium text-sky-600">Klik rute untuk zoom & sorot</span>
      </div>
    </div>
  );
};
