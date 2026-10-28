import { useState } from 'react';
import { AuthProvider, useAuth } from './features/auth/context/AuthContext';
import { LoginPage } from './features/auth/presentation/pages/LoginPage';
import { AppLayout } from './shared/components/layout/AppLayout';
import { DashboardPage } from './features/dashboard/presentation/pages/DashboardPage';
import { HistoryPage } from './features/history/presentation/pages/HistoryPage';
import { MonitoringPage } from './features/monitoring/presentation/pages/MonitoringPage';
import { FrostScorePage } from './features/frostscore/presentation/pages/FrostScorePage';
import { RiskMapPage } from './features/risk_map/presentation/pages/RiskMapPage';
import { ReportsPage } from './features/reports/presentation/pages/ReportsPage';
import { ProfilePage } from './features/profile/presentation/pages/ProfilePage';
import { NAVIGATION_ITEMS } from './core/constants/navigation';

function AppContent() {
  const { isAuthenticated } = useAuth();
  const [activeTab, setActiveTab] = useState<string>('dashboard');

  if (!isAuthenticated) {
    return <LoginPage />;
  }

  const currentTabItem = NAVIGATION_ITEMS.find((item) => item.id === activeTab);
  const currentTabLabel = currentTabItem ? currentTabItem.label : 'Dashboard';

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
