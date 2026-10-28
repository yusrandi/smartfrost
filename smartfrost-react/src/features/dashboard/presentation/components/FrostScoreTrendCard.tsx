import React from 'react';
import type { FrostScoreDataPoint } from '../../data/models/dashboard_types';
import { useElementWidth } from '../../../../shared/hooks/useElementWidth';

interface FrostScoreTrendCardProps {
  dataPoints: FrostScoreDataPoint[];
}

export const FrostScoreTrendCard: React.FC<FrostScoreTrendCardProps> = ({ dataPoints }) => {
  const [wrapRef, width] = useElementWidth<HTMLDivElement>();

  const height = Math.max(220, Math.min(340, Math.round(width * 0.34)));
  const paddingLeft = 40;
  const paddingRight = 24;
  const paddingTop = 20;
  const paddingBottom = 34;

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
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between w-full min-w-0">
      {/* Header */}
      <div>
        <div className="flex flex-wrap items-start justify-between gap-2">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Tren FrostScore</h3>
            <p className="text-xs text-slate-500 mt-0.5">Rata-rata batch tersinkron • 16&ndash;22 Oktober</p>
          </div>
          <div className="text-xs font-semibold text-sky-600 hover:text-sky-700 cursor-pointer">7 hari terakhir</div>
        </div>

        {/* Chart Area (fills the card width) */}
        <div ref={wrapRef} className="relative mt-4 w-full">
          <div className="text-[10px] text-slate-400 font-medium mb-1">FrostScore rata-rata</div>
          <svg width={width} height={height} className="block w-full select-none">
            <defs>
              <linearGradient id="frostAreaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#0284C7" stopOpacity="0.18" />
                <stop offset="100%" stopColor="#0284C7" stopOpacity="0" />
              </linearGradient>
            </defs>

            {/* Grid lines and Y labels */}
            {[60, 40, 20, 0].map((val) => {
              const y = getY(val);
              return (
                <g key={val}>
                  <line
                    x1={paddingLeft}
                    y1={y}
                    x2={width - paddingRight}
                    y2={y}
                    stroke="#E2E8F0"
                    strokeWidth="1"
                    strokeDasharray={val === 0 ? '0' : '3 3'}
                  />
                  <text x={paddingLeft - 8} y={y + 3} textAnchor="end" className="text-[10px] fill-slate-400 font-mono">
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

            {/* Data Dots */}
            {dataPoints.map((pt, i) => (
              <circle
                key={`${pt.date}-${i}`}
                cx={getX(i)}
                cy={getY(pt.score)}
                r="4"
                className="fill-sky-600 stroke-white stroke-2"
              >
                <title>{`${pt.date} • ${pt.score}`}</title>
              </circle>
            ))}

            {/* X Labels (from data) */}
            {dataPoints.map((pt, i) => (
              <text
                key={`x-${pt.date}-${i}`}
                x={getX(i)}
                y={height - 8}
                textAnchor={i === 0 ? 'start' : i === dataPoints.length - 1 ? 'end' : 'middle'}
                className="text-[10px] fill-slate-400 font-mono"
              >
                {pt.date}
              </text>
            ))}
          </svg>
        </div>

        <div className="text-[11px] text-slate-400 mt-1">Sumber: batch tersinkron &bull; data demonstrasi</div>
      </div>

      {/* Disclaimer Footer */}
      <div className="border-t border-slate-100 pt-3 mt-4 text-[11px] text-slate-400 leading-snug">
        FrostScore adalah indikator risiko, bukan hasil laboratorium atau sertifikat keamanan pangan.
      </div>
    </div>
  );
};
