import React from 'react';
import { Gauge, AlertTriangle, ShieldAlert } from 'lucide-react';

interface FrostScoreMetricsCardsProps {
  lowCount: number;
  midCount: number;
  highCount: number;
  totalCount: number;
}

export const FrostScoreMetricsCards: React.FC<FrostScoreMetricsCardsProps> = ({
  lowCount,
  midCount,
  highCount,
  totalCount,
}) => {
  const safeTotal = Math.max(totalCount, 1);
  const lowPct = ((lowCount / safeTotal) * 100).toFixed(1).replace('.', ',');
  const midPct = ((midCount / safeTotal) * 100).toFixed(1).replace('.', ',');
  const highPct = ((highCount / safeTotal) * 100).toFixed(1).replace('.', ',');

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {/* 1. Risiko Rendah (0-29) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Risiko rendah &bull; 0–29</span>
          <div className="h-7 w-7 rounded-full bg-slate-50 text-slate-500 flex items-center justify-center">
            <Gauge className="h-4 w-4 text-slate-500" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {lowCount} batch
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {lowPct}% dari {totalCount} batch
          </div>
        </div>
      </div>

      {/* 2. Perlu Perhatian (30-59) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Perlu perhatian &bull; 30–59</span>
          <div className="h-7 w-7 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center">
            <AlertTriangle className="h-4 w-4 text-amber-500" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {midCount} batch
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {midPct}% dari {totalCount} batch
          </div>
        </div>
      </div>

      {/* 3. Risiko Tinggi (60-100) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Risiko tinggi &bull; 60–100</span>
          <div className="h-7 w-7 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center">
            <ShieldAlert className="h-4 w-4 text-rose-500" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {highCount} batch
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {highPct}% dari {totalCount} batch
          </div>
        </div>
      </div>
    </div>
  );
};

