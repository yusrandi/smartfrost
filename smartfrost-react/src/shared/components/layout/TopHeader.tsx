import React, { useState, useRef, useEffect } from 'react';
import { Bell, ChevronDown, LogOut, User as UserIcon } from 'lucide-react';
import { useAuth } from '../../../features/auth/context/AuthContext';

interface TopHeaderProps {
  currentTabLabel: string;
  parentBreadcrumb?: string;
  onNavigateProfile?: () => void;
}

export const TopHeader: React.FC<TopHeaderProps> = ({
  currentTabLabel,
  parentBreadcrumb = 'Ruang pantau',
  onNavigateProfile,
}) => {
  const { user, logout } = useAuth();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleProfileClick = () => {
    setIsDropdownOpen(false);
    if (onNavigateProfile) {
      onNavigateProfile();
    }
  };

  const handleLogout = () => {
    setIsDropdownOpen(false);
    logout();
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full items-center justify-between border-b border-slate-200/80 bg-white/95 px-6 backdrop-blur-md">
      {/* Breadcrumb Navigation */}
      <nav className="flex items-center gap-2 text-xs">
        <span className="text-slate-500 font-medium">{parentBreadcrumb}</span>
        <span className="text-slate-400 font-light">/</span>
        <span className="font-bold text-slate-900">{currentTabLabel}</span>
      </nav>

      {/* Right Controls: Data Mode Badge, Notification Bell, User Avatar */}
      <div className="flex items-center gap-4">
        {/* Demonstration Mode Pill */}
        <div className="hidden sm:inline-flex items-center gap-2 rounded-full border border-slate-200 bg-slate-50 px-3.5 py-1 text-xs font-medium text-slate-600 shadow-2xs">
          <span className="h-1.5 w-1.5 rounded-full bg-slate-500" />
          <span>Data demonstrasi</span>
        </div>

        {/* Notifications Icon Button */}
        <button
          type="button"
          aria-label="Notifikasi"
          className="relative flex h-9 w-9 items-center justify-center rounded-xl text-slate-600 hover:bg-slate-100 hover:text-slate-900 transition-colors cursor-pointer"
        >
          <Bell className="h-4 w-4" />
          <span className="absolute top-2 right-2 h-1.5 w-1.5 rounded-full bg-sky-500 ring-2 ring-white" />
        </button>

        {/* User Profile Pill with Dropdown */}
        <div className="relative" ref={dropdownRef}>
          <button
            type="button"
            onClick={() => setIsDropdownOpen(!isDropdownOpen)}
            className="flex items-center gap-3 pl-2 border-l border-slate-200 hover:opacity-90 transition-opacity cursor-pointer text-left"
          >
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-cyan-100 font-black text-xs text-cyan-800 shadow-2xs border border-cyan-200/60">
              {user?.initials || 'RH'}
            </div>
            <div className="hidden md:block text-left leading-tight">
              <div className="text-xs font-bold text-slate-900 flex items-center gap-1">
                <span>{user?.name || 'Rahmat Hidayat'}</span>
                <ChevronDown className="h-3 w-3 text-slate-400" />
              </div>
              <div className="text-[11px] text-slate-500">
                {user?.role || 'Petugas pemantauan'}
              </div>
            </div>
          </button>

          {/* User Menu Dropdown */}
          {isDropdownOpen && (
            <div className="absolute right-0 mt-2 w-56 rounded-2xl bg-white border border-slate-200/90 shadow-xl py-2 z-50 animate-in fade-in duration-150">
              <div className="px-4 py-2 border-b border-slate-100">
                <p className="text-xs font-bold text-slate-900">{user?.name}</p>
                <p className="text-[10.5px] text-slate-500 truncate">{user?.email}</p>
                <div className="mt-1 inline-flex items-center gap-1 text-[10px] font-semibold text-sky-700 bg-sky-50 px-2 py-0.5 rounded-md">
                  {user?.role}
                </div>
              </div>

              <div className="p-1 space-y-0.5">
                <button
                  type="button"
                  onClick={handleProfileClick}
                  className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-100 transition-colors text-left cursor-pointer"
                >
                  <UserIcon className="h-4 w-4 text-slate-500" />
                  <span>Lihat Profil Saya</span>
                </button>

                <button
                  type="button"
                  onClick={handleLogout}
                  className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 transition-colors text-left cursor-pointer"
                >
                  <LogOut className="h-4 w-4 text-rose-500" />
                  <span>Keluar (Logout)</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
