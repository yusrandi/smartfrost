import React, { useState, useEffect } from 'react';
import { 
  Box, 
  Plus, 
  Trash2, 
  ShieldCheck, 
  Search, 
  AlertCircle,
  QrCode
} from 'lucide-react';
import { 
  MasterDataRtdbService, 
  type MasterCoolboxItem 
} from '../../data/datasources/master_data_rtdb_service';
import { CoolboxQrModal } from '../components/CoolboxQrModal';

export const MasterCoolboxesPage: React.FC = () => {
  const [coolboxes, setCoolboxes] = useState<MasterCoolboxItem[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [newCoolboxCode, setNewCoolboxCode] = useState('');
  const [newCoolboxLabel, setNewCoolboxLabel] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [alertNotice, setAlertNotice] = useState<{ type: 'success' | 'error'; message: string } | null>(null);
  const [selectedQrCoolbox, setSelectedQrCoolbox] = useState<MasterCoolboxItem | null>(null);

  useEffect(() => {
    const unsub = MasterDataRtdbService.subscribeCoolboxes(setCoolboxes);
    return () => unsub();
  }, []);

  const showAlert = (type: 'success' | 'error', message: string) => {
    setAlertNotice({ type, message });
    setTimeout(() => setAlertNotice(null), 4000);
  };

  const handleAddCoolbox = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCoolboxCode.trim()) return;
    setIsLoading(true);
    try {
      await MasterDataRtdbService.addCoolbox(newCoolboxCode, newCoolboxLabel);
      setNewCoolboxCode('');
      setNewCoolboxLabel('');
      showAlert('success', `Coolbox IoT "${newCoolboxCode.toUpperCase()}" berhasil didaftarkan.`);
    } catch (err: unknown) {
      showAlert('error', err instanceof Error ? err.message : 'Gagal menambahkan coolbox');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDeleteCoolbox = async (id: string, code: string) => {
    if (!window.confirm(`Yakin ingin menghapus coolbox "${code}"?`)) return;
    try {
      await MasterDataRtdbService.deleteCoolbox(id);
      showAlert('success', `Coolbox "${code}" berhasil dihapus.`);
    } catch (err: unknown) {
      showAlert('error', err instanceof Error ? err.message : 'Gagal menghapus');
    }
  };

  const filteredCoolboxes = coolboxes.filter((c) =>
    c.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (c.label && c.label.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  return (
    <div className="space-y-6 select-none animate-in fade-in duration-150">
      {/* Top Banner Header */}
      <div className="rounded-2xl bg-gradient-to-r from-[#0F223A] via-[#153457] to-[#0A4E7A] p-6 text-white shadow-md border border-white/10 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1.5">
            <span className="inline-flex items-center gap-1.5 rounded-full bg-amber-400/20 px-2.5 py-0.5 text-[11px] font-extrabold uppercase tracking-wider text-amber-300 border border-amber-400/30">
              <ShieldCheck className="h-3.5 w-3.5" />
              Master Perangkat IoT
            </span>
            <span className="text-xs text-sky-200">• Realtime Database (master_coolboxes)</span>
          </div>
          <h1 className="text-2xl font-black tracking-tight text-white flex items-center gap-2.5">
            <Box className="h-6 w-6 text-cyan-400" />
            Master Coolbox IoT
          </h1>
          <p className="text-xs text-slate-300 mt-1 max-w-2xl leading-relaxed">
            Daftar armada kotak pendingin pintar (Coolbox IoT) yang dilengkapi sensor suhu dan telemetri GPS untuk memantau rantai dingin ikan antarpulau.
          </p>
        </div>

        <div className="flex items-center gap-2.5 self-start md:self-center">
          <div className="px-4 py-2 rounded-xl bg-white/10 border border-white/15 text-right">
            <div className="text-[10px] text-slate-300 uppercase font-bold tracking-wider">Armada Aktif</div>
            <div className="text-lg font-black text-white">{coolboxes.length} Unit</div>
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
        {/* Form Add Coolbox */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2 mb-1">
              <Plus className="h-4 w-4 text-sky-600" />
              Registrasi Coolbox Baru
            </h2>
            <p className="text-[11.5px] text-slate-500 mb-4 leading-relaxed">
              Daftarkan kode unit hardware coolbox IoT baru ke sistem SmartFrost.
            </p>
            <form onSubmit={handleAddCoolbox} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Kode Coolbox (Hardware ID)
                </label>
                <input
                  type="text"
                  required
                  value={newCoolboxCode}
                  onChange={(e) => setNewCoolboxCode(e.target.value)}
                  placeholder="Contoh: SFR-CB-99"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-mono font-bold uppercase"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Label / Lokasi Basis (Opsional)
                </label>
                <input
                  type="text"
                  value={newCoolboxLabel}
                  onChange={(e) => setNewCoolboxLabel(e.target.value)}
                  placeholder="Contoh: Coolbox IoT 99 - Maccini Baji"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
                />
              </div>
              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-2.5 px-4 rounded-xl bg-[#0284C7] hover:bg-sky-700 text-white font-bold text-xs shadow-xs transition-colors flex items-center justify-center gap-2 cursor-pointer disabled:opacity-60"
              >
                <Plus className="h-4 w-4" />
                <span>Daftarkan Unit Coolbox</span>
              </button>
            </form>
          </div>
        </div>

        {/* List Coolboxes */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
              <div>
                <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <Box className="h-4 w-4 text-cyan-600" />
                  Daftar Coolbox IoT Terdaftar
                </h2>
                <p className="text-xs text-slate-400 mt-0.5">
                  Tersinkronisasi realtime dengan tabel <code>master_coolboxes</code>.
                </p>
              </div>

              {/* Search Bar */}
              <div className="relative w-full sm:w-60">
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Cari kode coolbox..."
                  className="w-full pl-8 pr-3 py-1.5 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-1 focus:ring-sky-500 font-medium"
                />
                <Search className="h-3.5 w-3.5 text-slate-400 absolute left-2.5 top-2.5 pointer-events-none" />
              </div>
            </div>

            {filteredCoolboxes.length === 0 ? (
              <div className="py-12 text-center text-slate-400 text-xs">
                Tidak ada data coolbox IoT yang cocok.
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {filteredCoolboxes.map((cb) => (
                  <div
                    key={cb.id}
                    className="p-3.5 rounded-xl border border-slate-200/90 hover:border-sky-300 hover:bg-sky-50/20 transition-all flex items-center justify-between group"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="h-9 w-9 rounded-xl bg-teal-50 text-teal-700 flex items-center justify-center shrink-0 border border-teal-200/60 font-mono text-xs font-black">
                        IoT
                      </div>
                      <div className="min-w-0">
                        <div className="text-xs font-bold text-slate-900 font-mono">
                          {cb.code}
                        </div>
                        <div className="text-[11px] text-slate-500 truncate">
                          {cb.label || 'Unit Coolbox Sensor Suhu IoT'}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-1">
                      <button
                        type="button"
                        onClick={() => setSelectedQrCoolbox(cb)}
                        className="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl bg-sky-50 hover:bg-sky-100 text-[#0284C7] font-bold text-xs border border-sky-200/70 transition-colors cursor-pointer shadow-2xs"
                        title="Generate & Cetak QR Code"
                      >
                        <QrCode className="h-3.5 w-3.5" />
                        <span>QR Code</span>
                      </button>

                      <button
                        type="button"
                        onClick={() => handleDeleteCoolbox(cb.id, cb.code)}
                        className="text-slate-400 hover:text-rose-600 p-1.5 rounded-lg hover:bg-rose-50 transition-colors opacity-70 group-hover:opacity-100 cursor-pointer"
                        title="Hapus coolbox"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* QR Code Modal Dialog */}
      <CoolboxQrModal
        coolbox={selectedQrCoolbox}
        onClose={() => setSelectedQrCoolbox(null)}
      />
    </div>
  );
};

