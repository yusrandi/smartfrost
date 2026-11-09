import type { NavigationItem, UserProfile } from '../types/navigation';

export const NAVIGATION_ITEMS: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    iconName: 'dashboard',
    operatorOnly: true,
  },
  {
    id: 'history',
    label: 'Riwayat Distribusi',
    iconName: 'history',
    operatorOnly: true,
  },
  {
    id: 'monitoring',
    label: 'Monitoring Perjalanan',
    iconName: 'monitoring',
    operatorOnly: true,
  },
  {
    id: 'frostscore',
    label: 'FrostScore',
    iconName: 'frostscore',
    operatorOnly: true,
  },
  {
    id: 'risk_map',
    label: 'Peta Risiko',
    iconName: 'riskMap',
    operatorOnly: true,
  },
  {
    id: 'reports',
    label: 'Laporan',
    iconName: 'reports',
    operatorOnly: true,
  },
  {
    id: 'master_fishes',
    label: 'Master Ikan',
    iconName: 'fish',
    adminOnly: true,
  },
  {
    id: 'master_coolboxes',
    label: 'Master Coolbox',
    iconName: 'box',
    adminOnly: true,
  },
  {
    id: 'master_distributors',
    label: 'Master Distributor',
    iconName: 'mapPin',
    adminOnly: true,
  },
  {
    id: 'master_users',
    label: 'Master Pengguna',
    iconName: 'users',
    adminOnly: true,
  },
  {
    id: 'profile',
    label: 'Profil',
    iconName: 'profile',
  },
];

export const CURRENT_USER: UserProfile = {
  name: 'Rahmat Hidayat',
  initials: 'RH',
  role: 'Petugas pemantauan',
  agency: 'Dinas Perikanan',
  region: 'Kabupaten Pangkep',
};

export const APP_METADATA = {
  name: 'SMART-FROST',
  tagline: 'RANTAI DINGIN • PANGKEP',
  version: 'v1.0 Data demonstrasi',
  sidebarNote: 'Ruang pantau distribusi antarpulau. Hanya baca dan pelaporan.',
  footerCopyright: '© 2026 SMART-FROST - Kabupaten Pangkep',
  footerDisclaimer: 'Data contoh untuk demonstrasi antarmuka',
};
