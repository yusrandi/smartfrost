export interface GeoPoint {
  lat: number;
  lng: number;
}

export interface DistributorLocation {
  id: string;
  code?: string;
  name: string;
  point: GeoPoint;
  type: 'island' | 'mainland' | 'water';
  description?: string;
  isMainHub?: boolean;
}

/** Complete list of distributor locations in Pangkep Spermonde matching official data and design. */
export const DISTRIBUTOR_LOCATIONS: DistributorLocation[] = [
  {
    id: 'sanane',
    code: '01',
    name: 'Pulau Sanane',
    point: { lat: -4.8986, lng: 119.3361 },
    type: 'island',
    description: '±2 jam menuju distributor',
  },
  {
    id: 'jangangan',
    code: '02',
    name: 'Pulau Jangang-jangangan',
    point: { lat: -4.862, lng: 119.351 },
    type: 'island',
    description: '3–5 jam menuju distributor',
  },
  {
    id: 'perairan_pangkep',
    code: '03',
    name: 'Perairan Pangkep dan Sekitarnya',
    point: { lat: -4.78, lng: 119.18 },
    type: 'water',
    description: 'Cakupan perairan tangkapan nelayan',
  },
  {
    id: 'sabutung',
    code: '05',
    name: 'Pulau Sabutung',
    point: { lat: -4.789, lng: 119.42 },
    type: 'island',
    description: '30–45 menit menuju distributor',
  },
  {
    id: 'kapoposang',
    code: '06',
    name: 'Pulau Kapoposang',
    point: { lat: -4.6958, lng: 118.9536 },
    type: 'island',
    description: '1–2 jam dari pangkalan terluar',
  },
  {
    id: 'badi',
    code: '07',
    name: 'Pulau Badi*',
    point: { lat: -4.968, lng: 119.288 },
    type: 'island',
    description: '1,5–2 jam menuju distributor',
  },
  {
    id: 'sarappo_keke',
    code: '08',
    name: 'Sarappo Keke',
    point: { lat: -4.869, lng: 119.255 },
    type: 'island',
    description: '2–2,5 jam • gugusan Sarappo',
  },
  {
    id: 'sarappo_lompo',
    name: 'Sarappo Lompo',
    point: { lat: -4.887, lng: 119.262 },
    type: 'island',
    description: 'Gugusan Sarappo',
  },
  {
    id: 'bontosua',
    code: '09',
    name: 'Pulau Bontosua*',
    point: { lat: -4.928, lng: 119.317 },
    type: 'island',
    description: '4–5 jam menuju distributor',
  },
  {
    id: 'karanrang',
    name: 'Pulau Karanrang',
    point: { lat: -4.8631, lng: 119.3872 },
    type: 'island',
    description: 'Hub pulau nelayan',
  },
  {
    id: 'kalupu',
    name: 'Pulau Kalupu',
    point: { lat: -4.845, lng: 119.31 },
    type: 'island',
    description: 'Pulau sentra perikanan',
  },
  {
    id: 'salemo',
    name: 'Pulau Salemo',
    point: { lat: -4.808, lng: 119.385 },
    type: 'island',
    description: 'Sentra nelayan tangkap Pangkep',
  },
  {
    id: 'balang_lompo',
    name: 'Pulau Balang Lompo',
    point: { lat: -4.935, lng: 119.362 },
    type: 'island',
    description: 'Pulau pengirim utama',
  },
  {
    id: 'maccini_baji',
    name: 'Dermaga Maccini Baji',
    point: { lat: -4.7741, lng: 119.4936 },
    type: 'mainland',
    description: 'Pelabuhan pendaratan ikan utama Pangkep',
    isMainHub: true,
  },
  {
    id: 'biringkassi',
    name: 'Dermaga Biringkassi',
    point: { lat: -4.7958, lng: 119.5085 },
    type: 'mainland',
    description: 'Dermaga logistik Pangkep',
    isMainHub: true,
  },
  {
    id: 'pangkajene',
    name: 'Pangkajene',
    point: { lat: -4.8378, lng: 119.5372 },
    type: 'mainland',
    description: 'Titik referensi geografis',
    isMainHub: true,
  },
];

/** Predefined map lookup by name. */
export const KNOWN_LOCATIONS: Record<string, GeoPoint> = DISTRIBUTOR_LOCATIONS.reduce(
  (acc, item) => {
    acc[item.name] = item.point;
    return acc;
  },
  {} as Record<string, GeoPoint>
);

