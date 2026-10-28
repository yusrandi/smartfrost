import React from 'react';
import { useAuth } from '../../../auth/context/AuthContext';

export const ProfileIdentityCard: React.FC = () => {
  const { user } = useAuth();

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-6 shadow-2xs">
      {/* Avatar & Basic Info */}
      <div className="flex flex-col items-center text-center">
        <div className="h-24 w-24 rounded-full bg-sky-100 text-[#0284C7] text-2xl font-black flex items-center justify-center shadow-inner tracking-wider">
          {user?.initials || 'RH'}
        </div>
        <h2 className="text-xl font-black text-slate-900 mt-4 tracking-tight">
          {user?.name || 'Rahmat Hidayat'}
        </h2>
        <p className="text-xs text-slate-500 mt-0.5 font-medium">
          {user?.agency || 'Dinas Perikanan Kabupaten Pangkep'}
        </p>

        <div className="mt-3 inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-sky-50 text-[#0284C7] text-xs font-bold border border-sky-200/70">
          <span className="h-1.5 w-1.5 rounded-full bg-[#0284C7]" />
          <span>{user?.role || 'Petugas pemantauan'}</span>
        </div>
      </div>

      {/* Divider */}
      <div className="border-t border-slate-100 my-6" />

      {/* Meta Key-Values */}
      <div className="space-y-3.5 text-xs">
        <div className="flex items-center justify-between">
          <span className="text-slate-500 font-medium">ID petugas</span>
          <span className="font-extrabold text-slate-900">{user?.id || 'DNS-PKP-003'}</span>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-slate-500 font-medium">Wilayah akses</span>
          <span className="font-extrabold text-slate-900">{user?.region || 'Kabupaten Pangkep'}</span>
        </div>

        <div className="flex items-center justify-between">
          <span className="text-slate-500 font-medium">Status akun</span>
          <span className="font-extrabold text-slate-900">
            {user?.statusAccount || 'Aktif • email terverifikasi'}
          </span>
        </div>
      </div>
    </div>
  );
};
