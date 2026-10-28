import React, { useState } from 'react';
import { RefreshCw } from 'lucide-react';
import { ProfileIdentityCard } from '../components/ProfileIdentityCard';
import { AccountPermissionsCard } from '../components/AccountPermissionsCard';
import { OfficerInfoCard } from '../components/OfficerInfoCard';
import { MonitoringPreferencesCard } from '../components/MonitoringPreferencesCard';
import { ChangePasswordModal } from '../components/ChangePasswordModal';

export const ProfilePage: React.FC = () => {
  const [isChangePasswordOpen, setIsChangePasswordOpen] = useState(false);

  return (
    <div className="space-y-6">
      {/* Title & Synchronization Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
            Profil & kewenangan akun
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Identitas petugas, preferensi pemantauan, dan batas akses platform.
          </p>
        </div>

        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">
            Kamis, 22 Oktober 2026 - WITA
          </div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className="h-3 w-3 text-teal-600" />
            <span>Tersinkron &bull; 22 Okt 2026, 10.42 WITA</span>
          </div>
        </div>
      </div>

      {/* Main Grid Layout (Left: 1 col, Right: 2 cols on lg) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
        {/* Left Column */}
        <div className="space-y-6 lg:col-span-1">
          <ProfileIdentityCard />
          <AccountPermissionsCard />
        </div>

        {/* Right Column */}
        <div className="space-y-6 lg:col-span-2">
          <OfficerInfoCard
            onOpenChangePassword={() => setIsChangePasswordOpen(true)}
          />
          <MonitoringPreferencesCard />
        </div>
      </div>

      {/* Change Password Dialog */}
      <ChangePasswordModal
        isOpen={isChangePasswordOpen}
        onClose={() => setIsChangePasswordOpen(false)}
      />

      {/* Bottom Footer Notice */}
      {/* <div className="flex flex-wrap items-center justify-between gap-2 text-xs text-slate-400 pt-2 pb-6">
        <div>&copy; 2026 SMART-FROST &bull; Kabupaten Pangkep</div>
        <div>Data contoh untuk demonstrasi antarmuka</div>
      </div> */}
    </div>
  );
};
