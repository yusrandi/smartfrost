import React, { useEffect, useMemo, useState } from 'react';
import { ChevronDown, Download, RefreshCw, RotateCcw, Search, X } from 'lucide-react';
import { RecentDispatchesTable } from '../../../dashboard/presentation/components/RecentDispatchesTable';
import { DashboardRtdbDatasource } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { MOCK_DISPATCH_ITEMS } from '../../../dashboard/data/mock/dashboard_mock_data';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import { HistorySummaryCard } from '../components/HistorySummaryCard';

const SELECT_CLASS =
  'w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer';

const ITEMS_PER_PAGE = 8;

function exportCsv(rows: DispatchSummaryItem[]) {
  const header = ['Batch', 'Coolbox', 'Komoditas', 'Berat (kg)', 'Asal', 'Tujuan', 'Tanggal', 'Suhu terakhir (C)', 'FrostScore', 'Risiko', 'Sinkronisasi', 'Status'];
  const esc = (v: string | number) => `"${String(v).replace(/"/g, '""')}"`;
  const lines = rows.map((r) =>
    [r.batchId, r.coolboxId, r.commodity, r.weightKg, r.origin, r.destination, r.dateStr, r.lastTemp, r.frostScore, r.riskLevel, r.syncStatus, r.operationalStatus]
      .map(esc)
      .join(',')
  );
  const blob = new Blob([[header.map(esc).join(','), ...lines].join('\n')], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'riwayat-distribusi.csv';
  a.click();
  URL.revokeObjectURL(url);
}

export const HistoryPage: React.FC = () => {
  const [items, setItems] = useState<DispatchSummaryItem[]>(MOCK_DISPATCH_ITEMS);
  const [regions, setRegions] = useState<string[]>([]);
  const [isLive, setIsLive] = useState(false);
  const [isSyncing, setIsSyncing] = useState(true);
  const [selected, setSelected] = useState<DispatchSummaryItem | null>(null);

  const [regionFilter, setRegionFilter] = useState('Semua wilayah');
  const [statusFilter, setStatusFilter] = useState('Semua status');
  const [riskFilter, setRiskFilter] = useState('Semua tingkat');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);

  useEffect(() => {
    const unsubscribe = DashboardRtdbDatasource.subscribeToDashboardData(
      (data) => {
        setItems(data.items);
        setRegions(data.allRegions);
        setIsLive(data.isLiveFromFirestore);
        setIsSyncing(false);
      },
      (err) => {
        console.warn('History datasource notice:', err);
        setIsSyncing(false);
      }
    );
    return () => {
      if (typeof unsubscribe === 'function') unsubscribe();
    };
  }, []);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    return items.filter((i) => {
      if (regionFilter !== 'Semua wilayah') {
        const r = regionFilter.toLowerCase();
        if (!i.origin.toLowerCase().includes(r) && !i.destination.toLowerCase().includes(r)) return false;
      }
      if (statusFilter !== 'Semua status' && i.operationalStatus !== statusFilter) return false;
      if (riskFilter !== 'Semua tingkat' && i.riskLevel !== riskFilter) return false;
      if (q) {
        const hay = `${i.batchId} ${i.coolboxId} ${i.commodity} ${i.origin} ${i.destination}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }, [items, regionFilter, statusFilter, riskFilter, search]);

  useEffect(() => setPage(1), [regionFilter, statusFilter, riskFilter, search]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / ITEMS_PER_PAGE));
  const startIndex = filtered.length === 0 ? 0 : (page - 1) * ITEMS_PER_PAGE + 1;
  const endIndex = Math.min(page * ITEMS_PER_PAGE, filtered.length);
  const pageItems = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);

  const hasFilter =
    regionFilter !== 'Semua wilayah' || statusFilter !== 'Semua status' || riskFilter !== 'Semua tingkat' || search !== '';
  const reset = () => {
    setRegionFilter('Semua wilayah');
    setStatusFilter('Semua status');
    setRiskFilter('Semua tingkat');
    setSearch('');
  };

  const today = new Date().toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">Riwayat distribusi</h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Telusuri batch, serah terima, dan jejak data distribusi antarpulau.
          </p>
        </div>
        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">{today} - WITA</div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>{isLive ? `Realtime Database Live (${items.length} batch)` : 'Tersinkron demonstrasi'}</span>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="space-y-2">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div className="relative">
            <select value={regionFilter} onChange={(e) => setRegionFilter(e.target.value)} className={SELECT_CLASS}>
              <option>Semua wilayah</option>
              {regions.map((r) => (
                <option key={r} value={r}>{r}</option>
              ))}
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
          <div className="relative">
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className={SELECT_CLASS}>
              <option>Semua status</option>
              {['Menunggu', 'Perjalanan', 'Diperiksa', 'Diterima', 'Ditolak'].map((s) => (
                <option key={s}>{s}</option>
              ))}
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
          <div className="relative">
            <select value={riskFilter} onChange={(e) => setRiskFilter(e.target.value)} className={SELECT_CLASS}>
              <option>Semua tingkat</option>
              <option value="Rendah">Rendah (Skor &lt;40)</option>
              <option value="Perhatian">Perhatian (Skor 40-59)</option>
              <option value="Tinggi">Tinggi (Skor ≥60)</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
        </div>

        <div className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="pointer-events-none absolute left-3.5 top-3 h-3.5 w-3.5 text-slate-400" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Cari ID batch, coolbox, komoditas, atau lokasi"
              className="w-full rounded-xl bg-white border border-slate-200/80 pl-9 pr-4 py-2.5 text-xs text-slate-700 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>
          <button
            type="button"
            onClick={() => exportCsv(filtered)}
            className="inline-flex items-center justify-center gap-2 rounded-xl bg-white border border-slate-200/80 px-5 py-2.5 text-xs font-bold text-slate-700 shadow-2xs hover:bg-slate-50 cursor-pointer"
          >
            <Download className="h-3.5 w-3.5" />
            Ekspor CSV
          </button>
        </div>

        {hasFilter && (
          <div className="flex items-center justify-between text-xs pt-1 px-1">
            <span className="text-slate-500">Menampilkan {filtered.length} batch hasil filter</span>
            <button type="button" onClick={reset} className="inline-flex items-center gap-1 font-semibold text-sky-600 hover:text-sky-700 cursor-pointer">
              <RotateCcw className="h-3 w-3" />
              <span>Reset filter</span>
            </button>
          </div>
        )}
      </div>

      {/* Table */}
      <RecentDispatchesTable
        title={`${filtered.length} pengiriman tercatat`}
        showViewAll={false}
        items={pageItems}
        currentPage={page}
        totalPages={totalPages}
        totalFilteredCount={filtered.length}
        startIndex={startIndex}
        endIndex={endIndex}
        onPageChange={setPage}
        onSelectBatch={setSelected}
      />

      {/* Summary (replaces "Batch terpilih" and "Jejak keputusan & data") */}
      <HistorySummaryCard items={filtered} />

      {/* Quick detail modal */}
      {selected && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
          <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl border border-slate-200 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-sky-600">Detail Batch</span>
                <h3 className="text-base font-bold text-slate-900 font-mono">{selected.batchId}</h3>
              </div>
              <button type="button" onClick={() => setSelected(null)} className="rounded-lg p-1 text-slate-400 hover:bg-slate-100 cursor-pointer">
                <X className="h-5 w-5" />
              </button>
            </div>
            <div className="grid grid-cols-2 gap-3 text-xs">
              {[
                ['Coolbox', selected.coolboxId],
                ['Muatan', `${selected.commodity} (${selected.weightKg} kg)`],
                ['Suhu terakhir', `${selected.lastTemp.toFixed(1).replace('.', ',')} °C (${selected.lastTempTime})`],
                ['FrostScore', `${selected.frostScore} (${selected.riskLevel})`],
              ].map(([k, v]) => (
                <div key={k} className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                  <span className="text-slate-400 text-[11px]">{k}</span>
                  <p className="font-bold text-slate-800 mt-0.5">{v}</p>
                </div>
              ))}
              <div className="col-span-2 rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Rute & status</span>
                <p className="font-bold text-slate-800 mt-0.5">
                  {selected.origin} → {selected.destination} • {selected.dateStr}
                </p>
                <p className="font-bold text-sky-600 mt-0.5">{selected.operationalStatus} • {selected.syncStatus}</p>
              </div>
            </div>
            <div className="flex justify-end">
              <button type="button" onClick={() => setSelected(null)} className="rounded-xl bg-sky-600 px-4 py-2 text-xs font-bold text-white hover:bg-sky-500 cursor-pointer">
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

