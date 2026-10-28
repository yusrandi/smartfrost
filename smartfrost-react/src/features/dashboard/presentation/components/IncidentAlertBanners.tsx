import React from 'react';
import { AlertTriangle } from 'lucide-react';

export const IncidentAlertBanners: React.FC = () => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {/* Alert 1: Data Tertunda (Amber) */}
      <div className="rounded-xl border border-amber-200 bg-amber-50/70 p-4 flex items-start gap-3 text-xs shadow-2xs">
        <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0 mt-0.5" />
        <div className="space-y-1">
          <h4 className="font-bold text-amber-950">
            3 perjalanan memiliki data tertunda
          </h4>
          <p className="text-amber-900/80 leading-relaxed text-[11.5px]">
            Pembacaan terakhir tidak mewakili kondisi saat ini. SF-221026-019 terakhir sinkron 09.55 WITA; GPS terbaru belum tersedia.
          </p>
        </div>
      </div>

      {/* Alert 2: Anomali Suhu (Rose) */}
      <div className="rounded-xl border border-rose-200 bg-rose-50/70 p-4 flex items-start gap-3 text-xs shadow-2xs">
        <AlertTriangle className="h-4 w-4 text-rose-600 shrink-0 mt-0.5" />
        <div className="space-y-1">
          <h4 className="font-bold text-rose-950">
            SF-221026-017 &bull; anomali suhu
          </h4>
          <p className="text-rose-900/80 leading-relaxed text-[11.5px]">
            Puncak 8,1 &deg;C &bull; 32 menit di atas 4 &deg;C. FrostScore 76. Keputusan menunggu pemeriksaan penerima.
          </p>
        </div>
      </div>
    </div>
  );
};
