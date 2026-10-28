import React, { useEffect, useMemo, useState } from 'react';
import { ChevronDown, Download, RefreshCw, RotateCcw, Search, X, Thermometer, ShieldCheck, Info } from 'lucide-react';
import { RecentDispatchesTable } from '../../../dashboard/presentation/components/RecentDispatchesTable';
import { DashboardRtdbDatasource, findCoolboxSuhu, type CoolboxSuhuState } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { MOCK_DISPATCH_ITEMS } from '../../../dashboard/data/mock/dashboard_mock_data';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import { FrostScoreCalculator } from '../../../dashboard/domain/services/frost_score_calculator';
import { HistorySummaryCard } from '../components/HistorySummaryCard';

const SELECT_CLASS =
  'w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer';

const ITEMS_PER_PAGE = 8;

function exportCsv(rows: DispatchSummaryItem[], suhuMap: Record<string, CoolboxSuhuState>) {
  const header = [
    'ID Batch',
    'Coolbox',
    'Komoditas',
    'Muatan / Berat',
    'Lokasi Asal',
    'Lokasi Tujuan',
    'Tanggal Pengiriman',
    'Suhu Udara Terakhir (°C)',
    'FrostScore',
    'Status Kualitas',
    'Sinkronisasi',
    'Status Operasional',
  ];
  const esc = (v: string | number) => `"${String(v).replace(/"/g, '""')}"`;
  const lines = rows.map((r) => {
    const boxSuhu = findCoolboxSuhu(suhuMap, r.coolboxId);
    const realTemp =
      boxSuhu?.latestAirTemp != null
        ? boxSuhu.latestAirTemp.toFixed(1)
        : r.lastTemp
        ? r.lastTemp.toFixed(1)
        : '-';
    const score = boxSuhu?.frostScore?.score ?? r.frostScore;
    const cat = FrostScoreCalculator.getCategory(score);
    const weight = r.weightDisplay || `${r.weightKg} kg`;

    return [
      r.batchId,
      boxSuhu?.coolboxId || r.coolboxId,
      r.commodity,
      weight,
      r.origin,
      r.destination,
      r.dateStr,
      realTemp,
      score,
      cat,
      r.syncStatus,
      r.operationalStatus,
    ]
      .map(esc)
      .join(',');
  });

  const blob = new Blob([[header.map(esc).join(','), ...lines].join('\n')], {
    type: 'text/csv;charset=utf-8;',
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `riwayat-distribusi-${new Date().toISOString().slice(0, 10)}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

export const HistoryPage: React.FC = () => {
  const [items, setItems] = useState<DispatchSummaryItem[]>(MOCK_DISPATCH_ITEMS);
  const [regions, setRegions] = useState<string[]>([]);
  const [suhuMap, setSuhuMap] = useState<Record<string, CoolboxSuhuState>>({});
  const [isLive, setIsLive] = useState(false);
  const [isSyncing, setIsSyncing] = useState(true);
  const [selected, setSelected] = useState<DispatchSummaryItem | null>(null);

  const [regionFilter, setRegionFilter] = useState('Semua wilayah');
  const [statusFilter, setStatusFilter] = useState('Semua status');
  const [riskFilter, setRiskFilter] = useState('Semua tingkat risiko');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);

  useEffect(() => {
    const unsubDashboard = DashboardRtdbDatasource.subscribeToDashboardData(
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

    const unsubSuhu = DashboardRtdbDatasource.subscribeToSuhuData(
      (map) => {
        setSuhuMap(map);
      },
      (err) => {
        console.warn('History suhu RTDB notice:', err);
      }
    );

    return () => {
      if (typeof unsubDashboard === 'function') unsubDashboard();
      if (typeof unsubSuhu === 'function') unsubSuhu();
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

      // Filter berdasarkan kategori FrostScore resmi
      if (riskFilter !== 'Semua tingkat risiko') {
        const boxSuhu = findCoolboxSuhu(suhuMap, i.coolboxId);
        const score = boxSuhu?.frostScore?.score ?? i.frostScore;
        const cat = FrostScoreCalculator.getCategory(score);
        if (riskFilter.startsWith('Sangat Baik') && cat !== 'Sangat Baik') return false;
        if (riskFilter.startsWith('Baik') && cat !== 'Baik') return false;
        if (riskFilter.startsWith('Waspada') && cat !== 'Waspada') return false;
        if (riskFilter.startsWith('Risiko Tinggi') && cat !== 'Risiko Tinggi') return false;
      }

      if (q) {
        const hay = `${i.batchId} ${i.coolboxId} ${i.commodity} ${i.origin} ${i.destination}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }, [items, regionFilter, statusFilter, riskFilter, search, suhuMap]);

  useEffect(() => setPage(1), [regionFilter, statusFilter, riskFilter, search]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / ITEMS_PER_PAGE));
  const startIndex = filtered.length === 0 ? 0 : (page - 1) * ITEMS_PER_PAGE + 1;
  const endIndex = Math.min(page * ITEMS_PER_PAGE, filtered.length);
  const pageItems = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);

  const realAverageTemp = useMemo(() => {
    if (Object.keys(suhuMap).length === 0) return null;
    const coolboxIdsInView = Array.from(new Set(filtered.map((i) => i.coolboxId)));
    const temps = coolboxIdsInView
      .map((id) => findCoolboxSuhu(suhuMap, id)?.latestAirTemp)
      .filter((t): t is number => typeof t === 'number');
    if (temps.length === 0) return null;
    return temps.reduce((a, b) => a + b, 0) / temps.length;
  }, [filtered, suhuMap]);

  const hasFilter =
    regionFilter !== 'Semua wilayah' ||
    statusFilter !== 'Semua status' ||
    riskFilter !== 'Semua tingkat risiko' ||
    search !== '';

  const reset = () => {
    setRegionFilter('Semua wilayah');
    setStatusFilter('Semua status');
    setRiskFilter('Semua tingkat risiko');
    setSearch('');
  };

  const today = new Date().toLocaleDateString('id-ID', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  // Data detail untuk batch yang terpilih
  const selectedSuhu = selected ? findCoolboxSuhu(suhuMap, selected.coolboxId) : null;
  const selectedRealTemp = selectedSuhu?.latestAirTemp;
  const selectedDisplayScore = selectedSuhu?.frostScore?.score ?? selected?.frostScore ?? 0;
  const selectedCategory = FrostScoreCalculator.getCategory(selectedDisplayScore);
  const selectedBadgeStyle = FrostScoreCalculator.getBadgeStyle(selectedDisplayScore);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">Riwayat distribusi</h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Telusuri batch, serah terima, dan jejak data telemetri rantai dingin antarpulau.
          </p>
        </div>
        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">{today} - WITA</div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>
              {isLive
                ? `Realtime Database Live (${items.length} batch • ${Object.keys(suhuMap).length} coolbox aktif)`
                : 'Tersinkron demonstrasi'}
            </span>
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
                <option key={r} value={r}>
                  {r}
                </option>
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
              <option>Semua tingkat risiko</option>
              <option value="Sangat Baik">Sangat Baik (Skor ≥90)</option>
              <option value="Baik">Baik (Skor 75–89)</option>
              <option value="Waspada">Waspada (Skor 60–74)</option>
              <option value="Risiko Tinggi">Risiko Tinggi (Skor &lt;60)</option>
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
            onClick={() => exportCsv(filtered, suhuMap)}
            className="inline-flex items-center justify-center gap-2 rounded-xl bg-white border border-slate-200/80 px-5 py-2.5 text-xs font-bold text-slate-700 shadow-2xs hover:bg-slate-50 cursor-pointer"
          >
            <Download className="h-3.5 w-3.5" />
            Ekspor CSV
          </button>
        </div>

        {hasFilter && (
          <div className="flex items-center justify-between text-xs pt-1 px-1">
            <span className="text-slate-500">Menampilkan {filtered.length} batch hasil filter</span>
            <button
              type="button"
              onClick={reset}
              className="inline-flex items-center gap-1 font-semibold text-sky-600 hover:text-sky-700 cursor-pointer"
            >
              <RotateCcw className="h-3 w-3" />
              <span>Reset filter</span>
            </button>
          </div>
        )}
      </div>

      {/* Table with real temperature and official FrostScore */}
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
        selectedBatchId={selected?.batchId}
        suhuMap={suhuMap}
      />

      {/* Ringkasan Riwayat Distribusi */}
      <HistorySummaryCard items={filtered} suhuMap={suhuMap} realAverageTemp={realAverageTemp} />

      {/* Quick detail modal */}
      {selected && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
          <div className="w-full max-w-lg rounded-2xl bg-white p-5 sm:p-6 shadow-2xl border border-slate-200 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-sky-600">
                  Detail Telemetri & Mutu Batch
                </span>
                <div className="flex items-center gap-2 mt-0.5">
                  <h3 className="text-lg font-bold text-slate-900 font-mono">{selected.batchId}</h3>
                  <span className="text-xs px-2 py-0.5 rounded-md bg-slate-100 text-slate-700 font-mono font-medium">
                    {selectedSuhu?.coolboxId || selected.coolboxId}
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setSelected(null)}
                className="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-600 cursor-pointer transition-colors"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Grid Informasi Utama */}
            <div className="grid grid-cols-2 gap-3 text-xs">
              {/* Suhu Terkini dari sensor valid /suhu */}
              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <div className="flex items-center justify-between text-slate-500 text-[11px]">
                  <span>Suhu Udara Sensor</span>
                  <Thermometer className="h-3.5 w-3.5 text-sky-600" />
                </div>
                {selectedRealTemp != null ? (
                  <div className="mt-1">
                    <p className="font-bold text-slate-900 font-mono text-base flex items-center gap-1.5">
                      <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                      {selectedRealTemp.toFixed(1).replace('.', ',')} &deg;C
                    </p>
                    <p className="text-[10.5px] text-slate-400 mt-0.5">
                      {selectedSuhu?.lastTimestampStr || selected.lastTempTime}
                    </p>
                  </div>
                ) : (
                  <div className="mt-1 text-slate-400 font-medium">
                    Menunggu sensor live
                  </div>
                )}
              </div>

              {/* FrostScore Resmi */}
              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <div className="flex items-center justify-between text-slate-500 text-[11px]">
                  <span>FrostScore Integritas</span>
                  <ShieldCheck className="h-3.5 w-3.5 text-emerald-600" />
                </div>
                <div className="mt-1 flex items-center gap-2">
                  <span className="font-black text-slate-900 text-base">{selectedDisplayScore}</span>
                  <span
                    className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10.5px] font-semibold border ${selectedBadgeStyle.badgeClass}`}
                  >
                    <span className={`h-1.5 w-1.5 rounded-full ${selectedBadgeStyle.dotClass}`} />
                    {selectedCategory}
                  </span>
                </div>
                <p className="text-[10.5px] text-slate-400 mt-0.5">
                  {selectedDisplayScore >= 90
                    ? 'Rantai dingin sangat aman'
                    : selectedDisplayScore >= 60
                    ? 'Perlu dipantau'
                    : 'Risiko kerusakan termal'}
                </p>
              </div>

              {/* Muatan & Komoditas */}
              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-500 text-[11px]">Muatan & Komoditas</span>
                <p className="font-bold text-slate-800 text-sm mt-0.5">{selected.commodity}</p>
                <p className="text-[11px] text-slate-500 font-mono mt-0.5">
                  {selected.weightDisplay || `${selected.weightKg} kg`}
                </p>
              </div>

              {/* Status Rantai Pasok */}
              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-500 text-[11px]">Status Operasional</span>
                <p className="font-bold text-sky-700 text-sm mt-0.5">{selected.operationalStatus}</p>
                <p className="text-[11px] text-slate-500 mt-0.5">
                  Data: <span className="font-semibold">{selected.syncStatus}</span>
                </p>
              </div>

              {/* Rute Perjalanan */}
              <div className="col-span-2 rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-500 text-[11px]">Rute Distribusi</span>
                <p className="font-bold text-slate-800 mt-0.5">
                  {selected.origin} &rarr; {selected.destination}
                </p>
                <p className="text-[11px] text-slate-400 mt-0.5">{selected.dateStr}</p>
              </div>
            </div>

            {/* Breakdown Komponen Penalti FrostScore (Jika ada data kalkulasi) */}
            {selectedSuhu?.frostScore && (
              <div className="rounded-xl border border-slate-200/80 p-3 bg-white space-y-2">
                <div className="flex items-center gap-1.5 text-xs font-bold text-slate-800">
                  <Info className="h-3.5 w-3.5 text-sky-600" />
                  <span>Komposisi Penalti Rumus SMART-FROST</span>
                </div>
                <div className="grid grid-cols-4 gap-2 text-center text-[10.5px]">
                  <div className="rounded-lg bg-slate-50 p-1.5 border border-slate-100">
                    <span className="text-slate-400 block">Dosis Termal (40%)</span>
                    <span className="font-bold text-slate-800 font-mono">
                      {selectedSuhu.frostScore.pThermal}%
                    </span>
                  </div>
                  <div className="rounded-lg bg-slate-50 p-1.5 border border-slate-100">
                    <span className="text-slate-400 block">Durasi (25%)</span>
                    <span className="font-bold text-slate-800 font-mono">
                      {selectedSuhu.frostScore.pExposure}%
                    </span>
                  </div>
                  <div className="rounded-lg bg-slate-50 p-1.5 border border-slate-100">
                    <span className="text-slate-400 block">Stabilitas (15%)</span>
                    <span className="font-bold text-slate-800 font-mono">
                      {selectedSuhu.frostScore.pStability}%
                    </span>
                  </div>
                  <div className="rounded-lg bg-slate-50 p-1.5 border border-slate-100">
                    <span className="text-slate-400 block">Anomali (20%)</span>
                    <span className="font-bold text-slate-800 font-mono">
                      {selectedSuhu.frostScore.pAnomaly}%
                    </span>
                  </div>
                </div>
                <div className="text-[10px] text-slate-400 text-right">
                  Total Penalti Kumulatif: <span className="font-bold text-slate-600 font-mono">{selectedSuhu.frostScore.pTotal}%</span>
                </div>
              </div>
            )}

            <div className="flex justify-end pt-2 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setSelected(null)}
                className="rounded-xl bg-slate-900 px-5 py-2 text-xs font-bold text-white hover:bg-slate-800 cursor-pointer transition-colors"
              >
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
