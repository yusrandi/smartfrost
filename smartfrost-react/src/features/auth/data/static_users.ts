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
  isAdmin?: boolean;
}

export const STATIC_USERS: StaticUser[] = [
  {
    id: 'ADM-PKP-001',
    username: 'admin',
    email: 'admin@smartfrost.id',
    password: 'password123',
    name: 'Administrator SmartFrost',
    initials: 'AD',
    role: 'Administrator Sistem',
    agency: 'Dinas Perikanan Kabupaten Pangkep',
    region: 'Kabupaten Pangkep',
    phone: '0410 000 000',
    workUnit: 'Tata Kelola & Pengelolaan Data Master',
    statusAccount: 'Aktif • Administrator Penuh',
    isAdmin: true,
    permissions: [
      'Pengelolaan penuh Master Data Komoditas Ikan',
      'Registrasi dan kontrol Armada Coolbox IoT',
      'Pengelolaan Master Distributor & Titik Dermaga / Pulau',
      'Tata Kelola Data Akun Pengguna Sistem',
      'Inisialisasi dan sinkronisasi referensi database',
    ],
  },
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
    isAdmin: false,
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
    isAdmin: false,
    permissions: [
      'Memantau distribusi dan perjalanan',
      'Melihat FrostScore dan peta risiko',
      'Membuat serta mengekspor laporan',
    ],
  },
];

export const DEFAULT_USER = STATIC_USERS[0];

