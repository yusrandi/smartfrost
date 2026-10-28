import React from 'react';
import { 
  LayoutGrid, 
  History, 
  Activity, 
  Gauge, 
  Map as MapIcon, 
  FileText, 
  User,
  LogOut
} from 'lucide-react';
import { NAVIGATION_ITEMS, APP_METADATA } from '../../../core/constants/navigation';
import { useAuth } from '../../../features/auth/context/AuthContext';

interface SidebarProps {
  activeTab: string;
  onTabChange: (tabId: string) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ activeTab, onTabChange }) => {
  const { user, logout } = useAuth();

  const getIcon = (iconName: string, isActive: boolean) => {
    const iconClass = `h-4 w-4 shrink-0 transition-colors ${
      isActive ? 'text-white' : 'text-slate-400 group-hover:text-white'
    }`;

    switch (iconName) {
      case 'dashboard':
        return <LayoutGrid className={iconClass} />;
      case 'history':
        return <History className={iconClass} />;
      case 'monitoring':
        return <Activity className={iconClass} />;
      case 'frostscore':
        return <Gauge className={iconClass} />;
      case 'riskMap':
        return <MapIcon className={iconClass} />;
      case 'reports':
        return <FileText className={iconClass} />;
      case 'profile':
        return <User className={iconClass} />;
      default:
        return <LayoutGrid className={iconClass} />;
    }
  };

  return (
    <aside className="w-64 shrink-0 bg-[#0F223A] border-r border-slate-800/80 flex flex-col justify-between min-h-screen text-slate-200 select-none">
      {/* Upper Area: Logo, Organization Card, Navigation Links */}
      <div className="p-4 space-y-5">
        {/* Brand Logo Header */}
        <div className="flex items-center gap-3 px-2 pt-2">
          {/* Custom Cyan Hexagon / Radial Frost Icon */}
          <div className="h-9 w-9 rounded-xl bg-gradient-to-tr from-cyan-600 to-sky-400 flex items-center justify-center shadow-md shadow-cyan-500/20 text-white font-black text-sm">
            <svg
              className="h-5 w-5 text-white"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="12" y1="2" x2="12" y2="22" />
              <line x1="2" y1="12" x2="22" y2="12" />
              <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
              <line x1="19.07" y1="4.93" x2="4.93" y2="19.07" />
              <circle cx="12" cy="12" r="3" fill="#0EA5E9" />
            </svg>
          </div>

          <div>
            <div className="text-[15px] font-black tracking-wider text-white leading-tight">
              {APP_METADATA.name}
            </div>
            <div className="text-[9.5px] font-bold tracking-widest text-cyan-400 uppercase">
              {APP_METADATA.tagline}
            </div>
          </div>
        </div>

        {/* Dinas Perikanan Organization Card */}
        <div className="rounded-xl bg-[#172E4C] border border-white/5 p-3.5 space-y-2.5">
          <div>
            <div className="text-xs font-bold text-white tracking-tight">
              {user?.agency || 'Dinas Perikanan Kabupaten Pangkep'}
            </div>
            <div className="text-[11px] text-slate-400">
              {user?.region || 'Kabupaten Pangkep'}
            </div>
          </div>

          <div className="inline-flex items-center gap-1.5 rounded-full bg-white px-2.5 py-0.5 shadow-sm">
            <span className="h-1.5 w-1.5 rounded-full bg-teal-600 animate-pulse" />
            <span className="text-[10px] font-bold text-slate-800">
              {user?.role || 'Akses pemantauan'}
            </span>
          </div>
        </div>

        {/* Navigation Menu */}
        <nav className="space-y-1 pt-1">
          {NAVIGATION_ITEMS.map((item) => {
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                type="button"
                onClick={() => onTabChange(item.id)}
                className={`group w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-semibold transition-all duration-150 text-left cursor-pointer ${
                  isActive
                    ? 'bg-[#1890C7] text-white shadow-md shadow-sky-900/20 font-bold'
                    : 'text-slate-300 hover:text-white hover:bg-white/[0.06]'
                }`}
              >
                {getIcon(item.iconName, isActive)}
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>
      </div>

      {/* Sidebar Footer Notes & Logout */}
      <div className="p-4 border-t border-slate-800/60 space-y-3">
        <button
          type="button"
          onClick={logout}
          className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-rose-300 hover:text-rose-100 hover:bg-rose-500/10 transition-colors cursor-pointer"
        >
          <LogOut className="h-4 w-4 text-rose-400" />
          <span>Keluar dari Akun</span>
        </button>

        <div className="text-[11px] text-slate-400 space-y-1 leading-relaxed px-1">
          <p>{APP_METADATA.sidebarNote}</p>
          <p className="text-[10px] text-slate-500 font-mono tracking-tight">
            {APP_METADATA.name} • {APP_METADATA.version}
          </p>
        </div>
      </div>
    </aside>
  );
};
