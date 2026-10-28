import React, { useState, useEffect, useMemo } from 'react';
import { ChevronDown, RefreshCw, X, Box, RotateCcw, Database, Thermometer } from 'lucide-react';
import { MetricCardsGrid } from '../components/MetricCardsGrid';
import { TemperatureChartCard } from '../components/TemperatureChartCard';
import { FrostScoreTrendCard } from '../components/FrostScoreTrendCard';
import { IncidentAlertBanners } from '../components/IncidentAlertBanners';
import { RecentDispatchesTable } from '../components/RecentDispatchesTable';
import {
  DashboardRtdbDatasource,
  findCoolboxSuhu,
  type CoolboxSuhuState,
} from '../../data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator } from '../../domain/services/frost_score_calculator';
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
  const [suhuMap, setSuhuMap] = useState<Record<string, CoolboxSuhuState>>({});
  const [isLive, setIsLive] = useState<boolean>(false);
  const [isSyncing, setIsSyncing] = useState<boolean>(true);
  const [activeBatch, setActiveBatch] = useState<DispatchSummaryItem | null>(null);
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
    const unsubDispatches = DashboardRtdbDatasource.subscribeToDashboardData(
      (data) => {
        setItems(data.items);
        setMetrics(data.metrics);
        setIsLive(data.isLiveFromFirestore);
        setAvailableRegions(data.allRegions);
        setIsSyncing(false);
        setActiveBatch((prev) => prev || (data.items.length > 0 ? data.items[0] : null));
      },
      (err) => {
        console.warn('Dashboard datasource notice:', err);
        setIsSyncing(false);
      }
    );

    const unsubSuhu = DashboardRtdbDatasource.subscribeToSuhuData(
      (map) => {
        setSuhuMap(map);
      },
      (err) => {
        console.warn('Dashboard suhu notice:', err);
      }
    );

    return () => {
      if (typeof unsubDispatches === 'function') unsubDispatches();
      if (typeof unsubSuhu === 'function') unsubSuhu();
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
        const boxSuhu = findCoolboxSuhu(suhuMap, item.coolboxId);
        const score = boxSuhu?.frostScore?.score ?? item.frostScore;
        const category = FrostScoreCalculator.getCategory(score);
        if (riskFilter === 'Sangat Baik' && category !== 'Sangat Baik') return false;
        if (riskFilter === 'Baik' && category !== 'Baik') return false;
        if (riskFilter === 'Waspada' && category !== 'Waspada') return false;
        if (riskFilter === 'Risiko Tinggi' && category !== 'Risiko Tinggi') return false;
      }

      return true;
    });
  }, [items, dateFilter, regionFilter, statusFilter, riskFilter, suhuMap]);

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

  const currentBatch = activeBatch || (items.length > 0 ? items[0] : null);
  const currentCoolboxId = currentBatch?.coolboxId || 'SFR-CB-01';

  const activeSuhu = useMemo(() => {
    return findCoolboxSuhu(suhuMap, currentCoolboxId);
  }, [suhuMap, currentCoolboxId]);

  const chartDataPoints = useMemo(() => {
    if (activeSuhu && activeSuhu.dataPoints.length > 0) {
      return activeSuhu.dataPoints;
    }
    return MOCK_TEMPERATURE_POINTS;
  }, [activeSuhu]);

  const chartSubtitle = currentBatch
    ? `${currentBatch.batchId} • Coolbox ${activeSuhu?.coolboxId || currentBatch.coolboxId} • ${currentBatch.origin} → ${currentBatch.destination}`
    : 'SF-221026-018 • Coolbox SFR-CB-01 • Balang Lompo → Pangkajene';

  const lastTempLabel = activeSuhu?.latestAirTemp != null
    ? `Terakhir ${activeSuhu.latestAirTemp.toFixed(1)} °C`
    : currentBatch
      ? `Terakhir ${currentBatch.lastTemp.toFixed(1)} °C`
      : 'Terakhir 1,8 °C';

  const selectedModalSuhu = useMemo(() => {
    if (!selectedBatch) return null;
    return findCoolboxSuhu(suhuMap, selectedBatch.coolboxId);
  }, [suhuMap, selectedBatch]);

  // Option B: Real average temperature from the valid /suhu table (across active coldboxes)
  const realAverageTemp = useMemo(() => {
    const boxes = Object.values(suhuMap);
    if (boxes.length === 0) return null;
    const temps = boxes
      .map((b) => b.averageTemp ?? b.latestAirTemp)
      .filter((t): t is number => typeof t === 'number' && !isNaN(t));
    if (temps.length === 0) return null;
    return temps.reduce((a, b) => a + b, 0) / temps.length;
  }, [suhuMap]);

  // Dynamically compute effective metrics across dispatches taking RTDB /suhu sensor into account
  const effectiveMetrics = useMemo(() => {
    let highRiskCount = 0;
    let totalScore = 0;
    let countScore = 0;

    items.forEach((item) => {
      const boxSuhu = findCoolboxSuhu(suhuMap, item.coolboxId);
      const score = boxSuhu?.frostScore?.score ?? item.frostScore;
      const category = FrostScoreCalculator.getCategory(score);

      const isHighRisk =
        category === 'Risiko Tinggi' ||
        score < 60 ||
        item.riskLevel === 'Risiko Tinggi' ||
        item.riskLevel === 'Tinggi';

      if (isHighRisk) {
        highRiskCount++;
      }
      if (typeof score === 'number' && !isNaN(score)) {
        totalScore += score;
        countScore++;
      }
    });

    return {
      ...metrics,
      averageFrostScore: countScore > 0 ? Math.round(totalScore / countScore) : metrics.averageFrostScore,
      highRiskBatchesCount: highRiskCount,
    };
  }, [items, suhuMap, metrics]);

  // Cara 2: Batch-to-Batch FrostScore trend from recent shipments
  const batchFrostScorePoints = useMemo(() => {
    if (items.length === 0) return [];
    // Take up to 8 recent batches (ordered left-to-right from earliest to newest among recent)
    const recent = items.slice(0, 8).reverse();
    return recent.map((item) => {
      const boxSuhu = findCoolboxSuhu(suhuMap, item.coolboxId);
      const score = boxSuhu?.frostScore?.score ?? item.frostScore;
      const category = FrostScoreCalculator.getCategory(score);

      // Shorten label for neat X-axis rendering, e.g. SF-221026-018 -> '018'
      const match = item.batchId.match(/(\d{3,4})$/);
      const shortLabel = match ? match[1] : item.batchId.slice(-4);
      return {
        batchId: item.batchId,
        label: shortLabel,
        score,
        commodity: item.commodity,
        coolboxId: item.coolboxId,
        riskLevel: category,
      };
    });
  }, [items, suhuMap]);

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
              <option value="Semua tingkat">Tingkat Risiko: Semua tingkat</option>
              <option value="Sangat Baik">Sangat Baik (Skor ≥90)</option>
              <option value="Baik">Baik (Skor 75–89)</option>
              <option value="Waspada">Waspada (Skor 60–74)</option>
              <option value="Risiko Tinggi">Risiko Tinggi (Skor &lt;60)</option>
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

      {/* 4 Top Metric Cards (Opsi B: Rata-rata FrostScore seluruh pengiriman + Rata-rata Suhu valid dari /suhu) */}
      <MetricCardsGrid metrics={effectiveMetrics} realAverageTemp={realAverageTemp} />

      {/* 2 Middle Chart Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 w-full">
        <TemperatureChartCard
          dataPoints={chartDataPoints}
          title="Suhu perjalanan terpilih"
          subtitle={chartSubtitle}
          lastTempLabel={lastTempLabel}
          coolboxId={activeSuhu?.coolboxId || currentCoolboxId}
          averageTemp={activeSuhu?.averageTemp}
          latestAirTemp={activeSuhu?.latestAirTemp}
          humidityPct={activeSuhu?.humidityPct}
          isLive={Boolean(activeSuhu && activeSuhu.dataPoints.length > 0)}
          syncLabel={activeSuhu?.lastTimestampStr ? `Tersinkron ${activeSuhu.lastTimestampStr}` : undefined}
        />
        {/* Cara 2: Tren FrostScore Batch-ke-Batch dari data RTDB */}
        <FrostScoreTrendCard
          dataPoints={MOCK_FROSTSCORE_POINTS}
          batchPoints={batchFrostScorePoints}
          selectedBatchId={currentBatch?.batchId}
          onSelectBatchId={(batchId) => {
            const found = items.find((i) => i.batchId === batchId);
            if (found) {
              setActiveBatch(found);
              setSelectedBatch(found);
            }
          }}
        />
      </div>

      {/* Incident Alert Banners with dynamic telemetry & cold-chain detection */}
      <IncidentAlertBanners
        items={items}
        suhuMap={suhuMap}
        onSelectBatch={(batch) => {
          setActiveBatch(batch);
          setSelectedBatch(batch);
        }}
      />

      {/* Bottom Table: Perjalanan Terkini with active pagination and valid /suhu telemetry */}
      <RecentDispatchesTable
        items={paginatedItems}
        currentPage={currentPage}
        totalPages={totalPages}
        totalFilteredCount={totalFilteredCount}
        startIndex={startIndex}
        endIndex={endIndex}
        onPageChange={(page) => setCurrentPage(page)}
        selectedBatchId={currentBatch?.batchId}
        suhuMap={suhuMap}
        onSelectBatch={(batch) => {
          setActiveBatch(batch);
          setSelectedBatch(batch);
        }}
      />

      {/* Quick Modal Preview on Table Row Click */}
      {selectedBatch && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
          <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl border border-slate-200 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-sky-600 flex items-center gap-1">
                  <Database className="h-3 w-3" />
                  Detail Batch Terpilih
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
                <span className="text-slate-400 text-[11px]">Suhu Terakhir (Sensor):</span>
                <p className="font-bold text-slate-900 mt-0.5 font-mono flex items-center gap-1">
                  <Thermometer className="h-3.5 w-3.5 text-sky-600" />
                  <span>
                    {selectedModalSuhu?.latestAirTemp != null
                      ? `${selectedModalSuhu.latestAirTemp.toFixed(1)} °C`
                      : `${selectedBatch.lastTemp.toFixed(1)} °C`}
                  </span>
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Rata-rata Suhu IoT:</span>
                <p className="font-bold text-teal-800 mt-0.5 font-mono">
                  {selectedModalSuhu?.averageTemp != null
                    ? `${selectedModalSuhu.averageTemp.toFixed(1)} °C`
                    : '-'}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">FrostScore / Risiko:</span>
                <p className="font-bold text-slate-900 mt-0.5">
                  {selectedBatch.frostScore} ({selectedBatch.riskLevel})
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100">
                <span className="text-slate-400 text-[11px]">Kelembaban:</span>
                <p className="font-bold text-slate-900 mt-0.5">
                  {selectedModalSuhu?.humidityPct != null
                    ? `${selectedModalSuhu.humidityPct}%`
                    : '-'}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-3 border border-slate-100 col-span-2">
                <span className="text-slate-400 text-[11px]">Status Operasional:</span>
                <p className="font-bold text-sky-600 mt-0.5">
                  {selectedBatch.operationalStatus} &bull; {selectedBatch.syncStatus}
                </p>
              </div>
            </div>

            <div className="flex items-center justify-between pt-2">
              <span className="text-[11px] text-slate-400">
                Batch aktif ditampilkan pada grafik suhu
              </span>
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
