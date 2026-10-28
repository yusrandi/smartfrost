import React from 'react';

export const HowToReadFrostScoreCard: React.FC = () => {
  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between h-full">
      <div>
        <h3 className="text-base font-bold text-slate-900">Cara membaca FrostScore</h3>
        <p className="text-xs text-slate-600 mt-2 leading-relaxed">
          Contoh skor menggabungkan paparan suhu, durasi anomali, dan kelengkapan data. Ambang ini bersifat demonstratif, bukan ambang ilmiah.
        </p>

        {/* Legend Scale List */}
        <div className="mt-5 space-y-3.5">
          {/* 0-29 Rendah */}
          <div className="flex items-center gap-3">
            <span className="w-1.5 h-6 rounded-full bg-emerald-600 shrink-0" />
            <div className="w-16 font-extrabold text-sm text-slate-900">0–29</div>
            <div className="text-xs font-bold text-emerald-700">Rendah</div>
          </div>

          {/* 30-59 Perlu Perhatian */}
          <div className="flex items-center gap-3">
            <span className="w-1.5 h-6 rounded-full bg-amber-500 shrink-0" />
            <div className="w-16 font-extrabold text-sm text-slate-900">30–59</div>
            <div className="text-xs font-bold text-amber-700">Perlu perhatian</div>
          </div>

          {/* 60-100 Tinggi */}
          <div className="flex items-center gap-3">
            <span className="w-1.5 h-6 rounded-full bg-rose-600 shrink-0" />
            <div className="w-16 font-extrabold text-sm text-slate-900">60–100</div>
            <div className="text-xs font-bold text-rose-700">Tinggi</div>
          </div>
        </div>
      </div>

      {/* Footer explanation note */}
      <div className="mt-6 pt-3 border-t border-slate-100 text-[11px] text-slate-400 leading-snug">
        Skor data tertunda memakai pembacaan terakhir; risiko terkini belum dapat dipastikan.
      </div>
    </div>
  );
};

