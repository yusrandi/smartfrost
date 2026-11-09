import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Trash2, 
  ShieldCheck, 
  Search, 
  AlertCircle 
} from 'lucide-react';
import { 
  MasterDataRtdbService, 
  type MasterUserItem 
} from '../../data/datasources/master_data_rtdb_service';

export const MasterUsersPage: React.FC = () => {
  const [users, setUsers] = useState<MasterUserItem[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [alertNotice, setAlertNotice] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  useEffect(() => {
    const unsub = MasterDataRtdbService.subscribeUsers(setUsers);
    return () => unsub();
  }, []);

  const showAlert = (type: 'success' | 'error', message: string) => {
    setAlertNotice({ type, message });
    setTimeout(() => setAlertNotice(null), 4000);
  };

  const handleDeleteUser = async (id: string, email: string) => {
    if (!window.confirm(`Yakin ingin menghapus data akun "${email}" dari Realtime Database?`)) return;
    try {
      await MasterDataRtdbService.deleteUser(id);
      showAlert('success', `Pengguna "${email}" berhasil dihapus.`);
    } catch (err: unknown) {
      showAlert('error', err instanceof Error ? err.message : 'Gagal menghapus pengguna');
    }
  };

  const filteredUsers = users.filter((u) =>
    u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    u.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (u.storeLocation && u.storeLocation.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  return (
    <div className="space-y-6 select-none animate-in fade-in duration-150">
      {/* Top Banner Header */}
      <div className="rounded-2xl bg-gradient-to-r from-[#0F223A] via-[#153457] to-[#0A4E7A] p-6 text-white shadow-md border border-white/10 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1.5">
            <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-400/20 px-2.5 py-0.5 text-[11px] font-extrabold uppercase tracking-wider text-amber-300 border border-amber-400/30">
              <ShieldCheck className="h-3.5 w-3.5" />
              Master Akun & Pengguna
            </span>
            <span className="text-xs text-sky-200">• Realtime Database (users)</span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-white flex items-center gap-2.5">
            <Users className="h-6 w-6 text-cyan-400" />
            Master Pengguna Sistem
          </h1>
          <p className="text-xs text-slate-300 mt-1 max-w-2xl leading-relaxed">
            Daftar seluruh profil pengguna sistem yang tersimpan pada node <code>users/</code> dengan key email unik untuk sinkronisasi profil, otoritas, dan basis lokasi pengiriman.
          </p>
        </div>

        <div className="flex items-center gap-2.5 self-start md:self-center">
          <div className="px-4 py-2 rounded-xl bg-white/10 border border-white/15 text-right">
            <div className="text-[10px] text-slate-300 uppercase font-bold tracking-wider">Total Akun Terdaftar</div>
            <div className="text-lg font-black text-white">{users.length} Pengguna</div>
          </div>
        </div>
      </div>

      {/* Alert Notice */}
      {alertNotice && (
        <div
          className={`p-3.5 rounded-xl text-xs font-semibold flex items-center gap-2.5 border transition-all ${
            alertNotice.type === 'success'
              ? 'bg-emerald-50 border-emerald-200 text-emerald-800'
              : 'bg-rose-50 border-rose-200 text-rose-800'
          }`}
        >
          <AlertCircle className="h-4 w-4 shrink-0" />
          <span>{alertNotice.message}</span>
        </div>
      )}

      {/* Table Container */}
      <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
          <div>
            <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
              <Users className="h-4 w-4 text-cyan-600" />
              Daftar Akun Pengguna Aktif
            </h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Data terindeks menggunakan key email yang telah disanitasi.
            </p>
          </div>

          {/* Search Bar */}
          <div className="relative w-full sm:w-64">
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Cari nama, email, lokasi..."
              className="w-full pl-8 pr-3 py-1.5 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
            />
            <Search className="h-3.5 w-3.5 text-slate-400 absolute left-2.5 top-2.5 pointer-events-none" />
          </div>
        </div>

        {filteredUsers.length === 0 ? (
          <div className="py-12 text-center text-slate-400 text-xs">
            Belum ada akun pengguna yang terdaftar atau cocok dengan pencarian.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-slate-100 text-slate-400 font-semibold uppercase tracking-wider text-[10px]">
                  <th className="py-2.5 px-3">Nama Pengguna</th>
                  <th className="py-2.5 px-3">Email Akun</th>
                  <th className="py-2.5 px-3">Peran (Role)</th>
                  <th className="py-2.5 px-3">Basis Dermaga / Lokasi</th>
                  <th className="py-2.5 px-3">Kontak Telepon</th>
                  <th className="py-2.5 px-3 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium">
                {filteredUsers.map((u) => (
                  <tr key={u.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-3 px-3 font-bold text-slate-800">
                      {u.name}
                    </td>
                    <td className="py-3 px-3 font-mono text-slate-600">
                      {u.email}
                    </td>
                    <td className="py-3 px-3">
                      <span className="inline-block px-2 py-0.5 rounded-full text-[10px] font-bold bg-sky-50 text-sky-700 border border-sky-200/60">
                        {u.accessRoleLabel || u.role || 'Mitra Pengirim'}
                      </span>
                    </td>
                    <td className="py-3 px-3 text-slate-600">
                      {u.storeLocation || u.location || '-'}
                    </td>
                    <td className="py-3 px-3 text-slate-500 font-mono text-[11px]">
                      {u.phoneNumber || '-'}
                    </td>
                    <td className="py-3 px-3 text-right">
                      <button
                        type="button"
                        onClick={() => handleDeleteUser(u.id, u.email)}
                        className="text-slate-400 hover:text-rose-600 p-1.5 rounded-lg hover:bg-rose-50 transition-colors cursor-pointer"
                        title="Hapus pengguna dari database"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

