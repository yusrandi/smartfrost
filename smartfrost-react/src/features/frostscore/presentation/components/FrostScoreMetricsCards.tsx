import React from 'react';
import { ShieldCheck, CheckCircle2, AlertTriangle, ShieldAlert } from 'lucide-react';

interface FrostScoreMetricsCardsProps {
  veryGoodCount: number;
  goodCount: number;
  warningCount: number;
  highRiskCount: number;
  totalCount: number;
}

export const FrostScoreMetricsCards: React.FC<FrostScoreMetricsCardsProps> = ({
  veryGoodCount,
  goodCount,
  warningCount,
  highRiskCount,
  totalCount,
}) => {
  const safeTotal = Math.max(totalCount, 1);
  const veryGoodPct = ((veryGoodCount / safeTotal) * 100).toFixed(1).replace('.', ',');
  const goodPct = ((goodCount / safeTotal) * 100).toFixed(1).replace('.', ',');
  const warningPct = ((warningCount / safeTotal) * 100).toFixed(1).replace('.', ',');
  const highRiskPct = ((highRiskCount / safeTotal) * 100).toFixed(1).replace('.', ',');

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {/* 1. Sangat Baik (90–100) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Sangat baik &bull; &ge;90</span>
          <div className="h-7 w-7 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center">
            <ShieldCheck className="h-4 w-4" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {veryGoodCount} <span className="text-lg font-bold text-slate-500">batch</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {veryGoodPct}% dari {totalCount} batch
          </div>
        </div>
      </div>

      {/* 2. Baik (75–89) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Baik &bull; 75–89</span>
          <div className="h-7 w-7 rounded-full bg-lime-50 text-lime-600 flex items-center justify-center">
            <CheckCircle2 className="h-4 w-4" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {goodCount} <span className="text-lg font-bold text-slate-500">batch</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {goodPct}% dari {totalCount} batch
          </div>
        </div>
      </div>

      {/* 3. Waspada (60–74) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Waspada &bull; 60–74</span>
          <div className="h-7 w-7 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center">
            <AlertTriangle className="h-4 w-4" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {warningCount} <span className="text-lg font-bold text-slate-500">batch</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {warningPct}% dari {totalCount} batch
          </div>
        </div>
      </div>

      {/* 4. Risiko Tinggi (<60) */}
      <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs hover:border-slate-300 transition-all">
        <div className="flex items-center justify-between text-xs font-semibold text-slate-500">
          <span>Risiko tinggi &bull; &lt;60</span>
          <div className="h-7 w-7 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center">
            <ShieldAlert className="h-4 w-4" />
          </div>
        </div>

        <div className="mt-3">
          <div className="text-3xl font-black text-slate-900 tracking-tight">
            {highRiskCount} <span className="text-lg font-bold text-slate-500">batch</span>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-medium">
            {highRiskPct}% dari {totalCount} batch
          </div>
        </div>
      </div>
    </div>
  );
};
