import { ref, onValue, set, remove, serverTimestamp, type DataSnapshot } from 'firebase/database';
import { rtdb } from '../../../../firebase';

export interface MasterFishItem {
  id: string;
  name: string;
  createdAt?: number;
}

export interface MasterCoolboxItem {
  id: string;
  code: string;
  label?: string;
  status?: string;
  createdAt?: number;
}

export interface MasterDistributorItem {
  id: string;
  name: string;
  storeLocation: string;
  latitude: number;
  longitude: number;
  email?: string;
  organization?: string;
  role?: string;
  updatedAt?: number;
}

export interface MasterUserItem {
  id: string;
  name: string;
  email: string;
  role?: string;
  accessRoleLabel?: string;
  storeLocation?: string;
  location?: string;
  phoneNumber?: string;
  organization?: string;
  updatedAt?: number;
}

export const DEFAULT_FISHES = [
  'Ikan Bandeng',
  'Ikan Tongkol',
  'Ikan Kerapu',
  'Ikan Cakalang',
  'Ikan Kakap Merah',
  'Ikan Tenggiri',
];

export const DEFAULT_COOLBOXES = [
  { code: 'SFR-CB-01', label: 'Coolbox IoT 01 - Maccini Baji' },
  { code: 'SFR-CB-042', label: 'Coolbox IoT 042 - Karanrang' },
  { code: 'SFR-CB-108', label: 'Coolbox IoT 108 - Sabutung' },
  { code: 'SFR-CB-201', label: 'Coolbox IoT 201 - Kulambing' },
  { code: 'SFR-CB-315', label: 'Coolbox IoT 315 - Salemo' },
  { code: 'SFR-CB-101', label: 'Coolbox IoT 101 - Gondong Bali' },
];

export const DEFAULT_DISTRIBUTORS: Omit<MasterDistributorItem, 'id'>[] = [
  {
    name: 'Dermaga Maccini Baji',
    storeLocation: 'Dermaga Maccini Baji',
    organization: 'Distributor Dermaga Maccini Baji',
    email: 'maccinibaji@smartfrost.id',
    role: 'distributor',
    latitude: -4.774082446457824,
    longitude: 119.4936169873191,
  },
  {
    name: 'Dermaga Biringkassi',
    storeLocation: 'Dermaga Biringkassi',
    organization: 'Distributor Dermaga Biringkassi',
    email: 'biringkassi@smartfrost.id',
    role: 'distributor',
    latitude: -4.7958,
    longitude: 119.5085,
  },
  {
    name: 'Pulau Karanrang',
    storeLocation: 'Pulau Karanrang',
    organization: 'Distributor Pulau Karanrang',
    email: 'karanrang@smartfrost.id',
    role: 'distributor',
    latitude: -4.8625,
    longitude: 119.3814,
  },
  {
    name: 'Pulau Sabutung',
    storeLocation: 'Pulau Sabutung',
    organization: 'Distributor Pulau Sabutung',
    email: 'sabutung@smartfrost.id',
    role: 'distributor',
    latitude: -4.8197,
    longitude: 119.4217,
  },
  {
    name: 'Pulau Kulambing',
    storeLocation: 'Pulau Kulambing',
    organization: 'Distributor Pulau Kulambing',
    email: 'kulambing@smartfrost.id',
    role: 'distributor',
    latitude: -4.8461,
    longitude: 119.4452,
  },
  {
    name: 'Pulau Salemo',
    storeLocation: 'Pulau Salemo',
    organization: 'Distributor Pulau Salemo',
    email: 'salemo@smartfrost.id',
    role: 'distributor',
    latitude: -4.8378,
    longitude: 119.4672,
  },
];

