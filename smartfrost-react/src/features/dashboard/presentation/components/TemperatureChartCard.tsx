import React from 'react';
import type { TemperatureDataPoint } from '../../data/models/dashboard_types';
import { useElementWidth } from '../../../../shared/hooks/useElementWidth';

interface TemperatureChartCardProps {
  dataPoints: TemperatureDataPoint[];
  title?: string;
  subtitle?: string;
  lastTempLabel?: string;
  syncLabel?: string;
  note?: string;
}

export const TemperatureChartCard: React.FC<TemperatureChartCardProps> = ({
  dataPoints,
  title = 'Suhu perjalanan terpilih',
  subtitle = 'SF-221026-018 • Balang Lompo → Pangkajene',
  lastTempLabel = 'Terakhir 1,8 °C',
  syncLabel = 'Tersinkron 10.42 WITA',
  note = 'Area arsiran: rentang operasional contoh 0–4 °C.',
}) => {
  const [wrapRef, width] = useElementWidth<HTMLDivElement>();

  // Chart dimensions: width follows the card, height scales with width
  const height = Math.max(220, Math.min(340, Math.round(width * 0.34)));
  const paddingLeft = 40;
  const paddingRight = 24;
  const paddingTop = 20;
  const paddingBottom = 34;

  const chartW = Math.max(width - paddingLeft - paddingRight, 10);
  const chartH = height - paddingTop - paddingBottom;

  // Temperature scale: -2 to 8 °C (total range 10)
  const minTemp = -2;
  const maxTemp = 8;
  const tempRange = maxTemp - minTemp;

  const getY = (temp: number) => {
    const clamped = Math.max(minTemp, Math.min(maxTemp, temp));
    const normalized = (clamped - minTemp) / tempRange;
    return paddingTop + chartH - normalized * chartH;
  };

  const lastIdx = Math.max(dataPoints.length - 1, 1);
  const getX = (idx: number) => paddingLeft + (idx / lastIdx) * chartW;

  // Safe zone between 0 °C and 4 °C
  const y0 = getY(0);
  const y4 = getY(4);
  const safeAreaHeight = Math.abs(y0 - y4);

  const pointsStr = dataPoints.map((pt, i) => `${getX(i)},${getY(pt.temp)}`).join(' ');
  const areaStr = dataPoints.length
    ? `${getX(0)},${paddingTop + chartH} ${pointsStr} ${getX(dataPoints.length - 1)},${paddingTop + chartH}`
    : '';

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between w-full min-w-0">
      {/* Header */}
      <div>
        <div className="flex flex-wrap items-start justify-between gap-2">
          <div>
            <h3 className="text-sm font-bold text-slate-900">{title}</h3>
            <p className="text-xs text-slate-500 mt-0.5">{subtitle}</p>
          </div>
          <div className="text-xs font-bold text-sky-600 bg-sky-50 px-2.5 py-1 rounded-lg">{lastTempLabel}</div>
        </div>

        {/* Chart Area (fills the card width) */}
        <div ref={wrapRef} className="relative mt-4 w-full">
          <div className="text-[10px] text-slate-400 font-medium mb-1">Suhu (&deg;C)</div>
          <svg width={width} height={height} className="block w-full select-none">
            <defs>
              <linearGradient id="tempAreaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#0284C7" stopOpacity="0.18" />
                <stop offset="100%" stopColor="#0284C7" stopOpacity="0" />
              </linearGradient>
            </defs>

            {/* Shaded Operational Safe Area (0 - 4 °C) */}
            <rect x={paddingLeft} y={y4} width={chartW} height={safeAreaHeight} fill="#D1FAE5" fillOpacity="0.45" />

            {/* Horizontal Grid lines and Y labels */}
            {[8, 4, 0, -2].map((val) => {
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
            {areaStr && <polygon points={areaStr} fill="url(#tempAreaGrad)" />}

            {/* Connecting Temperature Line */}
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
                key={`${pt.time}-${i}`}
                cx={getX(i)}
                cy={getY(pt.temp)}
                r="4"
                className="fill-sky-600 stroke-white stroke-2"
              >
                <title>{`${pt.time} • ${pt.temp} °C`}</title>
              </circle>
            ))}

            {/* X Labels (from data) */}
            {dataPoints.map((pt, i) => (
              <text
                key={`x-${pt.time}-${i}`}
                x={getX(i)}
                y={height - 8}
                textAnchor={i === 0 ? 'start' : i === dataPoints.length - 1 ? 'end' : 'middle'}
                className="text-[10px] fill-slate-400 font-mono"
              >
                {pt.time}
              </text>
            ))}
          </svg>
        </div>

        <div className="text-[11px] text-slate-400 mt-1">{note}</div>
      </div>

      {/* Footer Pill & Sync Time */}
      <div className="flex flex-wrap items-center justify-between gap-2 border-t border-slate-100 pt-3 mt-4 text-xs">
        <div className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1 text-emerald-700 font-medium border border-emerald-200/60">
          <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
          <span>1,8 &deg;C &bull; 10.30 WITA</span>
        </div>
        <div className="text-slate-400 text-[11px]">{syncLabel}</div>
      </div>
    </div>
  );
};
