import React from 'react';
import { Thermometer, Activity, Droplets } from 'lucide-react';
import type { TemperatureDataPoint } from '../../data/models/dashboard_types';
import { useElementWidth } from '../../../../shared/hooks/useElementWidth';

interface TemperatureChartCardProps {
  dataPoints: TemperatureDataPoint[];
  title?: string;
  subtitle?: string;
  lastTempLabel?: string;
  syncLabel?: string;
  note?: string;
  coolboxId?: string;
  averageTemp?: number | null;
  latestAirTemp?: number | null;
  humidityPct?: number | null;
  isLive?: boolean;
}

export const TemperatureChartCard: React.FC<TemperatureChartCardProps> = ({
  dataPoints,
  title = 'Suhu perjalanan terpilih',
  subtitle = 'SF-221026-018 • Balang Lompo → Pangkajene',
  lastTempLabel = 'Terakhir 1,8 °C',
  syncLabel = 'Tersinkron WITA',
  note = 'Sumbu Y: Suhu udara (air_temperature_c) • Sumbu X: Waktu sensor (timestamp)',
  coolboxId,
  averageTemp,
  latestAirTemp,
  humidityPct,
  isLive = false,
}) => {
  const [wrapRef, width] = useElementWidth<HTMLDivElement>();

  // Chart dimensions: width follows the card, height scales with width
  const height = Math.max(220, Math.min(320, Math.round(width * 0.32)));
  const paddingLeft = 44;
  const paddingRight = 24;
  const paddingTop = 20;
  const paddingBottom = 34;

  const chartW = Math.max(width - paddingLeft - paddingRight, 10);
  const chartH = height - paddingTop - paddingBottom;

  const hasData = dataPoints.length > 0;
  const temps = hasData ? dataPoints.map((pt) => pt.temp) : [0, 4];

  // Dynamic temperature scale based on actual IoT sensor data
  let minTemp = Math.min(...temps);
  let maxTemp = Math.max(...temps);

  if (minTemp === maxTemp) {
    minTemp = Math.max(0, minTemp - 2);
    maxTemp = maxTemp + 2;
  } else {
    const range = maxTemp - minTemp;
    minTemp = Math.floor(Math.max(0, minTemp - range * 0.15));
    maxTemp = Math.ceil(maxTemp + range * 0.15);
  }
  const tempRange = Math.max(maxTemp - minTemp, 1);

  const getY = (temp: number) => {
    const clamped = Math.max(minTemp, Math.min(maxTemp, temp));
    const normalized = (clamped - minTemp) / tempRange;
    return paddingTop + chartH - normalized * chartH;
  };

  const lastIdx = Math.max(dataPoints.length - 1, 1);
  const getX = (idx: number) => paddingLeft + (idx / lastIdx) * chartW;

  // Safe zone calculation (0 °C to 4 °C)
  const isSafeZoneVisible = maxTemp >= 0 && minTemp <= 4;
  const safeTop = Math.min(maxTemp, 4);
  const safeBottom = Math.max(minTemp, 0);
  const ySafeTop = getY(safeTop);
  const ySafeBottom = getY(safeBottom);
  const safeAreaHeight = Math.max(0, ySafeBottom - ySafeTop);

  const pointsStr = dataPoints.map((pt, i) => `${getX(i)},${getY(pt.temp)}`).join(' ');
  const areaStr = hasData
    ? `${getX(0)},${paddingTop + chartH} ${pointsStr} ${getX(dataPoints.length - 1)},${paddingTop + chartH}`
    : '';

  // 4 horizontal grid steps
  const gridSteps = 4;
  const stepVal = tempRange / (gridSteps - 1);
  const gridValues = Array.from({ length: gridSteps }, (_, i) =>
    Number((maxTemp - i * stepVal).toFixed(1))
  );

  // Statistics calculation
  const avgVal = averageTemp ?? (hasData ? temps.reduce((a, b) => a + b, 0) / temps.length : null);
  const minVal = hasData ? Math.min(...temps) : null;
  const maxVal = hasData ? Math.max(...temps) : null;
  const latestVal = latestAirTemp ?? (hasData ? temps[temps.length - 1] : null);

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs flex flex-col justify-between w-full min-w-0">
      {/* Header */}
      <div>
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-bold tracking-wider text-sky-600 uppercase">
                Sensor Suhu IoT
              </span>
              {coolboxId && (
                <span className="text-[10px] font-mono font-bold text-slate-600 bg-slate-100 px-2 py-0.5 rounded-full border border-slate-200">
                  {coolboxId}
                </span>
              )}
            </div>
            <h3 className="text-sm font-bold text-slate-900 mt-0.5">{title}</h3>
            <p className="text-xs text-slate-500 mt-0.5">{subtitle}</p>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            {isLive && (
              <div className="inline-flex items-center gap-1.5 text-xs font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-lg border border-emerald-200/60">
                <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                <span>Live Telemetri</span>
              </div>
            )}
            <div className="text-xs font-bold text-sky-700 bg-sky-50 px-2.5 py-1 rounded-lg border border-sky-200/60">
              {lastTempLabel}
            </div>
            {avgVal != null && (
              <div className="text-xs font-bold text-teal-700 bg-teal-50 px-2.5 py-1 rounded-lg border border-teal-200/60">
                Rata-rata: {avgVal.toFixed(1)} °C
              </div>
            )}
          </div>
        </div>

        {/* Chart Area */}
        <div ref={wrapRef} className="relative mt-4 w-full overflow-hidden">
          <div className="flex items-center justify-between text-[10px] text-slate-400 font-medium mb-1">
            <span>Suhu Udara Coldbox (&deg;C)</span>
            {humidityPct != null && (
              <span className="inline-flex items-center gap-1 text-slate-500">
                <Droplets className="h-3 w-3 text-sky-500" />
                <span>Kelembaban {humidityPct}%</span>
              </span>
            )}
          </div>

          {!hasData ? (
            <div
              style={{ height }}
              className="w-full flex flex-col items-center justify-center rounded-xl bg-slate-50/70 border border-dashed border-slate-200 text-center p-6"
            >
              <div className="h-10 w-10 rounded-full bg-sky-50 text-sky-500 flex items-center justify-center mb-2">
                <Thermometer className="h-5 w-5" />
              </div>
              <p className="text-xs font-bold text-slate-700">
                Menunggu data sensor untuk {coolboxId || 'coolbox'}
              </p>
              <p className="text-[11px] text-slate-400 mt-0.5 max-w-xs">
                Grafik akan otomatis memvisualisasikan data suhu udara (air_temperature_c) begitu sensor mengirim telemetri.
              </p>
            </div>
          ) : (
            <svg width={width} height={height} className="block w-full select-none">
              <defs>
                <linearGradient id="tempAreaGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#0284C7" stopOpacity="0.22" />
                  <stop offset="100%" stopColor="#0284C7" stopOpacity="0.0" />
                </linearGradient>
              </defs>

              {/* Shaded Operational Safe Area (0 - 4 °C) if visible */}
              {isSafeZoneVisible && (
                <rect
                  x={paddingLeft}
                  y={ySafeTop}
                  width={chartW}
                  height={safeAreaHeight}
                  fill="#D1FAE5"
                  fillOpacity="0.45"
                />
              )}

              {/* Dashed reference line for 4°C Safe Limit if in range */}
              {maxTemp >= 4 && minTemp <= 4 && (
                <g>
                  <line
                    x1={paddingLeft}
                    y1={getY(4)}
                    x2={width - paddingRight}
                    y2={getY(4)}
                    stroke="#FB923C"
                    strokeWidth="1.2"
                    strokeDasharray="4 4"
                  />
                  <text
                    x={width - paddingRight - 4}
                    y={getY(4) - 5}
                    textAnchor="end"
                    className="text-[9px] fill-orange-500 font-bold"
                  >
                    Batas aman 4°C
                  </text>
                </g>
              )}

              {/* Horizontal Grid lines and Y labels */}
              {gridValues.map((val, idx) => {
                const y = getY(val);
                return (
                  <g key={`grid-${idx}-${val}`}>
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
                      {val}°
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

              {/* Data Dots with tooltips */}
              {dataPoints.map((pt, i) => {
                const isAnomaly = pt.temp > 4;
                return (
                  <circle
                    key={`${pt.time}-${i}`}
                    cx={getX(i)}
                    cy={getY(pt.temp)}
                    r="4"
                    className={
                      isAnomaly
                        ? 'fill-rose-600 stroke-white stroke-2'
                        : 'fill-sky-600 stroke-white stroke-2'
                    }
                  >
                    <title>{`${pt.time} • ${pt.temp} °C (air_temperature_c)`}</title>
                  </circle>
                );
              })}

              {/* X Labels (time from IoT sensor) */}
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
          )}
        </div>

        <div className="text-[11px] text-slate-400 mt-1.5 flex items-center gap-1.5">
          <Activity className="h-3 w-3 text-slate-400" />
          <span>{note}</span>
        </div>
      </div>

      {/* Summary Telemetry Stats */}
      {hasData && (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 pt-3 mt-3 border-t border-slate-100">
          <div className="rounded-lg bg-slate-50 p-2 text-center">
            <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">
              Terendah
            </span>
            <span className="text-xs font-extrabold text-slate-700">
              {minVal?.toFixed(1)} &deg;C
            </span>
          </div>

          <div className="rounded-lg bg-teal-50/60 border border-teal-100 p-2 text-center">
            <span className="text-[10px] text-teal-600 font-semibold block uppercase tracking-wider">
              Rata-rata
            </span>
            <span className="text-xs font-extrabold text-teal-800">
              {avgVal?.toFixed(1)} &deg;C
            </span>
          </div>

          <div className="rounded-lg bg-slate-50 p-2 text-center">
            <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">
              Tertinggi
            </span>
            <span className="text-xs font-extrabold text-slate-700">
              {maxVal?.toFixed(1)} &deg;C
            </span>
          </div>

          <div className="rounded-lg bg-sky-50/60 border border-sky-100 p-2 text-center">
            <span className="text-[10px] text-sky-600 font-semibold block uppercase tracking-wider">
              Terkini
            </span>
            <span className="text-xs font-extrabold text-sky-800">
              {latestVal?.toFixed(1)} &deg;C
            </span>
          </div>
        </div>
      )}

      {/* Footer Pill & Sync Time */}
      <div className="flex flex-wrap items-center justify-between gap-2 border-t border-slate-100 pt-3 mt-3 text-xs">
        <div className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1 text-emerald-700 font-medium border border-emerald-200/60">
          <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
          <span>
            {latestVal != null ? `${latestVal.toFixed(1)} °C • Sensor Terhubung` : 'Data Sensor'}
          </span>
        </div>
        <div className="text-slate-400 text-[11px] font-mono">{syncLabel}</div>
      </div>
    </div>
  );
};
