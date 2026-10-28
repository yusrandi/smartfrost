import React from 'react';
import { Check } from 'lucide-react';
import { useAuth } from '../../../auth/context/AuthContext';

export const AccountPermissionsCard: React.FC = () => {
  const { user } = useAuth();

  const permissions = user?.permissions && user.permissions.length > 0
    ? user.permissions
    : [
        'Memantau distribusi dan perjalanan',
        'Melihat FrostScore dan peta risiko',
        'Membuat serta mengekspor laporan',
      ];

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-6 shadow-2xs">
      <h3 className="text-base font-bold text-slate-900">Kewenangan Anda</h3>

      <ul className="mt-4 space-y-3">
        {permissions.map((perm) => (
          <li key={perm} className="flex items-center gap-2.5 text-xs font-semibold text-slate-700">
            <span className="h-4 w-4 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0 border border-emerald-200/70">
              <Check className="h-2.5 w-2.5 stroke-[3]" />
            </span>
            <span>{perm}</span>
          </li>
        ))}
      </ul>

      <div className="mt-5 pt-4 border-t border-slate-100 text-[11.5px] leading-relaxed text-slate-400 font-medium">
        Tidak dapat mengirim ikan, menerima atau menolak batch, maupun mengubah hasil inspeksi.
      </div>
    </div>
  );
};
