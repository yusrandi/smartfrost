import React from 'react';
import { useElementWidth } from '../../../../shared/hooks/useElementWidth';
import type { FrostScoreDataPoint } from '../../../dashboard/data/models/dashboard_types';

interface RiskTrendCardProps {
  dataPoints: FrostScoreDataPoint[];
  currentAverage?: number;
  deltaLabel?: string;
}

export const RiskTrendCard: React.FC<RiskTrendCardProps> = ({
  dataPoints,
  currentAverage = 24,
  deltaLabel = 'Turun 6 poin',
}) => {
  const [wrapRef, width] = useElementWidth<HTMLDivElement>();

  const height = Math.max(190, Math.min(260, Math.round(width * 0.32)));
  const paddingLeft = 36;
  const paddingRight = 20;
  const paddingTop = 16;
  const paddingBottom = 28;

  const chartW = Math.max(width - paddingLeft - paddingRight, 10);
  const chartH = height - paddingTop - paddingBottom;

  const minScore = 0;
  const maxScore = 70;
  const scoreRange = maxScore - minScore;

  const getY = (score: number) => {
    const clamped = Math.max(minScore, Math.min(maxScore, score));
    const normalized = (clamped - minScore) / scoreRange;
    return paddingTop + chartH - normalized * chartH;
  };

  const lastIdx = Math.max(dataPoints.length - 1, 1);
  const getX = (idx: number) => paddingLeft + (idx / lastIdx) * chartW;

  const pointsStr = dataPoints.map((pt, i) => `${getX(i)},${getY(pt.score)}`).join(' ');
  const areaStr = dataPoints.length
    ? `${getX(0)},${paddingTop + chartH} ${pointsStr} ${getX(dataPoints.length - 1)},${paddingTop + chartH}`
    : '';

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between w-full min-w-0 h-full">
      {/* Header */}
      <div>
        <div className="flex flex-wrap items-start justify-between gap-2">
          <div>
            <h3 className="text-base font-bold text-slate-900">Tren risiko distribusi</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Rata-rata FrostScore harian &bull; 16–22 Oktober
            </p>
          </div>
          <span className="text-xs font-semibold text-sky-600 bg-sky-50 px-2.5 py-0.5 rounded-full border border-sky-100">
            7 hari terakhir
          </span>
        </div>

        {/* Chart Canvas */}
        <div ref={wrapRef} className="relative mt-3 w-full">
          <div className="text-[10px] text-slate-400 font-medium mb-1">FrostScore rata-rata</div>
          <svg width={width} height={height} className="block w-full select-none">
            <defs>
              <linearGradient id="riskAreaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#0284C7" stopOpacity="0.16" />
                <stop offset="100%" stopColor="#0284C7" stopOpacity="0" />
              </linearGradient>
            </defs>

            {/* Grid Lines & Y Labels */}
            {[60, 40, 20, 0].map((val) => {
              const y = getY(val);
              return (
                <g key={val}>
                  <line
                    x1={paddingLeft}
                    y1={y}
                    x2={width - paddingRight}
                    y2={y}
                    stroke="#F1F5F9"
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

            {/* Area Fill */}
            {areaStr && <polygon points={areaStr} fill="url(#riskAreaGrad)" />}

            {/* Trend Line */}
            <polyline
              fill="none"
              stroke="#0284C7"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
              points={pointsStr}
            />

            {/* Dots */}
            {dataPoints.map((pt, i) => (
              <circle
                key={`${pt.date}-${i}`}
                cx={getX(i)}
                cy={getY(pt.score)}
                r="3.5"
                className="fill-sky-600 stroke-white stroke-2"
              >
                <title>{`${pt.date} • Skor ${pt.score}`}</title>
              </circle>
            ))}

            {/* Filtered X Labels (16 Okt, 18 Okt, 20 Okt, 22 Okt) */}
            {dataPoints
              .filter((_, i) => i % 2 === 0 || i === dataPoints.length - 1)
              .map((pt) => {
                const origIdx = dataPoints.findIndex((d) => d.date === pt.date);
                return (
                  <text
                    key={`x-${pt.date}`}
                    x={getX(origIdx)}
                    y={height - 6}
                    textAnchor="middle"
                    className="text-[10px] fill-slate-400 font-mono"
                  >
                    {pt.date}
                  </text>
                );
              })}
          </svg>
        </div>

        <div className="text-[11px] text-slate-400 mt-1">
          Sumber: batch tersinkron &bull; data demonstrasi
        </div>
      </div>

      {/* Highlight & Footer */}
      <div className="mt-4 pt-3 border-t border-slate-100 flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <div className="text-xs text-slate-700">
            Rata-rata saat ini:{' '}
            <strong className="text-base font-black text-slate-900">{currentAverage}</strong>{' '}
            <span className="text-xs text-slate-400 font-normal">/100</span>
          </div>

          <div className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-0.5 text-[11px] font-bold text-emerald-700 border border-emerald-200/60">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
            <span>{deltaLabel}</span>
          </div>
        </div>

        <p className="text-[11px] text-slate-400 leading-snug">
          FrostScore adalah indikator risiko, bukan hasil laboratorium atau sertifikat keamanan pangan.
        </p>
      </div>
    </div>
  );
};

