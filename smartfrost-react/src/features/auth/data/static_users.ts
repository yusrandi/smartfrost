export interface StaticUser {
  id: string;
  username: string;
  email: string;
  password: string;
  name: string;
  initials: string;
  role: string;
  agency: string;
  region: string;
  phone: string;
  workUnit: string;
  statusAccount: string;
  permissions: string[];
}

export const STATIC_USERS: StaticUser[] = [
  {
    id: 'DNS-PKP-003',
    username: 'rahmat',
    email: 'rahmat@dinas-contoh.id',
    password: 'password123',
    name: 'Rahmat Hidayat',
    initials: 'RH',
    role: 'Petugas pemantauan',
    agency: 'Dinas Perikanan Kabupaten Pangkep',
    region: 'Kabupaten Pangkep',
    phone: '0410 000 003',
    workUnit: 'Pemantauan Distribusi Perikanan',
    statusAccount: 'Aktif • email terverifikasi',
    permissions: [
      'Memantau distribusi dan perjalanan',
      'Melihat FrostScore dan peta risiko',
      'Membuat serta mengekspor laporan',
    ],
  },
  {
    id: 'DNS-PKP-001',
    username: 'andi',
    email: 'andi@dinas-contoh.id',
    password: 'password123',
    name: 'Andi Baso Tenri',
    initials: 'AB',
    role: 'Koordinator Mutu Distribusi',
    agency: 'Dinas Perikanan Kabupaten Pangkep',
    region: 'Kabupaten Pangkep',
    phone: '0410 000 001',
    workUnit: 'Seksi Pengawasan & Karantina Ikan',
    statusAccount: 'Aktif • email terverifikasi',
    permissions: [
      'Memantau distribusi dan perjalanan',
      'Melihat FrostScore dan peta risiko',
      'Membuat serta mengekspor laporan',
    ],
  },
];

export const DEFAULT_USER = STATIC_USERS[0];

