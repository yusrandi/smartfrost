import React, { useEffect } from 'react';
import { CircleMarker, MapContainer, Marker, Polyline, TileLayer, Tooltip, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import {
  DISTRIBUTOR_LOCATIONS,
  MAP_DEFAULT_CENTER,
  resolveLocation,
  type DistributorLocation,
  type GeoPoint,
} from '../../../../core/constants/locations';
import type { MonitoringBatch } from '../../data/models/monitoring_types';

interface TrackingMapCardProps {
  batches: MonitoringBatch[];
  selectedId: string | null;
  onSelect: (id: string) => void;
  isLive: boolean;
}

const toLatLng = (p: GeoPoint): [number, number] => [p.lat, p.lng];

// Injected CSS for trackline animation and pulsing radar ripples
const MAP_STYLES = `
@keyframes marchDashes {
  from {
    stroke-dashoffset: 44;
  }
  to {
    stroke-dashoffset: 0;
  }
}
.animated-trackline {
  animation: marchDashes 1.2s linear infinite !important;
}
@keyframes pulseRadar {
  0% {
    transform: scale(0.95);
    opacity: 0.9;
  }
  70% {
    transform: scale(1.45);
    opacity: 0;
  }
  100% {
    transform: scale(1.45);
    opacity: 0;
  }
}
.radar-ring-origin {
  position: absolute;
  inset: -6px;
  border-radius: 999px;
  border: 3px solid #22c55e;
  animation: pulseRadar 1.8s cubic-bezier(0.24, 0, 0.38, 1) infinite;
  pointer-events: none;
}
.radar-ring-dest {
  position: absolute;
  inset: -6px;
  border-radius: 999px;
  border: 3px solid #0284c7;
  animation: pulseRadar 1.8s cubic-bezier(0.24, 0, 0.38, 1) infinite;
  pointer-events: none;
}
`;

// Custom HTML Pin for Island Distributors (Pill with Number Tag & Label)
function createIslandIcon(
  loc: DistributorLocation,
  isSelectedOrigin: boolean,
  isSelectedDest: boolean,
  hasActiveSelection: boolean
) {
  const isHighlighted = isSelectedOrigin || isSelectedDest;
  const borderCol = isSelectedOrigin ? '#16A34A' : isSelectedDest ? '#0284C7' : '#0D9488';
  const tagBg = isSelectedOrigin ? '#16A34A' : isSelectedDest ? '#0284C7' : '#0D9488';
  const tagText = loc.code || '•';

  const roleBadge = isSelectedOrigin
    ? '<span style="background:#15803D;color:#ffffff;padding:2px 8px;border-radius:999px;font-size:9.5px;font-weight:900;letter-spacing:0.5px;box-shadow:0 1px 4px rgba(0,0,0,0.25);">🚩 ASAL</span>'
    : isSelectedDest
    ? '<span style="background:#0284C7;color:#ffffff;padding:2px 8px;border-radius:999px;font-size:9.5px;font-weight:900;letter-spacing:0.5px;box-shadow:0 1px 4px rgba(0,0,0,0.25);">🏁 TUJUAN</span>'
    : '';

  const radarWave = isSelectedOrigin
    ? '<div class="radar-ring-origin"></div>'
    : isSelectedDest
    ? '<div class="radar-ring-dest"></div>'
    : '';

  const containerShadow = isSelectedOrigin
    ? 'box-shadow: 0 0 0 5px rgba(34, 197, 94, 0.35), 0 8px 24px rgba(22, 163, 74, 0.4);'
    : isSelectedDest
    ? 'box-shadow: 0 0 0 5px rgba(14, 165, 233, 0.35), 0 8px 24px rgba(2, 132, 199, 0.45);'
    : 'box-shadow: 0 2px 8px rgba(0, 0, 0, 0.14);';

  const scaleAndOpacity = isHighlighted
    ? 'transform: scale(1.18); font-weight: 800; z-index: 1000;'
    : hasActiveSelection
    ? 'opacity: 0.72; filter: saturate(0.85); transform: scale(0.96);'
    : 'opacity: 1; transform: scale(1);';

  return L.divIcon({
    className: 'custom-leaflet-div-icon',
    iconSize: isHighlighted ? [210, 40] : [175, 34],
    iconAnchor: isHighlighted ? [105, 20] : [87, 17],
    html: `
      <div style="position:relative; display:inline-block; transition:all 0.3s ease; ${scaleAndOpacity}">
        ${radarWave}
        <div style="
          display: inline-flex;
          align-items: center;
          background: #ffffff;
          border: ${isHighlighted ? '2.5px' : '1.5px'} solid ${borderCol};
          border-radius: 999px;
          padding: ${isHighlighted ? '4px 12px 4px 5px' : '3px 10px 3px 4px'};
          ${containerShadow}
          white-space: nowrap;
          gap: 6px;
          font-family: inherit;
          user-select: none;
        ">
          <span style="
            width: ${isHighlighted ? '24px' : '22px'};
            height: ${isHighlighted ? '24px' : '22px'};
            border-radius: 50%;
            background: ${tagBg};
            color: #ffffff;
            font-size: ${isHighlighted ? '11px' : '10px'};
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
          ">${tagText}</span>
          <span style="
            font-size: ${isHighlighted ? '12.5px' : '11.5px'};
            font-weight: ${isHighlighted ? '800' : '700'};
            color: ${isHighlighted ? '#0F172A' : '#1E293B'};
          ">${loc.name}</span>
          ${roleBadge}
        </div>
      </div>
    `,
  });
}

// Custom Pin for Mainland Hub (Pangkajene & Maccini Baji)
function createMainlandHubIcon(
  loc: DistributorLocation,
  isSelectedOrigin: boolean,
  isSelectedDest: boolean,
  hasActiveSelection: boolean
) {
  const isHighlighted = isSelectedDest || isSelectedOrigin;
  const borderCol = isSelectedDest ? '#0284C7' : isSelectedOrigin ? '#16A34A' : '#0284C7';

  const roleBadge = isSelectedDest
    ? '<span style="background:#0284C7;color:#ffffff;padding:2px 8px;border-radius:999px;font-size:9.5px;font-weight:900;letter-spacing:0.5px;box-shadow:0 1px 4px rgba(0,0,0,0.25);margin-left:4px;">🏁 TUJUAN</span>'
    : isSelectedOrigin
    ? '<span style="background:#15803D;color:#ffffff;padding:2px 8px;border-radius:999px;font-size:9.5px;font-weight:900;letter-spacing:0.5px;box-shadow:0 1px 4px rgba(0,0,0,0.25);margin-left:4px;">🚩 ASAL</span>'
    : '';

  const radarWave = isSelectedDest
    ? '<div class="radar-ring-dest"></div>'
    : isSelectedOrigin
    ? '<div class="radar-ring-origin"></div>'
    : '';

  const containerShadow = isHighlighted
    ? 'box-shadow: 0 0 0 5px rgba(14, 165, 233, 0.35), 0 8px 26px rgba(2, 132, 199, 0.45);'
    : 'box-shadow: 0 3px 12px rgba(2, 132, 199, 0.22);';

  const scaleAndOpacity = isHighlighted
    ? 'transform: scale(1.15); font-weight: 800; z-index: 1000;'
    : hasActiveSelection
    ? 'opacity: 0.72; filter: saturate(0.85); transform: scale(0.96);'
    : 'opacity: 1; transform: scale(1);';

  return L.divIcon({
    className: 'custom-leaflet-div-icon',
    iconSize: isHighlighted ? [250, 52] : [220, 46],
    iconAnchor: isHighlighted ? [28, 26] : [24, 23],
    html: `
      <div style="position:relative; display:inline-block; transition:all 0.3s ease; ${scaleAndOpacity}">
        ${radarWave}
        <div style="
          display: inline-flex;
          align-items: center;
          background: #ffffff;
          border: ${isHighlighted ? '3px' : '2px'} solid ${borderCol};
          border-radius: 999px;
          padding: 5px 14px 5px 6px;
          ${containerShadow}
          white-space: nowrap;
          gap: 8px;
          font-family: inherit;
          user-select: none;
        ">
          <span style="
            width: 24px;
            height: 24px;
            border-radius: 50%;
            border: 2.5px solid ${borderCol};
            background: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
          ">
            <span style="width: 8px; height: 8px; border-radius: 50%; background: ${borderCol};"></span>
          </span>
          <div style="line-height: 1.25;">
            <div style="font-size: ${isHighlighted ? '13.5px' : '13px'}; font-weight: 800; color: #0F172A; display: flex; align-items: center;">
              <span>${loc.name}</span>
              ${roleBadge}
            </div>
            <div style="font-size: 9.5px; color: #64748B; font-weight: 600;">${loc.description || 'Titik referensi geografis'}</div>
          </div>
        </div>
      </div>
    `,
  });
}

// Custom midpoint indicator badge showing batch & commodity along the dashed line
function createMidpointIcon(batchCode: string, commodityText: string) {
  return L.divIcon({
    className: 'custom-leaflet-div-icon',
    iconSize: [180, 28],
    iconAnchor: [90, 14],
    html: `
      <div style="
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(15, 23, 42, 0.9);
        color: #ffffff;
        padding: 4px 10px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 700;
        letter-spacing: 0.2px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        border: 1.5px solid #38BDF8;
        white-space: nowrap;
        pointer-events: none;
      ">
        <span style="color:#38BDF8; font-weight:800;">${batchCode}</span>
        <span style="color:#94A3B8;">&bull;</span>
        <span>${commodityText}</span>
        <span style="color:#38BDF8;">➔</span>
      </div>
    `,
  });
}

/** Re-fit map bounds with smooth animation whenever the selected origin/destination changes */
const FitToSelection: React.FC<{
  origin: GeoPoint | null;
  destination: GeoPoint | null;
  selectedId: string | null;
}> = ({ origin, destination, selectedId }) => {
  const map = useMap();

  useEffect(() => {
    if (!origin && !destination) return;

    if (origin && destination) {
      const bounds = L.latLngBounds([
        [origin.lat, origin.lng],
        [destination.lat, destination.lng],
      ]);
      // Fit bounds to show both origin and destination with comfortable padding
      map.fitBounds(bounds, {
        padding: [80, 80],
        maxZoom: 11,
        animate: true,
        duration: 0.8,
      });
    } else {
      const target = origin || destination;
      if (target) {
        map.setView([target.lat, target.lng], 10, { animate: true });
      }
    }
  }, [origin?.lat, origin?.lng, destination?.lat, destination?.lng, selectedId, map]);

  return null;
};

// Maritime corridor illustration lines connecting island clusters to mainland
const MARITIME_CORRIDORS: Array<[number, number][]> = [
  // Outer cluster (Kapoposang -> Sabutung -> Pangkajene)
  [
    [-4.6958, 118.9536],
    [-4.74, 119.18],
    [-4.789, 119.42],
    [-4.8378, 119.5372],
  ],
  // Middle cluster (Sarappo -> Jangang-jangangan -> Pangkajene)
  [
    [-4.869, 119.255],
    [-4.862, 119.351],
    [-4.8378, 119.5372],
  ],
  // Southern cluster (Badi -> Sanane -> Bontosua -> Maccini Baji)
  [
    [-4.968, 119.288],
    [-4.8986, 119.3361],
    [-4.928, 119.317],
    [-4.7741, 119.4936],
  ],
];

export const TrackingMapCard: React.FC<TrackingMapCardProps> = ({ batches, selectedId, isLive }) => {
  const selected = batches.find((b) => b.summary.id === selectedId) ?? null;

  // Resolve origin and destination points reliably
  const originPoint: GeoPoint | null =
    selected?.originPoint ?? (selected ? resolveLocation(selected.summary.origin) : null);
  const destinationPoint: GeoPoint | null =
    selected?.destinationPoint ?? (selected ? resolveLocation(selected.summary.destination) : null);

  const hasTrackline = !!(originPoint && destinationPoint);

  // Compute midpoint for route chip
  const midPoint: GeoPoint | null =
    originPoint && destinationPoint
      ? {
          lat: (originPoint.lat + destinationPoint.lat) / 2,
          lng: (originPoint.lng + destinationPoint.lng) / 2,
        }
      : null;

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 shadow-2xs overflow-hidden flex flex-col">
      {/* Inject animations style tag */}
      <style>{MAP_STYLES}</style>

      {/* Card Header Info */}
      <div className="p-5 pb-3">
        <h3 className="text-sm font-bold text-slate-900">
          {selected
            ? `${selected.summary.batchId} • ${selected.summary.origin} → ${selected.summary.destination}`
            : 'Peta sebaran distributor & jalur perjalanan antarpulau'}
        </h3>
        <p className="text-xs text-slate-500 mt-0.5">
          {selected
            ? `${selected.senderName} → ${selected.receiverName} • ${selected.summary.commodity} ${selected.summary.weightKg} kg`
            : 'Menampilkan seluruh pangkalan distributor pulau nelayan dan dermaga daratan Pangkep'}
        </p>
      </div>

      {/* Main Map Canvas with Overlays */}
      <div className="relative z-0 isolate h-[520px] w-full bg-[#E5F3F7]">
        {/* Top-Left Geographic Context Card */}
        <div className="absolute top-4 left-4 z-1000 pointer-events-none rounded-xl bg-white/90 backdrop-blur-md px-3.5 py-2.5 border border-slate-200/80 shadow-sm max-w-[240px]">
          <div className="text-xs font-black text-slate-900">Kepulauan Pangkep</div>
          <div className="text-[10px] text-slate-500 mt-0.5 leading-snug">
            Posisi relatif geografis • jalur maritim antarpulau Spermonde
          </div>
        </div>

        {/* Top-Right Compass Rose Indicator */}
        <div className="absolute top-4 right-4 z-1000 pointer-events-none rounded-full bg-white/90 backdrop-blur-md h-9 w-9 border border-slate-200/80 shadow-sm flex flex-col items-center justify-center">
          <span className="text-[10px] font-black text-slate-800 leading-none">U</span>
          <span className="text-[9px] text-sky-600 font-bold leading-none">▲</span>
        </div>

        {/* Bottom-Left Inset Box (Daerah Sorong / Ekstra-Regional) */}
        <div className="absolute bottom-6 left-4 z-1000 pointer-events-none rounded-xl bg-white/90 backdrop-blur-md p-3 border border-slate-200/80 shadow-sm max-w-[230px]">
          <div className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
            Inset - Tidak dalam skala peta
          </div>
          <div className="text-xs font-bold text-slate-800 mt-0.5 flex items-center gap-1.5">
            <span className="w-4 h-4 rounded-full bg-sky-100 text-sky-700 text-[9px] font-black flex items-center justify-center">
              04
            </span>
            <span>Daerah Sorong</span>
          </div>
          <div className="text-[9.5px] text-slate-500 mt-0.5 leading-snug">
            Papua Barat Daya (timur laut Pangkep). Rute jangka panjang (~10 hari).
          </div>
        </div>

        {/* Maritime Route Legend Tag */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-1000 pointer-events-none rounded-full bg-white/95 backdrop-blur-xs px-3.5 py-1.5 border border-sky-300 shadow-sm flex items-center gap-2 text-[11px] font-bold text-sky-800">
          <span className="h-2 w-5 border-b-2 border-dashed border-sky-600 inline-block" />
          <span>Trackline rute aktif: Garis putus-putus berjalan</span>
        </div>

        <MapContainer
          center={toLatLng(MAP_DEFAULT_CENTER)}
          zoom={10}
          scrollWheelZoom
          className="h-full w-full"
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />

          {/* Dynamic bounds fitting to origin and destination */}
          <FitToSelection origin={originPoint} destination={destinationPoint} selectedId={selectedId} />

          {/* Subtle background corridors for maritime context */}
          {MARITIME_CORRIDORS.map((corridor, idx) => (
            <Polyline
              key={`corridor-${idx}`}
              positions={corridor}
              pathOptions={{
                color: '#38BDF8',
                weight: 1.5,
                dashArray: '4 8',
                opacity: 0.3,
              }}
            />
          ))}

          {/* ALL DISTRIBUTOR LOCATIONS (Pills & Markers) with Active Highlight Focus */}
          {DISTRIBUTOR_LOCATIONS.map((loc) => {
            const locName = loc.name.toLowerCase();
            const isOrigin =
              selected?.summary.origin
                ? selected.summary.origin.toLowerCase().includes(locName) || locName.includes(selected.summary.origin.toLowerCase())
                : false;
            const isDest =
              selected?.summary.destination
                ? selected.summary.destination.toLowerCase().includes(locName) || locName.includes(selected.summary.destination.toLowerCase())
                : false;

            const hasActiveSelection = !!selected;

            if (loc.isMainHub) {
              return (
                <Marker
                  key={loc.id}
                  position={toLatLng(loc.point)}
                  icon={createMainlandHubIcon(loc, isOrigin, isDest, hasActiveSelection)}
                  zIndexOffset={isOrigin || isDest ? 1500 : 100}
                >
                  <Tooltip direction="top" offset={[0, -22]}>
                    <div className="font-bold text-xs">{loc.name}</div>
                    <div className="text-[10px] text-slate-500">{loc.description}</div>
                  </Tooltip>
                </Marker>
              );
            }

            return (
              <Marker
                key={loc.id}
                position={toLatLng(loc.point)}
                icon={createIslandIcon(loc, isOrigin, isDest, hasActiveSelection)}
                zIndexOffset={isOrigin || isDest ? 1500 : 50}
              >
                <Tooltip direction="top" offset={[0, -14]}>
                  <div className="font-bold text-xs">{loc.name}</div>
                  {loc.description && <div className="text-[10px] text-slate-500">{loc.description}</div>}
                </Tooltip>
              </Marker>
            );
          })}

          {/* Prominent Animated Trackline from Origin to Destination (Garis Putus-Putus Berjalan) */}
          {hasTrackline && originPoint && destinationPoint && (
            <>
              {/* Outer soft glow underline */}
              <Polyline
                positions={[toLatLng(originPoint), toLatLng(destinationPoint)]}
                pathOptions={{
                  color: '#38BDF8',
                  weight: 10,
                  dashArray: '10 12',
                  opacity: 0.45,
                }}
              />
              {/* Main animated crisp dashed trackline */}
              <Polyline
                positions={[toLatLng(originPoint), toLatLng(destinationPoint)]}
                pathOptions={{
                  className: 'animated-trackline',
                  color: '#0284C7',
                  weight: 4.5,
                  dashArray: '10 12',
                  opacity: 1,
                }}
              />

              {/* Midpoint badge indicator chip */}
              {midPoint && selected && (
                <Marker
                  position={toLatLng(midPoint)}
                  icon={createMidpointIcon(selected.summary.batchId, `${selected.summary.commodity} ${selected.summary.weightKg}kg`)}
                  zIndexOffset={1600}
                />
              )}

              {/* Endpoint Indicator at Origin (Green double ripple) */}
              <CircleMarker
                center={toLatLng(originPoint)}
                radius={14}
                pathOptions={{
                  color: '#22C55E',
                  fillColor: '#86EFAC',
                  fillOpacity: 0.35,
                  weight: 2,
                }}
              />
              <CircleMarker
                center={toLatLng(originPoint)}
                radius={6}
                pathOptions={{
                  color: '#15803D',
                  fillColor: '#22C55E',
                  fillOpacity: 1,
                  weight: 2.5,
                }}
              >
                <Tooltip direction="bottom" offset={[0, 10]} permanent>
                  <span className="text-[10px] font-black text-emerald-800">🚩 ASAL: {selected?.summary.origin}</span>
                </Tooltip>
              </CircleMarker>

              {/* Endpoint Indicator at Destination (Sky double ripple) */}
              <CircleMarker
                center={toLatLng(destinationPoint)}
                radius={14}
                pathOptions={{
                  color: '#0284C7',
                  fillColor: '#7DD3FC',
                  fillOpacity: 0.35,
                  weight: 2,
                }}
              />
              <CircleMarker
                center={toLatLng(destinationPoint)}
                radius={6}
                pathOptions={{
                  color: '#0369A1',
                  fillColor: '#0284C7',
                  fillOpacity: 1,
                  weight: 2.5,
                }}
              >
                <Tooltip direction="bottom" offset={[0, 10]} permanent>
                  <span className="text-[10px] font-black text-sky-800">🏁 TUJUAN: {selected?.summary.destination}</span>
                </Tooltip>
              </CircleMarker>
            </>
          )}
        </MapContainer>
      </div>

      {/* Footer Info */}
      <div className="flex flex-wrap items-center justify-between gap-2 px-5 py-3 text-[11px] text-slate-500 border-t border-slate-100">
        <div className="inline-flex items-center gap-1.5 rounded-full bg-sky-50 px-3 py-1 text-sky-800 font-semibold border border-sky-200/60">
          <span className="h-2 w-2 rounded-full bg-sky-500 animate-pulse" />
          {selected
            ? `Rute aktif disorot: ${selected.summary.origin} → ${selected.summary.destination}`
            : 'Pilih perjalanan dari daftar di samping untuk menyorot rute'}
        </div>
        <div>
          {isLive ? 'Realtime Database terhubung' : 'Data operasional terdistribusi'}
        </div>
      </div>
      <p className="px-5 pb-3 text-[11px] text-slate-400">
        * Lokasi asal dan tujuan rute terpilih disorot dengan animasi radar dan garis trackline.
      </p>
    </div>
  );
};
