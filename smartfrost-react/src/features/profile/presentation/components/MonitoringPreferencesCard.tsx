import React, { useState } from 'react';
import { Info } from 'lucide-react';

export const MonitoringPreferencesCard: React.FC = () => {
  const [highRiskAlert, setHighRiskAlert] = useState(true);
  const [unsyncedAlert, setUnsyncedAlert] = useState(true);

  return (
    <div className="space-y-4">
      {/* Preferences Container */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-6 sm:p-7 shadow-2xs">
        <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-4">
          Preferensi pemantauan
        </h3>

        <div className="mt-5 space-y-4">
          {/* Item 1: Peringatan Risiko Tinggi */}
          <div className="flex items-center justify-between gap-4">
            <div>
              <h4 className="text-xs sm:text-sm font-bold text-slate-900">
                Peringatan risiko tinggi
              </h4>
              <p className="text-xs text-slate-500 mt-0.5">
                Pemberitahuan ketika FrostScore mencapai &ge;60.
              </p>
            </div>

            <button
              type="button"
              onClick={() => setHighRiskAlert(!highRiskAlert)}
              className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold border transition-colors cursor-pointer ${
                highRiskAlert
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                  : 'bg-slate-100 text-slate-500 border-slate-200'
              }`}
            >
              <span
                className={`h-1.5 w-1.5 rounded-full ${
                  highRiskAlert ? 'bg-emerald-600' : 'bg-slate-400'
                }`}
              />
              <span>{highRiskAlert ? 'Aktif' : 'Nonaktif'}</span>
            </button>
          </div>

          <div className="border-t border-slate-100" />

          {/* Item 2: Data Belum Tersinkron */}
          <div className="flex items-center justify-between gap-4">
            <div>
              <h4 className="text-xs sm:text-sm font-bold text-slate-900">
                Data belum tersinkron
              </h4>
              <p className="text-xs text-slate-500 mt-0.5">
                Tandai perjalanan dengan data tertunda.
              </p>
            </div>

            <button
              type="button"
              onClick={() => setUnsyncedAlert(!unsyncedAlert)}
              className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold border transition-colors cursor-pointer ${
                unsyncedAlert
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                  : 'bg-slate-100 text-slate-500 border-slate-200'
              }`}
            >
              <span
                className={`h-1.5 w-1.5 rounded-full ${
                  unsyncedAlert ? 'bg-emerald-600' : 'bg-slate-400'
                }`}
              />
              <span>{unsyncedAlert ? 'Aktif' : 'Nonaktif'}</span>
            </button>
          </div>

          <div className="border-t border-slate-100" />

          {/* Item 3: Zona Waktu */}
          <div className="flex items-center justify-between gap-4">
            <div>
              <h4 className="text-xs sm:text-sm font-bold text-slate-900">
                Zona waktu
              </h4>
            </div>
            <div className="text-xs sm:text-sm font-extrabold text-slate-900 tracking-tight">
              WITA &bull; UTC+8
            </div>
          </div>
        </div>
      </div>

      {/* Info Notice Box */}
      <div className="rounded-2xl bg-sky-50/70 border border-sky-100 p-4 sm:p-5 flex items-start gap-3">
        <Info className="h-4 w-4 text-[#0284C7] shrink-0 mt-0.5" />
        <div className="text-xs text-sky-950 leading-relaxed">
          <strong className="font-bold text-sky-950 block">
            Perubahan akses melalui administrator
          </strong>
          <span className="text-sky-800/90 mt-0.5 block">
            Profil petugas tidak memberikan kewenangan untuk mengubah data perjalanan atau keputusan pemeriksaan distributor.
          </span>
        </div>
      </div>
    </div>
  );
};

