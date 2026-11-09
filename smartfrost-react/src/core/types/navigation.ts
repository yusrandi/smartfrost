export interface NavigationItem {
  id: string;
  label: string;
  iconName:
    | 'dashboard'
    | 'history'
    | 'monitoring'
    | 'frostscore'
    | 'riskMap'
    | 'reports'
    | 'profile'
    | 'master_data'
    | 'fish'
    | 'box'
    | 'mapPin'
    | 'users';
  badge?: string;
  path?: string;
  adminOnly?: boolean;
  operatorOnly?: boolean;
}

export interface UserProfile {
  name: string;
  initials: string;
  role: string;
  agency: string;
  region: string;
}
