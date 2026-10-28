import React from 'react';
import { TrendingUp } from 'lucide-react';
import type { FrostScoreDataPoint } from '../../data/models/dashboard_types';
import { useElementWidth } from '../../../../shared/hooks/useElementWidth';

export interface BatchFrostScorePoint {
  batchId: string;
  label: string;
  score: number;
  commodity?: string;
  coolboxId?: string;
  riskLevel?: 'Sangat Baik' | 'Baik' | 'Waspada' | 'Risiko Tinggi' | 'Rendah' | 'Perhatian' | 'Tinggi' | string;
}

interface FrostScoreTrendCardProps {
  dataPoints?: FrostScoreDataPoint[];
  batchPoints?: BatchFrostScorePoint[];
  selectedBatchId?: string;
  onSelectBatchId?: (batchId: string) => void;
  title?: string;
  subtitle?: string;
}

export const FrostScoreTrendCard: React.FC<FrostScoreTrendCardProps> = ({
  dataPoints = [],
  batchPoints = [],
  selectedBatchId,
  onSelectBatchId,
  title = 'Tren FrostScore',
  subtitle,
}) => {
  const [wrapRef, width] = useElementWidth<HTMLDivElement>();

  // Determine active dataset (Cara 2: batchPoints from RTDB, fallback to dataPoints)
  const isBatchMode = batchPoints.length > 0;
  const activePoints = isBatchMode
    ? batchPoints.map((b) => ({
        id: b.batchId,
        label: b.label,
        score: b.score,
        commodity: b.commodity,
        coolboxId: b.coolboxId,
        riskLevel: b.riskLevel,
      }))
    : dataPoints.map((d, i) => ({
        id: `d-${i}`,
        label: d.date,
        score: d.score,
        commodity: undefined,
        coolboxId: undefined,
        riskLevel: d.score >= 60 ? 'Tinggi' : d.score >= 40 ? 'Perhatian' : 'Rendah',
      }));

  const height = Math.max(220, Math.min(320, Math.round(width * 0.32)));
  const paddingLeft = 40;
  const paddingRight = 24;
  const paddingTop = 24;
  const paddingBottom = 34;

  const chartW = Math.max(width - paddingLeft - paddingRight, 10);
  const chartH = height - paddingTop - paddingBottom;

  const scores = activePoints.map((p) => p.score);
  const minScore = 0;
  const maxScore = Math.max(80, ...scores);
  const scoreRange = maxScore - minScore;

  const getY = (score: number) => {
    const clamped = Math.max(minScore, Math.min(maxScore, score));
    const normalized = (clamped - minScore) / scoreRange;
    return paddingTop + chartH - normalized * chartH;
  };

  const lastIdx = Math.max(activePoints.length - 1, 1);
  const getX = (idx: number) => paddingLeft + (idx / lastIdx) * chartW;

  const pointsStr = activePoints.map((pt, i) => `${getX(i)},${getY(pt.score)}`).join(' ');
  const areaStr = activePoints.length
    ? `${getX(0)},${paddingTop + chartH} ${pointsStr} ${getX(activePoints.length - 1)},${paddingTop + chartH}`
    : '';

  // Stats calculation
  const avgScore = scores.length ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;
  const highRiskCount = activePoints.filter((p) => p.score >= 60).length;
  const defaultSubtitle = isBatchMode
    ? `Berdasarkan ${activePoints.length} batch pengiriman terbaru • Sumbu X: Batch, Sumbu Y: Skor risiko`
    : 'Rata-rata batch tersinkron • 7 hari terakhir';

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between w-full min-w-0">
      {/* Header */}
      <div>
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-bold tracking-wider text-sky-600 uppercase">
                {isBatchMode ? 'Tren Batch-ke-Batch' : 'Tren FrostScore'}
              </span>
              <span className="text-[10px] font-bold text-slate-600 bg-slate-100 px-2 py-0.5 rounded-full border border-slate-200">
                {activePoints.length} batch
              </span>
            </div>
            <h3 className="text-sm font-bold text-slate-900 mt-0.5">{title}</h3>
            <p className="text-xs text-slate-500 mt-0.5">{subtitle || defaultSubtitle}</p>
          </div>

          <div className="flex items-center gap-2">
            <div className="text-xs font-bold text-sky-700 bg-sky-50 px-2.5 py-1 rounded-lg border border-sky-200/60">
              Rata-rata: {avgScore} / 100
            </div>
          </div>
        </div>

        {/* Chart Area */}
        <div ref={wrapRef} className="relative mt-4 w-full">
          <div className="flex items-center justify-between text-[10px] text-slate-400 font-medium mb-1">
            <span>FrostScore Risiko (0 - 100)</span>
            <div className="flex items-center gap-2 text-[10px]">
              <span className="inline-flex items-center gap-1 text-emerald-600">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" /> &lt;40 Rendah
              </span>
              <span className="inline-flex items-center gap-1 text-amber-600">
                <span className="h-1.5 w-1.5 rounded-full bg-amber-500" /> 40-59 Perhatian
              </span>
              <span className="inline-flex items-center gap-1 text-rose-600">
                <span className="h-1.5 w-1.5 rounded-full bg-rose-500" /> &ge;60 Tinggi
              </span>
            </div>
          </div>

          <svg width={width} height={height} className="block w-full select-none">
            <defs>
              <linearGradient id="frostAreaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#0284C7" stopOpacity="0.18" />
                <stop offset="100%" stopColor="#0284C7" stopOpacity="0.0" />
              </linearGradient>
            </defs>

            {/* Threshold line 90 (Batas Aman / Sangat Baik) */}
            {maxScore >= 90 && (
              <g>
                <line
                  x1={paddingLeft}
                  y1={getY(90)}
                  x2={width - paddingRight}
                  y2={getY(90)}
                  stroke="#10B981"
                  strokeWidth="1.2"
                  strokeDasharray="4 4"
                />
                <text
                  x={width - paddingRight - 4}
                  y={getY(90) - 4}
                  textAnchor="end"
                  className="text-[9px] fill-emerald-600 font-bold"
                >
                  Batas Aman (&ge;90)
                </text>
              </g>
            )}

            {/* Threshold line 60 (Ambang Kritis / Batas Waspada) */}
            {maxScore >= 60 && (
              <g>
                <line
                  x1={paddingLeft}
                  y1={getY(60)}
                  x2={width - paddingRight}
                  y2={getY(60)}
                  stroke="#F43F5E"
                  strokeWidth="1.2"
                  strokeDasharray="3 3"
                />
                <text
                  x={width - paddingRight - 4}
                  y={getY(60) - 4}
                  textAnchor="end"
                  className="text-[9px] fill-rose-500 font-semibold"
                >
                  Ambang Kritis (&lt;60 Risiko Tinggi)
                </text>
              </g>
            )}

            {/* Horizontal Grid lines and Y labels */}
            {[100, 80, 60, 40, 20, 0].filter((val) => val <= maxScore).map((val) => {
              const y = getY(val);
              return (
                <g key={`y-${val}`}>
                  <line
                    x1={paddingLeft}
                    y1={y}
                    x2={width - paddingRight}
                    y2={y}
                    stroke="#E2E8F0"
                    strokeWidth="1"
                    strokeDasharray={val === 0 ? '0' : '3 3'}
                  />
                  <text
                    x={paddingLeft - 8}
                    y={y + 3}
                    textAnchor="end"
                    className="text-[10px] fill-slate-400 font-mono"
                  >
                    {val}
                  </text>
                </g>
              );
            })}

            {/* Gradient fill under line */}
            {areaStr && <polygon points={areaStr} fill="url(#frostAreaGrad)" />}

            {/* Connecting Trend Line */}
            <polyline
              fill="none"
              stroke="#0284C7"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
              points={pointsStr}
            />

            {/* Data Dots with Risk Colors & Selection Indicator */}
            {activePoints.map((pt, i) => {
              const isSelected = selectedBatchId ? pt.id === selectedBatchId : false;
              // Official SMART-FROST color mapping:
              // >= 90: Sangat Baik (Emerald)
              // >= 75: Baik (Lime)
              // >= 60: Waspada (Amber)
              // < 60: Risiko Tinggi (Rose)
              const dotFill =
                pt.score >= 90
                  ? '#059669'
                  : pt.score >= 75
                  ? '#65A30D'
                  : pt.score >= 60
                  ? '#D97706'
                  : '#E11D48';

              const cx = getX(i);
              const cy = getY(pt.score);

              return (
                <g
                  key={`${pt.id}-${i}`}
                  onClick={() => onSelectBatchId?.(pt.id)}
                  className="cursor-pointer group"
                >
                  {/* Outer glow for selected batch */}
                  {isSelected && (
                    <circle
                      cx={cx}
                      cy={cy}
                      r="9"
                      fill={dotFill}
                      fillOpacity="0.25"
                      className="animate-pulse"
                    />
                  )}

                  <circle
                    cx={cx}
                    cy={cy}
                    r={isSelected ? 5.5 : 4}
                    fill={dotFill}
                    stroke="#FFFFFF"
                    strokeWidth="2"
                    className="transition-transform group-hover:scale-125"
                  >
                    <title>{`${pt.id} • FrostScore: ${pt.score} (${pt.riskLevel})${pt.commodity ? ` • ${pt.commodity}` : ''}`}</title>
                  </circle>

                  {/* Value label on top if selected */}
                  {isSelected && (
                    <text
                      x={cx}
                      y={cy - 12}
                      textAnchor="middle"
                      className="text-[10px] font-bold fill-sky-700"
                    >
                      {pt.score}
                    </text>
                  )}
                </g>
              );
            })}

            {/* X Labels (Short batch code or date) */}
            {activePoints.map((pt, i) => (
              <text
                key={`x-${pt.id}-${i}`}
                x={getX(i)}
                y={height - 8}
                textAnchor={i === 0 ? 'start' : i === activePoints.length - 1 ? 'end' : 'middle'}
                className="text-[10px] fill-slate-500 font-mono font-medium"
              >
                {pt.label}
              </text>
            ))}
          </svg>
        </div>

        <div className="text-[11px] text-slate-400 mt-1.5 flex items-center gap-1.5">
          <TrendingUp className="h-3 w-3 text-slate-400" />
          <span>
            {isBatchMode
              ? 'Klik titik batch untuk menginspeksi telemetri dan detailnya.'
              : 'Sumber: batch tersinkron • data demonstrasi'}
          </span>
        </div>
      </div>

      {/* Summary Footer */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 pt-3 mt-3 border-t border-slate-100 text-center">
        <div className="rounded-lg bg-slate-50 p-2">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase">Rata-Rata</span>
          <span className="text-xs font-extrabold text-slate-700">{avgScore} / 100</span>
        </div>
        <div className="rounded-lg bg-slate-50 p-2">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase">Terendah</span>
          <span className="text-xs font-extrabold text-emerald-700">{scores.length ? Math.min(...scores) : 0}</span>
        </div>
        <div className="rounded-lg bg-slate-50 p-2">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase">Tertinggi</span>
          <span className="text-xs font-extrabold text-rose-700">{scores.length ? Math.max(...scores) : 0}</span>
        </div>
        <div className="rounded-lg bg-rose-50/60 border border-rose-100 p-2">
          <span className="text-[10px] text-rose-600 font-semibold block uppercase">Risiko Tinggi</span>
          <span className="text-xs font-extrabold text-rose-800">{highRiskCount} batch</span>
        </div>
      </div>
    </div>
  );
};
