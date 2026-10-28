import React, { useEffect } from 'react';
import { MapContainer, Marker, TileLayer, Tooltip, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { RegionRiskSummary } from '../../data/models/risk_map_types';

interface RegionalRiskMapCardProps {
  regions: RegionRiskSummary[];
  selectedId: string;
  onSelect: (id: string) => void;
  totalBatchCount?: number;
}

const PANGKAJENE_POINT: [number, number] = [-4.8378, 119.5372];
const MAP_DEFAULT_CENTER: [number, number] = [-4.84, 119.38];

function createRiskPinIcon(region: RegionRiskSummary, isSelected: boolean) {
  const isHigh = region.highRiskCount > 0;
  const isMed = region.mediumRiskCount > 0;

  const themeColor = isHigh ? '#E11D48' : isMed ? '#D97706' : '#16A34A';
  const tagBg = isHigh ? '#FFE4E6' : isMed ? '#FEF3C7' : '#DCFCE7';
  const tagText = isHigh ? '#9F1239' : isMed ? '#92400E' : '#15803D';
  const summaryLabel = isHigh
    ? `${region.highRiskCount} tinggi`
    : isMed
    ? `${region.mediumRiskCount} perhatian`
    : region.batchCount > 0
    ? `${region.batchCount} batch`
    : '0 batch';

  const pulseRing = isSelected
    ? `<div style="
        position: absolute;
        inset: -6px;
        border-radius: 999px;
        border: 2.5px solid ${themeColor};
        animation: pulseRing 1.8s infinite;
        pointer-events: none;
      "></div>`
    : '';

  return L.divIcon({
    className: 'custom-leaflet-div-icon',
    iconSize: isSelected ? [200, 36] : [180, 32],
    iconAnchor: isSelected ? [100, 18] : [90, 16],
    html: `
      <div style="position:relative; display:inline-block; transition:all 0.25s ease; ${
        isSelected ? 'transform: scale(1.15); z-index: 1000;' : 'transform: scale(1);'
      }">
        ${pulseRing}
        <div style="
          display: inline-flex;
          align-items: center;
          background: rgba(255, 255, 255, 0.98);
          border: 1.5px solid ${themeColor};
          border-radius: 999px;
          padding: 3px 8px 3px 5px;
          box-shadow: ${
            isSelected
              ? `0 0 0 4px ${themeColor}33, 0 6px 18px rgba(0,0,0,0.2)`
              : '0 2px 8px rgba(0, 0, 0, 0.12)'
          };
          white-space: nowrap;
          gap: 6px;
          font-family: inherit;
          user-select: none;
        ">
          <span style="
            width: 18px;
            height: 18px;
            border-radius: 50%;
            background: ${themeColor};
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
          ">📍</span>
          <span style="
            font-size: 11.5px;
            font-weight: 800;
            color: #0F172A;
          ">${region.name}</span>
          <span style="
            background: ${tagBg};
            color: ${tagText};
            font-size: 10px;
            font-weight: 800;
            padding: 1px 6px;
            border-radius: 999px;
          ">&bull; ${summaryLabel}</span>
        </div>
      </div>
    `,
  });
}

function createMainlandIcon() {
  return L.divIcon({
    className: 'custom-leaflet-div-icon',
    iconSize: [140, 32],
    iconAnchor: [20, 16],
    html: `
      <div style="
        display: inline-flex;
        align-items: center;
        background: rgba(255, 255, 255, 0.96);
        border: 2px solid #0284C7;
        border-radius: 999px;
        padding: 4px 10px 4px 6px;
        box-shadow: 0 3px 10px rgba(2, 132, 199, 0.2);
        white-space: nowrap;
        gap: 6px;
        font-family: inherit;
        user-select: none;
      ">
        <span style="
          width: 14px;
          height: 14px;
          border-radius: 50%;
          border: 2.5px solid #0284C7;
          background: #ffffff;
          display: flex;
          align-items: center;
          justify-content: center;
        ">
          <span style="width: 4px; height: 4px; border-radius: 50%; background: #0284C7;"></span>
        </span>
        <span style="font-size: 12px; font-weight: 800; color: #0F172A;">Pangkajene</span>
      </div>
    `,
  });
}

const FocusOnRegion: React.FC<{ region: RegionRiskSummary | undefined }> = ({ region }) => {
  const map = useMap();
  useEffect(() => {
    if (!region) return;
    map.panTo([region.point.lat, region.point.lng], { animate: true, duration: 0.6 });
  }, [region, map]);
  return null;
};

const AutoFitDistributors: React.FC<{ regions: RegionRiskSummary[] }> = ({ regions }) => {
  const map = useMap();
  const key = regions.map((r) => `${r.point.lat},${r.point.lng}`).join('|');
  useEffect(() => {
    if (regions.length === 0) return;
    const bounds = L.latLngBounds([
      ...regions.map((r): [number, number] => [r.point.lat, r.point.lng]),
      PANGKAJENE_POINT,
    ]);
    map.fitBounds(bounds, { padding: [50, 50], maxZoom: 11 });
  }, [key, map, regions]);
  return null;
};

export const RegionalRiskMapCard: React.FC<RegionalRiskMapCardProps> = ({
  regions,
  selectedId,
  onSelect,
  totalBatchCount = 0,
}) => {
  const selectedRegion = regions.find((r) => r.id === selectedId);

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 shadow-2xs overflow-hidden flex flex-col">
      <style>{`
        @keyframes pulseRing {
          0% { transform: scale(0.95); opacity: 0.9; }
          70% { transform: scale(1.35); opacity: 0; }
          100% { transform: scale(1.35); opacity: 0; }
        }
      `}</style>

      {/* Card Header */}
      <div className="p-5 pb-3">
        <h3 className="text-sm font-bold text-slate-900">
          Sebaran risiko distributor
        </h3>
        <p className="text-xs text-slate-500 mt-0.5">
          Tabel distributors Realtime Database &bull; {regions.length} distributor terdaftar &bull; {totalBatchCount} batch
        </p>
      </div>

      {/* Map Container */}
      <div className="relative isolate h-[300px] sm:h-[380px] lg:h-[480px] w-full bg-[#E5F3F7]">
        {/* Floating bottom-left badge */}
        <div className="absolute bottom-4 left-4 z-1000 pointer-events-none rounded-full bg-white/95 backdrop-blur-md px-3.5 py-1.5 border border-slate-200/90 shadow-sm text-[11px] font-semibold text-slate-700">
          Peta distributor resmi &bull; realtime database
        </div>

        <MapContainer
          center={MAP_DEFAULT_CENTER}
          zoom={10}
          scrollWheelZoom
          className="h-full w-full"
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />

          <AutoFitDistributors regions={regions} />
          <FocusOnRegion region={selectedRegion} />

          {/* Mainland reference pin: Pangkajene */}
          <Marker position={PANGKAJENE_POINT} icon={createMainlandIcon()} zIndexOffset={50}>
            <Tooltip direction="top">Titik referensi daratan utama Pangkep</Tooltip>
          </Marker>

          {/* Real Distributor Markers from Database */}
          {regions.map((region) => {
            const isSelected = region.id === selectedId;

            return (
              <Marker
                key={region.id}
                position={[region.point.lat, region.point.lng]}
                icon={createRiskPinIcon(region, isSelected)}
                eventHandlers={{ click: () => onSelect(region.id) }}
                zIndexOffset={isSelected ? 1000 : 300}
              >
                <Tooltip direction="top" offset={[0, -14]}>
                  <div className="font-bold text-xs">{region.name}</div>
                  <div className="text-[10px] text-slate-500">
                    {region.batchCount} batch &bull; {region.totalTonnageTon} ton
                  </div>
                </Tooltip>
              </Marker>
            );
          })}
        </MapContainer>
      </div>

      {/* Legend & Footnote below Map */}
      <div className="p-4 space-y-2 border-t border-slate-100 bg-white">
        <div className="flex flex-wrap items-center gap-2">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-bold text-emerald-700 border border-emerald-200/60">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
            0–29 rendah
          </span>
          <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-50 px-2.5 py-0.5 text-xs font-bold text-amber-700 border border-amber-200/60">
            <span className="h-1.5 w-1.5 rounded-full bg-amber-500" />
            30–59 perhatian
          </span>
          <span className="inline-flex items-center gap-1.5 rounded-full bg-rose-50 px-2.5 py-0.5 text-xs font-bold text-rose-700 border border-rose-200/60">
            <span className="h-1.5 w-1.5 rounded-full bg-rose-500" />
            60–100 tinggi
          </span>
        </div>

        <p className="text-[11px] text-slate-400 leading-snug">
          Lokasi pangkalan diambil murni dari tabel distributors di Realtime Database.
        </p>
      </div>
    </div>
  );
};
