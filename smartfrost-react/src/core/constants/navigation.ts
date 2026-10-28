import type { NavigationItem, UserProfile } from '../types/navigation';

export const NAVIGATION_ITEMS: NavigationItem[] = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    iconName: 'dashboard',
  },
  {
    id: 'history',
    label: 'Riwayat Distribusi',
    iconName: 'history',
  },
  {
    id: 'monitoring',
    label: 'Monitoring Perjalanan',
    iconName: 'monitoring',
  },
  {
    id: 'frostscore',
    label: 'FrostScore',
    iconName: 'frostscore',
  },
  {
    id: 'risk_map',
    label: 'Peta Risiko',
    iconName: 'riskMap',
  },
  {
    id: 'reports',
    label: 'Laporan',
    iconName: 'reports',
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
