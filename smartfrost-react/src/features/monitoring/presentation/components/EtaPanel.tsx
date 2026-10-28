import React from 'react';
import { Navigation, Clock } from 'lucide-react';
import type { MonitoringBatch } from '../../data/models/monitoring_types';
import { computeEta } from '../utils/eta';

interface EtaPanelProps {
  batches: MonitoringBatch[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}

interface ReferenceEtaItem {
  code: string;
  location: string;
  estimate: string;
  informant?: string;
  isEstimateFlagged?: boolean;
}

const REFERENCE_ETA_LIST: ReferenceEtaItem[] = [
  {
    code: '01',
    location: 'Pulau Sanane',
    estimate: '±2 jam menuju distributor',
    informant: 'Informasi: Asri dan Muhammad Isra',
  },
  {
    code: '02',
    location: 'Pulau Jangang-jangangan (Pangkep)',
    estimate: '3–5 jam',
    informant: 'Informasi: Darus, Putra, dan Andi',
  },
  {
    code: '03',
    location: 'Perairan Pangkep dan Sekitarnya',
    estimate: 'Bervariasi',
    informant: 'Dipengaruhi jarak penangkapan, cuaca, dan gelombang. Informasi: Rudi dan Rusli',
  },
  {
    code: '04',
    location: 'Daerah Sorong',
    estimate: 'Hingga 10 hari',
    informant: 'Lihat inset geografis. Informasi: Pak Mustari',
  },
  {
    code: '05',
    location: 'Pulau Sabutung',
    estimate: '30–45 menit',
  },
  {
    code: '06',
    location: 'Pulau Kapoposang',
    estimate: '1–2 jam',
  },
  {
    code: '07',
    location: 'Pulau Badi*',
    estimate: '1,5–2 jam',
    isEstimateFlagged: true,
  },
  {
    code: '08',
    location: 'Pulau Sarappo Lompo dan Sarappo Keke',
    estimate: '2–2,5 jam',
    informant: 'Dua lokasi terpisah, satu entri laporan.',
  },
  {
    code: '09',
    location: 'Pulau Bontosua*',
    estimate: '4–5 jam',
    isEstimateFlagged: true,
  },
];

export const EtaPanel: React.FC<EtaPanelProps> = ({ batches, selectedId, onSelect }) => {
  const selectedBatch = batches.find((b) => b.summary.id === selectedId);
  const liveEta = selectedBatch ? computeEta(selectedBatch) : null;

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs h-full flex flex-col justify-between">
      <div>
        <div className="flex items-start justify-between gap-2 border-b border-slate-100 pb-3">
          <div>
            <h3 className="text-base font-bold text-slate-900">Estimasi waktu tempuh</h3>
            <p className="text-xs text-slate-500 mt-0.5">Ringkasan berdasarkan lokasi / laporan</p>
          </div>
          <span className="text-xs font-bold text-sky-600 bg-sky-50 px-2 py-0.5 rounded-md">
            {REFERENCE_ETA_LIST.length} entri
          </span>
        </div>

        {/* Live GPS Telemetry Box if Selected Batch has ongoing journey */}
        {selectedBatch && liveEta && (
          <div className="mt-3 rounded-xl bg-sky-50/90 border border-sky-100 p-3.5">
            <div className="flex items-center justify-between text-[11px] font-semibold text-sky-700">
              <span className="flex items-center gap-1.5">
                <Navigation className="h-3.5 w-3.5 text-sky-600" />
                {selectedBatch.summary.batchId}
              </span>
              <span className="text-[10px] font-bold uppercase tracking-wider text-sky-600 bg-white px-2 py-0.5 rounded-full border border-sky-200/60">
                Live GPS
              </span>
            </div>
            <div className="text-lg font-black text-slate-900 mt-1">{liveEta.label}</div>
            <div className="text-[11px] text-slate-600 mt-0.5 leading-snug">{liveEta.detail}</div>

            {liveEta.state === 'moving' && (
              <div className="mt-2.5">
                <div className="h-2 rounded-full bg-white overflow-hidden">
                  <div
                    className="h-full rounded-full bg-sky-500 transition-all duration-300"
                    style={{ width: `${Math.round(liveEta.progress * 100)}%` }}
                  />
                </div>
                <div className="flex justify-between text-[10px] text-slate-400 mt-1 font-medium">
                  <span>{selectedBatch.summary.origin}</span>
                  <span>{Math.round(liveEta.progress * 100)}% menuju {selectedBatch.summary.destination}</span>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Complete Reference Location List matching the Design */}
        <div className="mt-3 space-y-2 overflow-y-auto max-h-[380px] pr-1 divide-y divide-slate-100">
          {REFERENCE_ETA_LIST.map((item) => {
            const isTarget = selectedBatch && (
              selectedBatch.summary.origin.toLowerCase().includes(item.location.toLowerCase().split(' ')[1] || item.location.toLowerCase()) ||
              selectedBatch.summary.destination.toLowerCase().includes(item.location.toLowerCase().split(' ')[1] || item.location.toLowerCase())
            );

            // Find matching batch if any
            const matchedBatch = batches.find((b) =>
              b.summary.origin.toLowerCase().includes(item.location.toLowerCase().split(' ')[1] || '') ||
              b.summary.destination.toLowerCase().includes(item.location.toLowerCase().split(' ')[1] || '')
            );

            return (
              <div
                key={item.code}
                onClick={() => {
                  if (matchedBatch) {
                    onSelect(matchedBatch.summary.id);
                  }
                }}
                className={`pt-2.5 pb-2 transition-colors rounded-lg px-2 ${
                  isTarget ? 'bg-teal-50/70 border border-teal-200/60' : 'hover:bg-slate-50'
                } ${matchedBatch ? 'cursor-pointer' : ''}`}
              >
                <div className="flex items-start gap-2.5">
                  <span className="mt-0.5 h-5 w-5 shrink-0 rounded-md bg-sky-100 text-sky-800 text-[10px] font-black flex items-center justify-center">
                    {item.code}
                  </span>
                  <div className="flex-1 min-w-0">
                    <div className="text-xs font-semibold text-slate-800">
                      {item.location}
                    </div>
                    <div className="text-sm font-bold text-sky-700 mt-0.5 flex items-center gap-1.5">
                      <Clock className="h-3.5 w-3.5 text-sky-600 inline" />
                      <span>{item.estimate}</span>
                    </div>
                    {item.informant && (
                      <div className="text-[10px] text-slate-400 mt-0.5 leading-snug">
                        {item.informant}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div className="text-[10.5px] text-slate-400 mt-3 pt-3 border-t border-slate-100 leading-snug">
        Informasi hanya dicantumkan bila tersedia dalam data operasional dan logistik maritim.
      </div>
    </div>
  );
};
