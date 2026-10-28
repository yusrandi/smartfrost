import React from 'react';
import { ShieldCheck, Activity, ThermometerSnowflake, Flame } from 'lucide-react';

export const HowToReadFrostScoreCard: React.FC = () => {
  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between h-full">
      <div>
        <div className="flex items-center justify-between">
          <h3 className="text-base font-bold text-slate-900">Spesifikasi FrostScore</h3>
          <span className="text-[10px] font-bold text-sky-700 bg-sky-50 px-2 py-0.5 rounded-full border border-sky-200/60">
            Standar Resmi
          </span>
        </div>

        <p className="text-xs text-slate-600 mt-2 leading-relaxed">
          Integritas rantai dingin dihitung dengan rumus:
          <span className="block mt-1 font-mono font-bold text-sky-950 bg-sky-50/80 p-2 rounded-lg border border-sky-100 text-[11px]">
            FrostScore = max(0, 100 - P_total)
          </span>
        </p>

        {/* 4 Komponen Penalti */}
        <div className="mt-3.5 space-y-2 text-[11px]">
          <div className="flex items-center justify-between text-slate-600">
            <span className="flex items-center gap-1.5 font-medium">
              <Flame className="h-3 w-3 text-rose-500" /> Dosis Termal (DH)
            </span>
            <span className="font-mono font-bold text-slate-800">Bobot 40%</span>
          </div>
          <div className="flex items-center justify-between text-slate-600">
            <span className="flex items-center gap-1.5 font-medium">
              <ThermometerSnowflake className="h-3 w-3 text-amber-500" /> Durasi Paparan (&gt;4°C)
            </span>
            <span className="font-mono font-bold text-slate-800">Bobot 25%</span>
          </div>
          <div className="flex items-center justify-between text-slate-600">
            <span className="flex items-center gap-1.5 font-medium">
              <Activity className="h-3 w-3 text-teal-500" /> Stabilitas Variansi (σ²)
            </span>
            <span className="font-mono font-bold text-slate-800">Bobot 15%</span>
          </div>
          <div className="flex items-center justify-between text-slate-600">
            <span className="flex items-center gap-1.5 font-medium">
              <ShieldCheck className="h-3 w-3 text-sky-500" /> Anomali AI / Sensor
            </span>
            <span className="font-mono font-bold text-slate-800">Bobot 20%</span>
          </div>
        </div>

        {/* Skala Kategori Resmi */}
        <div className="mt-4 pt-3 border-t border-slate-100 space-y-2">
          <div className="text-[11px] font-bold text-slate-700">Kategori Mutu & Tindakan:</div>

          {/* 90-100 Sangat Baik */}
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-emerald-500" />
              <span className="font-bold text-slate-800 font-mono">90–100</span>
            </div>
            <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/60">
              Sangat Baik / Aman
            </span>
          </div>

          {/* 75-89 Baik */}
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-lime-500" />
              <span className="font-bold text-slate-800 font-mono">75–89</span>
            </div>
            <span className="text-[11px] font-bold text-lime-700 bg-lime-50 px-2 py-0.5 rounded-full border border-lime-200/60">
              Baik (Normal)
            </span>
          </div>

          {/* 60-74 Waspada */}
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-amber-500" />
              <span className="font-bold text-slate-800 font-mono">60–74</span>
            </div>
            <span className="text-[11px] font-bold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200/60">
              Waspada
            </span>
          </div>

          {/* <60 Risiko Tinggi */}
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-rose-500" />
              <span className="font-bold text-slate-800 font-mono">&lt; 60</span>
            </div>
            <span className="text-[11px] font-bold text-rose-700 bg-rose-50 px-2 py-0.5 rounded-full border border-rose-200/60">
              Risiko Tinggi
            </span>
          </div>
        </div>
      </div>

      {/* Footer note */}
      <div className="mt-4 pt-3 border-t border-slate-100 text-[10.5px] text-slate-400 leading-snug">
        Batas suhu aman: 0–4 °C. Batch berisiko tinggi (&lt;60) diprioritaskan untuk pemeriksaan serah terima fisik.
      </div>
    </div>
  );
};
