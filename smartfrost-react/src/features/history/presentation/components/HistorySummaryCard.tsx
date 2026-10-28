import React from 'react';
import { Activity, Boxes, Scale, ShieldAlert, Snowflake, CheckCircle2, XCircle, Thermometer } from 'lucide-react';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import { findCoolboxSuhu, type CoolboxSuhuState } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator, type FrostScoreCategory } from '../../../dashboard/domain/services/frost_score_calculator';

interface HistorySummaryCardProps {
  items: DispatchSummaryItem[];
  suhuMap?: Record<string, CoolboxSuhuState>;
  realAverageTemp?: number | null;
}

const STATUS_ROWS: Array<{ key: DispatchSummaryItem['operationalStatus']; bar: string }> = [
  { key: 'Menunggu', bar: 'bg-slate-400' },
  { key: 'Perjalanan', bar: 'bg-sky-500' },
  { key: 'Diperiksa', bar: 'bg-amber-500' },
  { key: 'Diterima', bar: 'bg-emerald-500' },
  { key: 'Ditolak', bar: 'bg-rose-500' },
];

const OFFICIAL_RISK_ROWS: Array<{ key: FrostScoreCategory; label: string; bar: string; text: string }> = [
  { key: 'Sangat Baik', label: 'Sangat Baik (≥90)', bar: 'bg-emerald-500', text: 'text-emerald-700' },
  { key: 'Baik', label: 'Baik (75–89)', bar: 'bg-lime-500', text: 'text-lime-700' },
  { key: 'Waspada', label: 'Waspada (60–74)', bar: 'bg-amber-500', text: 'text-amber-700' },
  { key: 'Risiko Tinggi', label: 'Risiko Tinggi (<60)', bar: 'bg-rose-500', text: 'text-rose-700' },
];

const formatTon = (kg: number) => `${(kg / 1000).toFixed(2).replace('.', ',')} ton`;