// Map shortcuts / aliases
KNOWN_LOCATIONS['Balang Lompo'] = { lat: -4.935, lng: 119.362 };
KNOWN_LOCATIONS['Pulau Balang Lompo'] = { lat: -4.935, lng: 119.362 };
KNOWN_LOCATIONS['Salemo'] = { lat: -4.808, lng: 119.385 };
KNOWN_LOCATIONS['Pulau Salemo'] = { lat: -4.808, lng: 119.385 };
KNOWN_LOCATIONS['Sarappo'] = { lat: -4.887, lng: 119.262 };
KNOWN_LOCATIONS['Pulau Sarappo'] = { lat: -4.887, lng: 119.262 };
KNOWN_LOCATIONS['Sarappo Lompo'] = { lat: -4.887, lng: 119.262 };
KNOWN_LOCATIONS['Sarappo Keke'] = { lat: -4.869, lng: 119.255 };
KNOWN_LOCATIONS['Sabutung'] = { lat: -4.789, lng: 119.42 };
KNOWN_LOCATIONS['Pulau Sabutung'] = { lat: -4.789, lng: 119.42 };
KNOWN_LOCATIONS['Karanrang'] = { lat: -4.8631, lng: 119.3872 };
KNOWN_LOCATIONS['Pulau Karanrang'] = { lat: -4.8631, lng: 119.3872 };
KNOWN_LOCATIONS['Sanane'] = { lat: -4.8986, lng: 119.3361 };
KNOWN_LOCATIONS['Pulau Sanane'] = { lat: -4.8986, lng: 119.3361 };
KNOWN_LOCATIONS['Kapoposang'] = { lat: -4.6958, lng: 118.9536 };
KNOWN_LOCATIONS['Pulau Kapoposang'] = { lat: -4.6958, lng: 118.9536 };
KNOWN_LOCATIONS['Badi'] = { lat: -4.968, lng: 119.288 };
KNOWN_LOCATIONS['Pulau Badi'] = { lat: -4.968, lng: 119.288 };
KNOWN_LOCATIONS['Bontosua'] = { lat: -4.928, lng: 119.317 };
KNOWN_LOCATIONS['Pulau Bontosua'] = { lat: -4.928, lng: 119.317 };
KNOWN_LOCATIONS['Pulau Jangan-Jangangan'] = { lat: -4.862, lng: 119.351 };
KNOWN_LOCATIONS['Jangan-Jangangan'] = { lat: -4.862, lng: 119.351 };
KNOWN_LOCATIONS['Jangang-Jangangan'] = { lat: -4.862, lng: 119.351 };
KNOWN_LOCATIONS['Pulau Jangang-jangangan'] = { lat: -4.862, lng: 119.351 };
KNOWN_LOCATIONS['Pangkajene'] = { lat: -4.8378, lng: 119.5372 };
KNOWN_LOCATIONS['Maccini Baji'] = { lat: -4.7741, lng: 119.4936 };
KNOWN_LOCATIONS['Dermaga Maccini Baji'] = { lat: -4.7741, lng: 119.4936 };
KNOWN_LOCATIONS['Biringkassi'] = { lat: -4.7958, lng: 119.5085 };
KNOWN_LOCATIONS['Pelabuhan Paotere'] = { lat: -5.1146, lng: 119.419 };
KNOWN_LOCATIONS['Pelabuhan Bira'] = { lat: -5.612, lng: 120.457 };

export const MAP_DEFAULT_CENTER: GeoPoint = { lat: -4.84, lng: 119.35 };

export function resolveLocation(name: string | undefined): GeoPoint | null {
  if (!name) return null;
  const clean = name.trim().toLowerCase();
  // Exact match in KNOWN_LOCATIONS
  for (const [key, pt] of Object.entries(KNOWN_LOCATIONS)) {
    if (key.toLowerCase() === clean) return pt;
  }
  // Substring match in KNOWN_LOCATIONS
  for (const [key, pt] of Object.entries(KNOWN_LOCATIONS)) {
    const k = key.toLowerCase();
    if (clean.includes(k) || k.includes(clean)) return pt;
  }
  // Match in DISTRIBUTOR_LOCATIONS
  for (const loc of DISTRIBUTOR_LOCATIONS) {
    const n = loc.name.toLowerCase();
    if (clean.includes(n) || n.includes(clean)) return loc.point;
  }
  return null;
}

/** Great-circle distance in kilometres. */
export function haversineKm(a: GeoPoint, b: GeoPoint): number {
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const h =
    Math.sin(dLat / 2) ** 2 + Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}
