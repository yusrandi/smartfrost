import React, { useState, useEffect } from 'react';
import { 
  MapPin, 
  Plus, 
  Trash2, 
  ShieldCheck, 
  Search, 
  AlertCircle 
} from 'lucide-react';
import { 
  MasterDataRtdbService, 
  type MasterDistributorItem 
} from '../../data/datasources/master_data_rtdb_service';

export const MasterDistributorsPage: React.FC = () => {
  const [distributors, setDistributors] = useState<MasterDistributorItem[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [alertNotice, setAlertNotice] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const [newDistributor, setNewDistributor] = useState({
    name: '',
    storeLocation: '',
    latitude: '',
    longitude: '',
    email: '',
    organization: '',
  });

  useEffect(() => {
    const unsub = MasterDataRtdbService.subscribeDistributors(setDistributors);
    return () => unsub();
  }, []);

  const showAlert = (type: 'success' | 'error', message: string) => {
    setAlertNotice({ type, message });
    setTimeout(() => setAlertNotice(null), 4000);
  };

  const handleAddDistributor = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDistributor.name.trim() || !newDistributor.storeLocation.trim()) {
      showAlert('error', 'Nama mitra dan dermaga/lokasi wajib diisi');
      return;
    }
    const lat = parseFloat(newDistributor.latitude);
    const lng = parseFloat(newDistributor.longitude);
    if (isNaN(lat) || isNaN(lng)) {
      showAlert('error', 'Koordinat Latitude dan Longitude harus berupa angka yang valid');
      return;
    }

    setIsLoading(true);
    try {
      await MasterDataRtdbService.addDistributor({
        name: newDistributor.name,
        storeLocation: newDistributor.storeLocation,
        latitude: lat,
        longitude: lng,
        email: newDistributor.email,
        organization: newDistributor.organization,
      });
      setNewDistributor({
        name: '',
        storeLocation: '',
        latitude: '',
        longitude: '',
        email: '',
        organization: '',
      });
      showAlert('success', `Distributor "${newDistributor.name}" berhasil ditambahkan.`);
    } catch (err: unknown) {
      showAlert('error', err instanceof Error ? err.message : 'Gagal menambahkan distributor');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDeleteDistributor = async (id: string, name: string) => {
    if (!window.confirm(`Yakin ingin menghapus distributor "${name}"?`)) return;
    try {
      await MasterDataRtdbService.deleteDistributor(id);
      showAlert('success', `Distributor "${name}" berhasil dihapus.`);
    } catch (err: unknown) {
      showAlert('error', err instanceof Error ? err.message : 'Gagal menghapus');
    }
  };

  const filteredDistributors = distributors.filter((d) =>
    d.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    d.storeLocation.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (d.email && d.email.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  return (
    <div className="space-y-6 select-none animate-in fade-in duration-150">
      {/* Top Banner Header */}
      <div className="rounded-2xl bg-gradient-to-r from-[#0F223A] via-[#153457] to-[#0A4E7A] p-6 text-white shadow-md border border-white/10 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1.5">
            <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-400/20 px-2.5 py-0.5 text-[11px] font-extrabold uppercase tracking-wider text-amber-300 border border-amber-400/30">
              <ShieldCheck className="h-3.5 w-3.5" />
              Master Geospasial & Logistik
            </span>
            <span className="text-xs text-sky-200">• Realtime Database (distributors)</span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-white flex items-center gap-2.5">
            <MapPin className="h-6 w-6 text-cyan-400" />
            Master Distributor & Dermaga
          </h1>
          <p className="text-xs text-slate-300 mt-1 max-w-2xl leading-relaxed">
            Kelola data mitra distributor perikanan, lokasi dermaga asal/tujuan di kepulauan Pangkep, dan titik koordinat GPS untuk pelacakan rute laut.
          </p>
        </div>

        <div className="flex items-center gap-2.5 self-start md:self-center">
          <div className="px-4 py-2 rounded-xl bg-white/10 border border-white/15 text-right">
            <div className="text-[10px] text-slate-300 uppercase font-bold tracking-wider">Titik Distribusi</div>
            <div className="text-lg font-black text-white">{distributors.length} Titik Aktif</div>
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

      {/* Main Grid: Form Left, List Right */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Form Add Distributor */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2 mb-1">
              <Plus className="h-4 w-4 text-sky-600" />
              Tambah Mitra Distributor
            </h2>
            <p className="text-[11.5px] text-slate-500 mb-4 leading-relaxed">
              Daftarkan dermaga atau pulau baru beserta titik koordinat GPS laut.
            </p>
            <form onSubmit={handleAddDistributor} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Nama Mitra Distributor
                </label>
                <input
                  type="text"
                  required
                  value={newDistributor.name}
                  onChange={(e) => setNewDistributor({ ...newDistributor, name: e.target.value })}
                  placeholder="Contoh: Dermaga Maccini Baji"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Nama Dermaga / Pulau (Store Location)
                </label>
                <input
                  type="text"
                  required
                  value={newDistributor.storeLocation}
                  onChange={(e) => setNewDistributor({ ...newDistributor, storeLocation: e.target.value })}
                  placeholder="Contoh: Pulau Karanrang"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[11px] font-bold text-slate-700 mb-1">
                    Latitude
                  </label>
                  <input
                    type="number"
                    step="any"
                    required
                    value={newDistributor.latitude}
                    onChange={(e) => setNewDistributor({ ...newDistributor, latitude: e.target.value })}
                    placeholder="-4.7740"
                    className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-mono font-medium"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-700 mb-1">
                    Longitude
                  </label>
                  <input
                    type="number"
                    step="any"
                    required
                    value={newDistributor.longitude}
                    onChange={(e) => setNewDistributor({ ...newDistributor, longitude: e.target.value })}
                    placeholder="119.4936"
                    className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-mono font-medium"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Email Distributor (Opsional)
                </label>
                <input
                  type="email"
                  value={newDistributor.email}
                  onChange={(e) => setNewDistributor({ ...newDistributor, email: e.target.value })}
                  placeholder="nama@smartfrost.id"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
                />
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-2.5 px-4 rounded-xl bg-[#0284C7] hover:bg-sky-700 text-white font-bold text-xs shadow-xs transition-colors flex items-center justify-center gap-2 cursor-pointer disabled:opacity-60"
              >
                <Plus className="h-4 w-4" />
                <span>Simpan Distributor</span>
              </button>
            </form>
          </div>
        </div>

        {/* List Distributors */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
              <div>
                <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <MapPin className="h-4 w-4 text-cyan-600" />
                  Daftar Master Distributor & Dermaga
                </h2>
                <p className="text-xs text-slate-400 mt-0.5">
                  Tersinkronisasi realtime dengan tabel <code>distributors</code>.
                </p>
              </div>

              {/* Search Bar */}
              <div className="relative w-full sm:w-60">
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Cari distributor/dermaga..."
                  className="w-full pl-8 pr-3 py-1.5 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
                />
                <Search className="h-3.5 w-3.5 text-slate-400 absolute left-2.5 top-2.5 pointer-events-none" />
              </div>
            </div>

            {filteredDistributors.length === 0 ? (
              <div className="py-12 text-center text-slate-400 text-xs">
                Tidak ada data distributor yang cocok.
              </div>
            ) : (
              <div className="space-y-2.5">
                {filteredDistributors.map((dist) => (
                  <div
                    key={dist.id}
                    className="p-3.5 rounded-xl border border-slate-200/90 hover:border-sky-300 hover:bg-sky-50/20 transition-all flex items-center justify-between group"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="h-9 w-9 rounded-xl bg-sky-100 text-[#0284C7] flex items-center justify-center shrink-0 border border-sky-200/60">
                        <MapPin className="h-4 w-4" />
                      </div>
                      <div className="min-w-0">
                        <div className="text-xs font-bold text-slate-900 flex items-center gap-2 truncate">
                          <span>{dist.name}</span>
                          <span className="text-[10px] font-semibold text-sky-700 bg-sky-50 px-2 py-0.2 rounded-md">
                            {dist.storeLocation}
                          </span>
                        </div>
                        <div className="text-[11px] text-slate-500 font-mono mt-0.5">
                          GPS: {dist.latitude.toFixed(4)}, {dist.longitude.toFixed(4)} • {dist.email || 'Tanpa email'}
                        </div>
                      </div>
                    </div>
                    <button
                      type="button"
                      onClick={() => handleDeleteDistributor(dist.id, dist.name)}
                      className="text-slate-400 hover:text-rose-600 p-1.5 rounded-lg hover:bg-rose-50 transition-colors opacity-70 group-hover:opacity-100 cursor-pointer"
                      title="Hapus distributor"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

