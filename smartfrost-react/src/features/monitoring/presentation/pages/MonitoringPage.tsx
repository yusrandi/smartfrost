import React, { useEffect, useMemo, useState } from 'react';
import { ChevronDown, RefreshCw, RotateCcw } from 'lucide-react';
import { TemperatureChartCard } from '../../../dashboard/presentation/components/TemperatureChartCard';
import { RecentDispatchesTable } from '../../../dashboard/presentation/components/RecentDispatchesTable';
import { MOCK_DISPATCH_ITEMS, MOCK_TEMPERATURE_POINTS } from '../../../dashboard/data/mock/dashboard_mock_data';
import type { DispatchSummaryItem, TemperatureDataPoint } from '../../../dashboard/data/models/dashboard_types';
import { MonitoringRtdbDatasource } from '../../data/datasources/monitoring_rtdb_datasource';
import type { MonitoringBatch } from '../../data/models/monitoring_types';
import { TrackingMapCard } from '../components/TrackingMapCard';
import { TripListPanel } from '../components/TripListPanel';
import { resolveLocation } from '../../../../core/constants/locations';

const SELECT_CLASS =
  'w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer';

const ITEMS_PER_PAGE = 4;

function mockBatches(): MonitoringBatch[] {
  return MOCK_DISPATCH_ITEMS.map((item) => ({
    summary: item,
    senderName: item.origin === 'Balang Lompo' ? 'Arman Ridwan • Laut Jaya' : 'Dinas Nelayan Lokal',
    receiverName: item.destination === 'Pangkajene' ? 'Nur Aisyah • Bahari Segar' : 'Distributor Pangkep',
    originPoint: resolveLocation(item.origin),
    destinationPoint: resolveLocation(item.destination),
    currentPoint: resolveLocation(item.origin),
    updatedAt: Date.now(),
    logs: [],
  }));
}

