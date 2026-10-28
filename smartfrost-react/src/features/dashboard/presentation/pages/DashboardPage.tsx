import React, { useState, useEffect, useMemo } from 'react';
import { ChevronDown, RefreshCw, X, Box, RotateCcw, Database } from 'lucide-react';
import { MetricCardsGrid } from '../components/MetricCardsGrid';
import { TemperatureChartCard } from '../components/TemperatureChartCard';
import { FrostScoreTrendCard } from '../components/FrostScoreTrendCard';
import { IncidentAlertBanners } from '../components/IncidentAlertBanners';
import { RecentDispatchesTable } from '../components/RecentDispatchesTable';
import { DashboardRtdbDatasource } from '../../data/datasources/dashboard_rtdb_datasource';
import {
  MOCK_METRICS,
  MOCK_DISPATCH_ITEMS,
  MOCK_TEMPERATURE_POINTS,
  MOCK_FROSTSCORE_POINTS
} from '../../data/mock/dashboard_mock_data';
import type { DashboardMetrics, DispatchSummaryItem } from '../../data/models/dashboard_types';

export const DashboardPage: React.FC = () => {
  const [metrics, setMetrics] = useState<DashboardMetrics>(MOCK_METRICS);
  const [items, setItems] = useState<DispatchSummaryItem[]>(MOCK_DISPATCH_ITEMS);
  const [isLive, setIsLive] = useState<boolean>(false);
  const [isSyncing, setIsSyncing] = useState<boolean>(true);
  const [selectedBatch, setSelectedBatch] = useState<DispatchSummaryItem | null>(null);
  const [availableRegions, setAvailableRegions] = useState<string[]>([
    'Balang Lompo', 'Sarappo', 'Sabutung', 'Karanrang', 'Gondongbali', 'Kulambing', 'Pangkajene'
  ]);

  // Filter States
  const [dateFilter, setDateFilter] = useState<string>('Semua tanggal');
  const [regionFilter, setRegionFilter] = useState<string>('Semua wilayah');
  const [statusFilter, setStatusFilter] = useState<string>('Semua status');
  const [riskFilter, setRiskFilter] = useState<string>('Semua tingkat');

  // Pagination State
  const [currentPage, setCurrentPage] = useState<number>(1);
  const itemsPerPage = 4;

  useEffect(() => {
    const unsubscribe = DashboardRtdbDatasource.subscribeToDashboardData(
      (data) => {
        setItems(data.items);
        setMetrics(data.metrics);
        setIsLive(data.isLiveFromFirestore);
        setAvailableRegions(data.allRegions);
        setIsSyncing(false);
      },
      (err) => {
        console.warn('Dashboard datasource notice:', err);
        setIsSyncing(false);
      }
    );

    return () => {
      if (typeof unsubscribe === 'function') unsubscribe();
    };
  }, []);

  // Filter items based on active criteria
  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      // Date filtering
      if (dateFilter === 'Hari ini (22 Okt 2026)') {
        if (!item.dateStr.includes('22 Okt')) return false;
      }

      // Region filtering (matches origin or destination)
      if (regionFilter !== 'Semua wilayah') {
        const matchesOrigin = item.origin.toLowerCase().includes(regionFilter.toLowerCase());
        const matchesDest = item.destination.toLowerCase().includes(regionFilter.toLowerCase());
        if (!matchesOrigin && !matchesDest) return false;
      }

      // Status filtering
      if (statusFilter !== 'Semua status') {
        if (item.operationalStatus.toLowerCase() !== statusFilter.toLowerCase()) return false;
      }

      // Risk level filtering
      if (riskFilter !== 'Semua tingkat') {
        if (item.riskLevel.toLowerCase() !== riskFilter.toLowerCase()) return false;
      }

      return true;
    });
  }, [items, dateFilter, regionFilter, statusFilter, riskFilter]);

  // Reset pagination to page 1 whenever any filter changes
  useEffect(() => {
    setCurrentPage(1);
  }, [dateFilter, regionFilter, statusFilter, riskFilter]);

  // Pagination calculations
  const totalFilteredCount = filteredItems.length;
  const totalPages = Math.max(1, Math.ceil(totalFilteredCount / itemsPerPage));
  const startIndex = totalFilteredCount === 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
  const endIndex = Math.min(currentPage * itemsPerPage, totalFilteredCount);

  const paginatedItems = useMemo(() => {
    const start = (currentPage - 1) * itemsPerPage;
    return filteredItems.slice(start, start + itemsPerPage);
  }, [filteredItems, currentPage, itemsPerPage]);

  const hasActiveFilter =
    dateFilter !== 'Semua tanggal' ||
    regionFilter !== 'Semua wilayah' ||
    statusFilter !== 'Semua status' ||
    riskFilter !== 'Semua tingkat';

  const handleResetFilters = () => {
    setDateFilter('Semua tanggal');
    setRegionFilter('Semua wilayah');
    setStatusFilter('Semua status');
    setRiskFilter('Semua tingkat');
    setCurrentPage(1);
  };

  return (
    <div className="space-y-6">
      {/* Title & Sync Status Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
            Rantai dingin, dalam pantauan.
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Ringkasan distribusi ikan antarpulau &bull; Kabupaten Pangkep
          </p>
        </div>

        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">
            Kamis, 22 Oktober 2026 - WITA
          </div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>
              {isLive ? `Realtime Database Live (${items.length} batch)` : 'Tersinkron demonstrasi'} &bull; 22 Okt 2026, 10.42 WITA
            </span>
          </div>
        </div>
      </div>

      {/* Filter Row with Active Reset Option */}
      <div className="space-y-2">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {/* 1. Date Filter Dropdown */}
          <div className="relative">
            <select
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer"
            >
              <option value="Semua tanggal">Tanggal: Semua tanggal</option>
              <option value="Hari ini (22 Okt 2026)">Hari ini (22 Okt 2026)</option>
              <option value="1–22 Okt 2026">1–22 Okt 2026</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>

          {/* 2. Region Filter Dropdown */}
          <div className="relative">
            <select
              value={regionFilter}
              onChange={(e) => setRegionFilter(e.target.value)}
              className="w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer"
            >
              <option value="Semua wilayah">Wilayah: Semua wilayah</option>
              {availableRegions.map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>

          {/* 3. Status Filter Dropdown */}
          <div className="relative">
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer"
            >
              <option value="Semua status">Status: Semua status</option>
              <option value="Menunggu">Menunggu</option>
              <option value="Perjalanan">Perjalanan</option>
              <option value="Diperiksa">Diperiksa</option>
              <option value="Diterima">Diterima</option>
              <option value="Ditolak">Ditolak</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>

          {/* 4. Risk Filter Dropdown */}
          <div className="relative">
            <select
              value={riskFilter}
              onChange={(e) => setRiskFilter(e.target.value)}
              className="w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer"
            >
              <option value="Semua tingkat">Risiko: Semua tingkat</option>
              <option value="Rendah">Rendah (Skor &lt;40)</option>
              <option value="Perhatian">Perhatian (Skor 40-59)</option>
              <option value="Tinggi">Tinggi (Skor &ge;60)</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
        </div>

        {/* Reset Filter Button if any filter is active */}
        {hasActiveFilter && (
          <div className="flex items-center justify-between text-xs pt-1 px-1">
            <span className="text-slate-500">
              Menampilkan {totalFilteredCount} batch hasil filter
            </span>
            <button
              type="button"
              onClick={handleResetFilters}
              className="inline-flex items-center gap-1 font-semibold text-sky-600 hover:text-sky-700 cursor-pointer"
            >
              <RotateCcw className="h-3 w-3" />
              <span>Reset filter ke default</span>
            </button>
          </div>
        )}
      </div>

      {/* 4 Top Metric Cards */}
      <MetricCardsGrid metrics={metrics} />

      {/* 2 Middle Chart Cards */}
      <div className="grid grid-cols-2 gap-4 w-full">
        <TemperatureChartCard dataPoints={MOCK_TEMPERATURE_POINTS} />
        <FrostScoreTrendCard dataPoints={MOCK_FROSTSCORE_POINTS} />
      </div>

      {/* Incident Alert Banners */}
      <IncidentAlertBanners />

      {/* Bottom Table: Perjalanan Terkini with active pagination */}
      <RecentDispatchesTable
        items={paginatedItems}
        currentPage={currentPage}
        totalPages={totalPages}
        totalFilteredCount={totalFilteredCount}
        startIndex={startIndex}
        endIndex={endIndex}
        onPageChange={(page) => setCurrentPage(page)}
        onSelectBatch={(batch) => setSelectedBatch(batch)}
      />

      {/* Quick Modal Preview on Table Row Click */}
      {selectedBatch && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
          <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl border border-slate-200 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-sky-600 flex items-center gap-1">
                  <Database className="h-3 w-3" />
                  Detail Batch
                </span>
                <h3 className="text-base font-bold text-slate-900 font-mono">
                  {selectedBatch.batchId}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setSelectedBatch(null)}
                className="rounded-lg p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-700 cursor-pointer"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Coolbox ID:</span>
                <p className="font-bold text-slate-800 mt-0.5 flex items-center gap-1.5 font-mono">
                  <Box className="h-3.5 w-3.5 text-sky-600" />
                  {selectedBatch.coolboxId}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Komoditas / Muatan:</span>
                <p className="font-bold text-slate-800 mt-0.5">
                  {selectedBatch.commodity} ({selectedBatch.weightKg} kg)
                </p>
              </div>

              <div className="col-span-2 rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Rute Maritim:</span>
                <p className="font-bold text-slate-800 mt-0.5">
                  {selectedBatch.origin} &rarr; {selectedBatch.destination} &bull; {selectedBatch.dateStr}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Suhu Terakhir:</span>
                <p className="font-bold text-slate-900 mt-0.5 font-mono">
                  {selectedBatch.lastTemp.toFixed(1).replace('.', ',')} &deg;C ({selectedBatch.lastTempTime})
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">FrostScore / Risiko:</span>
                <p className="font-bold text-slate-900 mt-0.5">
                  {selectedBatch.frostScore} ({selectedBatch.riskLevel})
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100 col-span-2">
                <span className="text-slate-400 text-[11px]">Status Operasional:</span>
                <p className="font-bold text-sky-600 mt-0.5">
                  {selectedBatch.operationalStatus} &bull; {selectedBatch.syncStatus}
                </p>
              </div>
            </div>

            <div className="flex justify-end pt-2">
              <button
                type="button"
                onClick={() => setSelectedBatch(null)}
                className="rounded-xl bg-sky-600 px-4 py-2 text-xs font-bold text-white hover:bg-sky-500 transition-colors cursor-pointer"
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
