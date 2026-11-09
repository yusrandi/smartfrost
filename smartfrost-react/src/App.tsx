import { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './features/auth/context/AuthContext';
import { LoginPage } from './features/auth/presentation/pages/LoginPage';
import { AppLayout } from './shared/components/layout/AppLayout';
import { DashboardPage } from './features/dashboard/presentation/pages/DashboardPage';
import { HistoryPage } from './features/history/presentation/pages/HistoryPage';
import { MonitoringPage } from './features/monitoring/presentation/pages/MonitoringPage';
import { FrostScorePage } from './features/frostscore/presentation/pages/FrostScorePage';
import { RiskMapPage } from './features/risk_map/presentation/pages/RiskMapPage';
import { ReportsPage } from './features/reports/presentation/pages/ReportsPage';
import { MasterFishesPage } from './features/master_data/presentation/pages/MasterFishesPage';
import { MasterCoolboxesPage } from './features/master_data/presentation/pages/MasterCoolboxesPage';
import { MasterDistributorsPage } from './features/master_data/presentation/pages/MasterDistributorsPage';
import { MasterUsersPage } from './features/master_data/presentation/pages/MasterUsersPage';
import { ProfilePage } from './features/profile/presentation/pages/ProfilePage';
import { NAVIGATION_ITEMS } from './core/constants/navigation';

const ADMIN_TABS = [
  'master_fishes',
  'master_coolboxes',
  'master_distributors',
  'master_users',
  'profile',
];

const OPERATOR_TABS = [
  'dashboard',
  'history',
  'monitoring',
  'frostscore',
  'risk_map',
  'reports',
  'profile',
];

function AppContent() {
  const { user, isAuthenticated } = useAuth();
  const isAdmin = Boolean(user?.isAdmin || user?.role?.toLowerCase().includes('admin'));

  const [activeTab, setActiveTab] = useState<string>(() => {
    return isAdmin ? 'master_fishes' : 'dashboard';
  });

  // Pastikan admin selalu fokus pada menu master_data atau profile, dan operator pada menu operasional
  useEffect(() => {
    if (isAdmin) {
      if (!ADMIN_TABS.includes(activeTab)) {
        setActiveTab('master_fishes');
      }
    } else {
      if (!OPERATOR_TABS.includes(activeTab)) {
        setActiveTab('dashboard');
      }
    }
  }, [user, isAdmin, activeTab]);

  if (!isAuthenticated) {
    return <LoginPage />;
  }

  const currentTabItem = NAVIGATION_ITEMS.find((item) => item.id === activeTab);
  const currentTabLabel = currentTabItem ? currentTabItem.label : (isAdmin ? 'Master Ikan' : 'Dashboard');

  return (
    <AppLayout
      activeTab={activeTab}
      onTabChange={setActiveTab}
      currentTabLabel={currentTabLabel}
    >
      {activeTab === 'dashboard' ? (
        <DashboardPage />
      ) : activeTab === 'history' ? (
        <HistoryPage />
      ) : activeTab === 'monitoring' ? (
        <MonitoringPage />
      ) : activeTab === 'frostscore' ? (
        <FrostScorePage />
      ) : activeTab === 'risk_map' ? (
        <RiskMapPage />
      ) : activeTab === 'reports' ? (
        <ReportsPage />
      ) : activeTab === 'master_fishes' ? (
        <MasterFishesPage />
      ) : activeTab === 'master_coolboxes' ? (
        <MasterCoolboxesPage />
      ) : activeTab === 'master_distributors' ? (
        <MasterDistributorsPage />
      ) : activeTab === 'master_users' ? (
        <MasterUsersPage />
      ) : activeTab === 'profile' ? (
        <ProfilePage />
      ) : (
        <div className="rounded-2xl border border-slate-200/80 bg-white p-12 text-center text-slate-500 shadow-xs">
          <h2 className="text-base font-bold text-slate-800">{currentTabLabel}</h2>
          <p className="text-xs text-slate-400 mt-1">
            Modul {currentTabLabel} telah terdaftar pada routing clean architecture dan siap diimplementasikan.
          </p>
        </div>
      )}
    </AppLayout>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}
