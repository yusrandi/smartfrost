export interface NavigationItem {
  id: string;
  label: string;
  iconName: 'dashboard' | 'history' | 'monitoring' | 'frostscore' | 'riskMap' | 'reports' | 'profile';
  badge?: string;
  path?: string;
}

export interface UserProfile {
  name: string;
  initials: string;
  role: string;
  agency: string;
  region: string;
}