export class MasterDataRtdbService {
  static sanitizeKey(key: string): string {
    return key.trim().replace(/[.#$[\]/\s]+/g, '_');
  }

  // ==================== FISHES ====================
  static subscribeFishes(callback: (items: MasterFishItem[]) => void) {
    return onValue(ref(rtdb, 'master_fishes'), (snapshot: DataSnapshot) => {
      if (!snapshot.exists()) {
        callback([]);
        return;
      }
      const data = snapshot.val();
      const list: MasterFishItem[] = [];
      if (typeof data === 'object' && data !== null) {
        Object.entries(data).forEach(([key, val]) => {
          if (typeof val === 'object' && val !== null) {
            const v = val as Record<string, unknown>;
            list.push({
              id: key,
              name: String(v.name || key),
              createdAt: typeof v.createdAt === 'number' ? v.createdAt : undefined,
            });
          } else if (typeof val === 'string') {
            list.push({ id: key, name: val });
          }
        });
      }
      callback(list);
    });
  }

  static async addFish(name: string): Promise<void> {
    const trimmed = name.trim();
    if (!trimmed) throw new Error('Nama ikan tidak boleh kosong');
    const safeKey = this.sanitizeKey(trimmed);
    await set(ref(rtdb, `master_fishes/${safeKey}`), {
      name: trimmed,
      createdAt: serverTimestamp(),
    });
  }

  static async deleteFish(id: string): Promise<void> {
    await remove(ref(rtdb, `master_fishes/${id}`));
  }

  // ==================== COOLBOXES ====================
  static subscribeCoolboxes(callback: (items: MasterCoolboxItem[]) => void) {
    return onValue(ref(rtdb, 'master_coolboxes'), (snapshot: DataSnapshot) => {
      if (!snapshot.exists()) {
        callback([]);
        return;
      }
      const data = snapshot.val();
      const list: MasterCoolboxItem[] = [];
      if (typeof data === 'object' && data !== null) {
        Object.entries(data).forEach(([key, val]) => {
          if (typeof val === 'object' && val !== null) {
            const v = val as Record<string, unknown>;
            list.push({
              id: key,
              code: String(v.code || key),
              label: typeof v.label === 'string' ? v.label : undefined,
              status: typeof v.status === 'string' ? v.status : 'ready',
              createdAt: typeof v.createdAt === 'number' ? v.createdAt : undefined,
            });
          } else if (typeof val === 'string') {
            list.push({ id: key, code: val, label: val });
          }
        });
      }
      callback(list);
    });
  }

  static async addCoolbox(code: string, label?: string): Promise<void> {
    const trimmedCode = code.trim().toUpperCase();
    if (!trimmedCode) throw new Error('Kode coolbox tidak boleh kosong');
    const safeKey = this.sanitizeKey(trimmedCode);
    await set(ref(rtdb, `master_coolboxes/${safeKey}`), {
      code: trimmedCode,
      label: label?.trim() || `Coolbox IoT ${trimmedCode}`,
      status: 'ready',
      createdAt: serverTimestamp(),
    });
  }

  static async deleteCoolbox(id: string): Promise<void> {
    await remove(ref(rtdb, `master_coolboxes/${id}`));
  }

  // ==================== DISTRIBUTORS ====================
  static subscribeDistributors(callback: (items: MasterDistributorItem[]) => void) {
    return onValue(ref(rtdb, 'distributors'), (snapshot: DataSnapshot) => {
      if (!snapshot.exists()) {
        callback([]);
        return;
      }
      const data = snapshot.val();
      const list: MasterDistributorItem[] = [];
      if (typeof data === 'object' && data !== null) {
        Object.entries(data).forEach(([key, val]) => {
          if (typeof val === 'object' && val !== null) {
            const v = val as Record<string, unknown>;
            list.push({
              id: key,
              name: String(v.name || key),
              storeLocation: String(v.storeLocation || v.location || key),
              latitude: typeof v.latitude === 'number' ? v.latitude : 0,
              longitude: typeof v.longitude === 'number' ? v.longitude : 0,
              email: typeof v.email === 'string' ? v.email : undefined,
              organization: typeof v.organization === 'string' ? v.organization : undefined,
              role: typeof v.role === 'string' ? v.role : 'distributor',
              updatedAt: typeof v.updatedAt === 'number' ? v.updatedAt : undefined,
            });
          }
        });
      }
      callback(list);
    });
  }

  static async addDistributor(data: {
    name: string;
    storeLocation: string;
    latitude: number;
    longitude: number;
    email?: string;
    organization?: string;
  }): Promise<void> {
    const locKey = data.storeLocation.trim() || data.name.trim();
    if (!locKey) throw new Error('Nama dermaga/lokasi tidak boleh kosong');
    const safeKey = this.sanitizeKey(locKey);

    await set(ref(rtdb, `distributors/${safeKey}`), {
      name: data.name.trim(),
      storeLocation: data.storeLocation.trim(),
      latitude: data.latitude,
      longitude: data.longitude,
      email: data.email?.trim() || `${safeKey.toLowerCase()}@smartfrost.id`,
      organization: data.organization?.trim() || `Distributor ${data.name.trim()}`,
      role: 'distributor',
      updatedAt: serverTimestamp(),
    });
  }

  static async deleteDistributor(id: string): Promise<void> {
    await remove(ref(rtdb, `distributors/${id}`));
  }

  // ==================== USERS ====================
  static subscribeUsers(callback: (items: MasterUserItem[]) => void) {
    return onValue(ref(rtdb, 'users'), (snapshot: DataSnapshot) => {
      if (!snapshot.exists()) {
        callback([]);
        return;
      }
      const data = snapshot.val();
      const list: MasterUserItem[] = [];
      if (typeof data === 'object' && data !== null) {
        Object.entries(data).forEach(([key, val]) => {
          if (typeof val === 'object' && val !== null) {
            const v = val as Record<string, unknown>;
            list.push({
              id: key,
              name: String(v.name || key),
              email: String(v.email || key),
              role: typeof v.role === 'string' ? v.role : undefined,
              accessRoleLabel: typeof v.accessRoleLabel === 'string' ? v.accessRoleLabel : undefined,
              storeLocation: typeof v.storeLocation === 'string' ? v.storeLocation : undefined,
              location: typeof v.location === 'string' ? v.location : undefined,
              phoneNumber: typeof v.phoneNumber === 'string' ? v.phoneNumber : undefined,
              organization: typeof v.organization === 'string' ? v.organization : undefined,
              updatedAt: typeof v.updatedAt === 'number' ? v.updatedAt : undefined,
            });
          }
        });
      }
      callback(list);
    });
  }

  static async deleteUser(id: string): Promise<void> {
    await remove(ref(rtdb, `users/${id}`));
  }

  // ==================== SEED DEFAULT MASTER DATA ====================
  static async seedDefaultMasterData(): Promise<void> {
    // 1. Seed Fishes
    for (const fish of DEFAULT_FISHES) {
      const safeKey = this.sanitizeKey(fish);
      await set(ref(rtdb, `master_fishes/${safeKey}`), {
        name: fish,
        createdAt: serverTimestamp(),
      });
    }

    // 2. Seed Coolboxes
    for (const cb of DEFAULT_COOLBOXES) {
      const safeKey = this.sanitizeKey(cb.code);
      await set(ref(rtdb, `master_coolboxes/${safeKey}`), {
        code: cb.code,
        label: cb.label,
        status: 'ready',
        createdAt: serverTimestamp(),
      });
    }

    // 3. Seed Distributors
    for (const dist of DEFAULT_DISTRIBUTORS) {
      const safeKey = this.sanitizeKey(dist.storeLocation);
      await set(ref(rtdb, `distributors/${safeKey}`), {
        ...dist,
        updatedAt: serverTimestamp(),
      });
    }
  }
}

