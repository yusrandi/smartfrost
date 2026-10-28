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
  currentAverage = 87,
  deltaLabel = 'Stabil di zona aman',
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
  const maxScore = 100;
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
            <h3 className="text-base font-bold text-slate-900">Tren integritas mutu rantai dingin</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Rata-rata FrostScore harian &bull; 16–22 Oktober (Skala 0–100)
            </p>
          </div>
          <span className="text-xs font-semibold text-sky-700 bg-sky-50 px-2.5 py-0.5 rounded-full border border-sky-100">
            7 hari terakhir
          </span>
        </div>

        {/* Chart Canvas */}
        <div ref={wrapRef} className="relative mt-3 w-full">
          <div className="flex items-center justify-between text-[10px] text-slate-400 font-medium mb-1">
            <span>FrostScore rata-rata harian</span>
            <span className="text-emerald-600 font-semibold">&ge;90 Sangat Baik</span>
          </div>
          <svg width={width} height={height} className="block w-full select-none">
            <defs>
              <linearGradient id="riskAreaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#0284C7" stopOpacity="0.2" />
                <stop offset="100%" stopColor="#0284C7" stopOpacity="0" />
              </linearGradient>
            </defs>

            {/* Threshold Line 90 (Batas Aman / Sangat Baik) */}
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

            {/* Threshold Line 60 (Ambang Kritis / Risiko Tinggi) */}
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
                Ambang Kritis (&lt;60)
              </text>
            </g>

            {/* Grid Lines & Y Labels */}
            {[100, 80, 60, 40, 20, 0].map((val) => {
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

            {/* Connecting Line */}
            {pointsStr && (
              <polyline
                fill="none"
                stroke="#0284C7"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
                points={pointsStr}
              />
            )}

            {/* Data Dots with Official SMART-FROST Colors */}
            {dataPoints.map((pt, i) => {
              const cx = getX(i);
              const cy = getY(pt.score);
              const dotColor =
                pt.score >= 90
                  ? '#059669' // Emerald
                  : pt.score >= 75
                  ? '#65A30D' // Lime
                  : pt.score >= 60
                  ? '#D97706' // Amber
                  : '#E11D48'; // Rose

              return (
                <circle
                  key={pt.date}
                  cx={cx}
                  cy={cy}
                  r="4"
                  fill={dotColor}
                  stroke="#FFFFFF"
                  strokeWidth="2"
                  className="transition-transform hover:scale-125"
                >
                  <title>{`${pt.date}: ${pt.score}`}</title>
                </circle>
              );
            })}

            {/* X-Axis Date Labels */}
            {dataPoints.map((pt, i) => (
              <text
                key={pt.date}
                x={getX(i)}
                y={height - 6}
                textAnchor={i === 0 ? 'start' : i === dataPoints.length - 1 ? 'end' : 'middle'}
                className="text-[10px] fill-slate-500 font-medium"
              >
                {pt.date}
              </text>
            ))}
          </svg>
        </div>
      </div>

      {/* Footer Info */}
      <div className="flex items-center justify-between pt-3 mt-3 border-t border-slate-100 text-xs text-slate-500">
        <div>
          Rata-rata saat ini:{' '}
          <strong className="text-slate-900 font-mono text-sm">{currentAverage} / 100</strong>
        </div>
        <div className="font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/60 text-[11px]">
          {deltaLabel}
        </div>
      </div>
    </div>
  );
};