export const MonitoringPage: React.FC = () => {
  const [batches, setBatches] = useState<MonitoringBatch[]>(mockBatches);
  const [isLive, setIsLive] = useState<boolean>(false);
  const [isSyncing, setIsSyncing] = useState<boolean>(true);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  // Filters
  const [dateFilter, setDateFilter] = useState<string>('Semua tanggal');
  const [regionFilter, setRegionFilter] = useState<string>('Semua wilayah');
  const [statusFilter, setStatusFilter] = useState<string>('Semua status');
  const [riskFilter, setRiskFilter] = useState<string>('Semua tingkat');
  const [page, setPage] = useState<number>(1);

  useEffect(() => {
    const unsubscribe = MonitoringRtdbDatasource.subscribe(
      (liveBatches, liveStatus) => {
        if (liveBatches.length > 0) {
          setBatches(liveBatches);
          setSelectedId((prev) => prev ?? liveBatches[0].summary.id);
        } else {
          setBatches(mockBatches());
          setSelectedId((prev) => prev ?? MOCK_DISPATCH_ITEMS[0].id);
        }
        setIsLive(liveStatus);
        setIsSyncing(false);
      },
      (err) => {
        console.warn('Monitoring datasource notice:', err);
        setBatches(mockBatches());
        setSelectedId((prev) => prev ?? MOCK_DISPATCH_ITEMS[0].id);
        setIsSyncing(false);
      }
    );

    return () => {
      if (typeof unsubscribe === 'function') unsubscribe();
    };
  }, []);

  const availableRegions = useMemo(() => {
    const set = new Set<string>();
    batches.forEach((b) => {
      if (b.summary.origin) set.add(b.summary.origin);
      if (b.summary.destination) set.add(b.summary.destination);
    });
    return Array.from(set);
  }, [batches]);

  const filteredBatches = useMemo(() => {
    return batches.filter(({ summary: item }) => {
      if (dateFilter === 'Hari ini (22 Okt 2026)' && !item.dateStr.includes('22 Okt')) {
        return false;
      }
      if (regionFilter !== 'Semua wilayah') {
        const matchesOrigin = item.origin.toLowerCase().includes(regionFilter.toLowerCase());
        const matchesDest = item.destination.toLowerCase().includes(regionFilter.toLowerCase());
        if (!matchesOrigin && !matchesDest) return false;
      }
      if (statusFilter !== 'Semua status' && item.operationalStatus.toLowerCase() !== statusFilter.toLowerCase()) {
        return false;
      }
      if (riskFilter !== 'Semua tingkat' && item.riskLevel.toLowerCase() !== riskFilter.toLowerCase()) {
        return false;
      }
      return true;
    });
  }, [batches, dateFilter, regionFilter, statusFilter, riskFilter]);

  useEffect(() => {
    setPage(1);
  }, [dateFilter, regionFilter, statusFilter, riskFilter]);

  // Selected batch resolution
  const selectedBatch = useMemo(() => {
    return batches.find((b) => b.summary.id === selectedId) ?? batches[0] ?? null;
  }, [batches, selectedId]);

  // Temperature data resolution: tracking_logs or fallback mock
  const temperatureSeries: TemperatureDataPoint[] = useMemo(() => {
    if (!selectedBatch) return MOCK_TEMPERATURE_POINTS;
    const validLogs = selectedBatch.logs.filter((l) => typeof l.temperature === 'number');
    if (validLogs.length >= 2) {
      return validLogs.map((l) => ({
        time: l.timeLabel,
        temp: l.temperature as number,
      }));
    }
    return MOCK_TEMPERATURE_POINTS;
  }, [selectedBatch]);

  // Pagination for the bottom table
  const filteredItems: DispatchSummaryItem[] = useMemo(
    () => filteredBatches.map((b) => b.summary),
    [filteredBatches]
  );
  const totalFilteredCount = filteredItems.length;
  const totalPages = Math.max(1, Math.ceil(totalFilteredCount / ITEMS_PER_PAGE));
  const startIndex = totalFilteredCount === 0 ? 0 : (page - 1) * ITEMS_PER_PAGE + 1;
  const endIndex = Math.min(page * ITEMS_PER_PAGE, totalFilteredCount);
  const paginatedItems = useMemo(
    () => filteredItems.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE),
    [filteredItems, page]
  );

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
    setPage(1);
  };

  const activeInTransitCount = batches.filter(
    (b) => b.summary.operationalStatus === 'Perjalanan' || b.summary.operationalStatus === 'Menunggu'
  ).length;
  const delayedCount = batches.filter((b) => b.summary.syncStatus === 'Tertunda').length;

  return (
    <div className="space-y-6">
      {/* Title & Sync Status Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
            Monitoring perjalanan
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Pantau suhu, rute perjalanan antarpulau, sebaran distributor, dan kelengkapan data operasional rantai dingin.
          </p>
        </div>

        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">
            Kamis, 22 Oktober 2026 - WITA
          </div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>
              {isLive ? `Realtime Database Live (${batches.length} batch)` : 'Tersinkron demonstrasi'} &bull; 22 Okt 2026, 10.42 WITA
            </span>
          </div>
        </div>
      </div>

      {/* Map & Trip List Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-stretch">
        <div className="lg:col-span-2">
          <TrackingMapCard
            batches={filteredBatches}
            selectedId={selectedBatch?.summary.id ?? null}
            onSelect={(id) => setSelectedId(id)}
            isLive={isLive}
          />
        </div>
        <div className="lg:col-span-1">
          <TripListPanel
            batches={filteredBatches}
            selectedId={selectedBatch?.summary.id ?? null}
            onSelect={(id) => setSelectedId(id)}
          />
        </div>
      </div>

      {/* Temperature Timeline for Selected Batch */}
      <div className="w-full">
        <TemperatureChartCard
          dataPoints={temperatureSeries}
          title="Grafik suhu perjalanan"
          subtitle={
            selectedBatch
              ? `${selectedBatch.summary.batchId} • ${selectedBatch.summary.origin} → ${selectedBatch.summary.destination} • ${selectedBatch.summary.dateStr}`
              : '22 Oktober 2026 • 08.00–10.30 WITA'
          }
          lastTempLabel={`Terakhir ${selectedBatch ? selectedBatch.summary.lastTemp.toFixed(1).replace('.', ',') : '1,8'} °C`}
          syncLabel={selectedBatch?.summary.syncTime ? `Tersinkron ${selectedBatch.summary.syncTime}` : 'Tersinkron 10.42 WITA'}
          note="Area arsiran: rentang operasional contoh 0–4 °C. Sensor suhu digital IoT DS18B20."
        />
      </div>

      {/* Filters */}
      <div className="space-y-2">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <div className="relative">
            <select
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className={SELECT_CLASS}
            >
              <option value="Semua tanggal">Tanggal: Semua tanggal</option>
              <option value="Hari ini (22 Okt 2026)">Hari ini (22 Okt 2026)</option>
              <option value="1–22 Okt 2026">1–22 Okt 2026</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>

          <div className="relative">
            <select
              value={regionFilter}
              onChange={(e) => setRegionFilter(e.target.value)}
              className={SELECT_CLASS}
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

          <div className="relative">
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className={SELECT_CLASS}
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

          <div className="relative">
            <select
              value={riskFilter}
              onChange={(e) => setRiskFilter(e.target.value)}
              className={SELECT_CLASS}
            >
              <option value="Semua tingkat">Risiko: Semua tingkat</option>
              <option value="Rendah">Rendah (Skor &lt;40)</option>
              <option value="Perhatian">Perhatian (Skor 40-59)</option>
              <option value="Tinggi">Tinggi (Skor &ge;60)</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
        </div>

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

      {/* Bottom Table: Daftar Perjalanan */}
      <RecentDispatchesTable
        title={`Daftar perjalanan (${activeInTransitCount} aktif • ${delayedCount} dengan data tertunda)`}
        showViewAll={false}
        items={paginatedItems}
        currentPage={page}
        totalPages={totalPages}
        totalFilteredCount={totalFilteredCount}
        startIndex={startIndex}
        endIndex={endIndex}
        onPageChange={(p) => setPage(p)}
        onSelectBatch={(item) => setSelectedId(item.id)}
      />
    </div>
  );
};