/** Summary of the currently filtered distribution history with official cold-chain metrics. */
export const HistorySummaryCard: React.FC<HistorySummaryCardProps> = ({ items, suhuMap, realAverageTemp }) => {
  const total = items.length;
  const totalKg = items.reduce((a, i) => a + i.weightKg, 0);

  // Hitung score per item dengan prioritas telemetri sensor
  const itemScores = items.map((i) => {
    if (suhuMap) {
      const boxSuhu = findCoolboxSuhu(suhuMap, i.coolboxId);
      if (boxSuhu?.frostScore?.score != null) return boxSuhu.frostScore.score;
    }
    return i.frostScore;
  });

  const avgScore = total
    ? Math.round(itemScores.reduce((a, s) => a + s, 0) / total)
    : 0;

  const accepted = items.filter((i) => i.operationalStatus === 'Diterima').length;
  const rejected = items.filter((i) => i.operationalStatus === 'Ditolak').length;
  const decided = accepted + rejected;
  const acceptRate = decided ? Math.round((accepted / decided) * 100) : 0;
  const delayed = items.filter((i) => i.syncStatus === 'Tertunda').length;
  const origins = new Set(items.map((i) => i.origin).filter((o) => o && o !== '-'));

  // Batch berisiko tinggi (< 60)
  const highRiskCount = itemScores.filter((s) => s < 60).length;

  const pct = (n: number) => (total ? Math.round((n / total) * 100) : 0);

  const stats = [
    { icon: Boxes, label: 'Total pengiriman', value: String(total), hint: `${origins.size} wilayah asal` },
    { icon: Scale, label: 'Total muatan', value: formatTon(totalKg), hint: `${totalKg.toLocaleString('id-ID')} kg` },
    {
      icon: realAverageTemp != null ? Thermometer : Snowflake,
      label: 'Suhu & FrostScore',
      value: realAverageTemp != null ? `${realAverageTemp.toFixed(1)} °C` : `${avgScore} / 100`,
      hint: realAverageTemp != null ? `FrostScore rata-rata: ${avgScore}` : 'Skor ≥90: Sangat Baik',
    },
    { icon: CheckCircle2, label: 'Tingkat diterima', value: `${acceptRate}%`, hint: `${accepted} diterima • ${rejected} ditolak` },
    { icon: Activity, label: 'Sinkronisasi tertunda', value: String(delayed), hint: `${total - delayed} tersinkron` },
    { icon: ShieldAlert, label: 'Batch risiko tinggi', value: String(highRiskCount), hint: 'FrostScore < 60 (kritis)' },
  ];

  // Hitung distribusi kategori risiko resmi
  const categoryCounts: Record<FrostScoreCategory, number> = {
    'Sangat Baik': 0,
    'Baik': 0,
    'Waspada': 0,
    'Risiko Tinggi': 0,
  };

  itemScores.forEach((s) => {
    const cat = FrostScoreCalculator.getCategory(s);
    categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
  });

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs w-full">
      <div className="flex flex-wrap items-start justify-between gap-2">
        <div>
          <h3 className="text-sm font-bold text-slate-900">Ringkasan riwayat distribusi</h3>
          <p className="text-xs text-slate-500 mt-0.5">Berdasarkan {total} pengiriman sesuai filter aktif</p>
        </div>
        <div className="flex items-center gap-2">
          {highRiskCount > 0 && (
            <div className="inline-flex items-center gap-1 text-[11px] text-rose-700 bg-rose-50 border border-rose-200/80 rounded-full px-2.5 py-1 font-semibold">
              <ShieldAlert className="h-3 w-3 text-rose-600" />
              <span>{highRiskCount} risiko tinggi</span>
            </div>
          )}
          <div className="inline-flex items-center gap-1 text-[11px] text-slate-500 bg-slate-50 border border-slate-200/80 rounded-full px-2.5 py-1">
            <XCircle className="h-3 w-3 text-rose-500" />
            <span>{rejected} ditolak</span>
          </div>
        </div>
      </div>

      {/* Key stats */}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-3 mt-4">
        {stats.map(({ icon: Icon, label, value, hint }) => (
          <div key={label} className="rounded-xl bg-slate-50/80 border border-slate-100 p-3">
            <div className="flex items-center gap-1.5 text-[11px] text-slate-500 font-medium">
              <Icon className="h-3.5 w-3.5 text-sky-600" />
              <span>{label}</span>
            </div>
            <div className="text-xl font-black text-slate-900 mt-1">{value}</div>
            <div className="text-[10.5px] text-slate-400 mt-0.5">{hint}</div>
          </div>
        ))}
      </div>

      {/* Breakdown bars */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-5 pt-4 border-t border-slate-100">
        <div>
          <div className="text-xs font-bold text-slate-700 mb-2">Status operasional</div>
          <div className="space-y-2">
            {STATUS_ROWS.map(({ key, bar }) => {
              const n = items.filter((i) => i.operationalStatus === key).length;
              return (
                <div key={key} className="flex items-center gap-3 text-xs">
                  <span className="w-20 text-slate-600">{key}</span>
                  <div className="flex-1 h-2 rounded-full bg-slate-100 overflow-hidden">
                    <div className={`h-full rounded-full ${bar}`} style={{ width: `${pct(n)}%` }} />
                  </div>
                  <span className="w-16 text-right font-semibold text-slate-700">{n} • {pct(n)}%</span>
                </div>
              );
            })}
          </div>
        </div>

        <div>
          <div className="text-xs font-bold text-slate-700 mb-2">Tingkat integritas mutu (Standar SMART-FROST)</div>
          <div className="space-y-2">
            {OFFICIAL_RISK_ROWS.map(({ key, label, bar, text }) => {
              const n = categoryCounts[key] || 0;
              return (
                <div key={key} className="flex items-center gap-3 text-xs">
                  <span className={`w-36 font-medium truncate ${text}`}>{label}</span>
                  <div className="flex-1 h-2 rounded-full bg-slate-100 overflow-hidden">
                    <div className={`h-full rounded-full ${bar}`} style={{ width: `${pct(n)}%` }} />
                  </div>
                  <span className="w-16 text-right font-semibold text-slate-700">{n} • {pct(n)}%</span>
                </div>
              );
            })}
          </div>
          <p className="text-[11px] text-slate-400 mt-3">
            Ambang batas aman &ge;90 (Sangat Baik), &lt;60 dianggap anomali/risiko tinggi menurut spesifikasi cold-chain.
          </p>
        </div>
      </div>
    </div>
  );
};
