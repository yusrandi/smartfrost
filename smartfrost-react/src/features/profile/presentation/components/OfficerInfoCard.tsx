import React, { useEffect, useState } from 'react';
import { Check, ChevronDown, Lock, Mail, Phone } from 'lucide-react';
import { useAuth } from '../../../auth/context/AuthContext';

interface OfficerInfoCardProps {
  onOpenChangePassword: () => void;
}

export const OfficerInfoCard: React.FC<OfficerInfoCardProps> = ({ onOpenChangePassword }) => {
  const { user, updateProfile } = useAuth();
  const [fullName, setFullName] = useState(user?.name || 'Rahmat Hidayat');
  const [email, setEmail] = useState(user?.email || 'rahmat@dinas-contoh.id');
  const [phone, setPhone] = useState(user?.phone || '0410 000 003');
  const [workUnit, setWorkUnit] = useState(user?.workUnit || 'Pemantauan Distribusi Perikanan');
  const [savedSuccess, setSavedSuccess] = useState(false);

  useEffect(() => {
    if (user) {
      setFullName(user.name);
      setEmail(user.email);
      setPhone(user.phone);
      setWorkUnit(user.workUnit);
    }
  }, [user]);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile({
      name: fullName,
      email: email,
      phone: phone,
      workUnit: workUnit,
    });
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 2500);
  };

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-6 sm:p-7 shadow-2xs">
      <div className="flex items-center justify-between border-b border-slate-100 pb-4">
        <h3 className="text-base font-bold text-slate-900">Informasi petugas</h3>
        {savedSuccess && (
          <span className="text-xs font-semibold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200 animate-in fade-in">
            Profil berhasil disimpan
          </span>
        )}
      </div>

      <form onSubmit={handleSave} className="mt-5 space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* Nama Lengkap */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1.5">
              Nama lengkap
            </label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full rounded-xl bg-white border border-slate-200/90 px-3.5 py-2.5 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>

          {/* Email Dinas */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1.5">
              Email dinas
            </label>
            <div className="relative">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full rounded-xl bg-white border border-slate-200/90 px-3.5 py-2.5 pr-9 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
              />
              <Mail className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
            </div>
          </div>

          {/* Nomor Telepon */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1.5">
              Nomor telepon
            </label>
            <div className="relative">
              <input
                type="text"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full rounded-xl bg-white border border-slate-200/90 px-3.5 py-2.5 pr-9 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
              />
              <Phone className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
            </div>
          </div>

          {/* Unit Kerja */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1.5">
              Unit kerja
            </label>
            <input
              type="text"
              value={workUnit}
              onChange={(e) => setWorkUnit(e.target.value)}
              className="w-full rounded-xl bg-white border border-slate-200/90 px-3.5 py-2.5 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>
        </div>

        {/* Wilayah Pemantauan */}
        <div>
          <label className="block text-xs font-bold text-slate-700 mb-1.5">
            Wilayah pemantauan
          </label>
          <div className="relative">
            <select
              disabled
              value={`${user?.region || 'Kabupaten Pangkep'} · seluruh wilayah terdaftar`}
              className="w-full appearance-none rounded-xl bg-slate-50 border border-slate-200/90 px-3.5 py-2.5 pr-9 text-xs font-semibold text-slate-700 shadow-2xs cursor-not-allowed"
            >
              <option value={`${user?.region || 'Kabupaten Pangkep'} · seluruh wilayah terdaftar`}>
                {user?.region || 'Kabupaten Pangkep'} &bull; seluruh wilayah terdaftar
              </option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
          <p className="text-[11px] text-slate-400 mt-1.5">
            Wilayah akses ditetapkan administrator.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="pt-2 flex flex-col sm:flex-row items-center gap-3">
          <button
            type="submit"
            className="w-full sm:flex-1 inline-flex items-center justify-center gap-2 py-3 px-6 rounded-xl bg-[#0284C7] hover:bg-sky-700 text-white font-extrabold text-xs sm:text-sm shadow-xs transition-all cursor-pointer"
          >
            <Check className="h-4 w-4 stroke-[3]" />
            <span>Simpan profil</span>
          </button>

          <button
            type="button"
            onClick={onOpenChangePassword}
            className="w-full sm:flex-1 inline-flex items-center justify-center gap-2 py-3 px-6 rounded-xl bg-white hover:bg-slate-50 border border-slate-200/90 text-slate-800 font-bold text-xs sm:text-sm shadow-2xs transition-all cursor-pointer"
          >
            <Lock className="h-3.5 w-3.5 text-slate-600" />
            <span>Ubah kata sandi</span>
          </button>
        </div>
      </form>
    </div>
  );
};
