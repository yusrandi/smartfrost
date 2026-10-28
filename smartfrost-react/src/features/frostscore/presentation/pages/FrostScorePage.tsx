import React, { useEffect, useMemo, useState } from 'react';
import { ChevronDown, Info, RefreshCw, RotateCcw } from 'lucide-react';
import { DashboardRtdbDatasource } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import {
  MOCK_DISPATCH_ITEMS,
  MOCK_FROSTSCORE_POINTS,
  MOCK_METRICS,
} from '../../../dashboard/data/mock/dashboard_mock_data';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import { FrostScoreMetricsCards } from '../components/FrostScoreMetricsCards';
import { RiskTrendCard } from '../components/RiskTrendCard';
import { HowToReadFrostScoreCard } from '../components/HowToReadFrostScoreCard';
import { PriorityReviewTable } from '../components/PriorityReviewTable';

const SELECT_CLASS =
  'w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer';

const ITEMS_PER_PAGE = 3;

// Extended realistic mock items covering the 17 priority batches mentioned in the design
const PRIORITY_MOCK_ITEMS: DispatchSummaryItem[] = [
  {
    id: 'p-1',
    batchId: 'SF-221026-019',
    coolboxId: 'SFR-CB-019',
    commodity: 'Kembung',
    weightKg: 65,
    origin: 'Balang Lompo',
    destination: 'Pangkajene',
    dateStr: '22 Okt 2026',
    lastTemp: 3.8,
    lastTempTime: '09.55 WITA',
    frostScore: 42,
    riskLevel: 'Perhatian',
    syncStatus: 'Tertunda',
    operationalStatus: 'Perjalanan',
  },
  {
    id: 'p-2',
    batchId: 'SF-221026-017',
    coolboxId: 'SFR-CB-017',
    commodity: 'Tuna',
    weightKg: 60,
    origin: 'Sarappo',
    destination: 'Pangkajene',
    dateStr: '22 Okt 2026',
    lastTemp: 8.1,
    lastTempTime: '10.30 WITA',
    frostScore: 76,
    riskLevel: 'Tinggi',
    syncStatus: 'Tersinkron',
    operationalStatus: 'Diperiksa',
  },
  {
    id: 'p-3',
    batchId: 'SF-221026-015',
    coolboxId: 'SFR-CB-015',
    commodity: 'Tuna',
    weightKg: 55,
    origin: 'Sarappo',
    destination: 'Pangkajene',
    dateStr: '22 Okt 2026',
    lastTemp: 6.4,
    lastTempTime: '10.30 WITA',
    frostScore: 68,
    riskLevel: 'Tinggi',
    syncStatus: 'Tersinkron',
    operationalStatus: 'Diperiksa',
  },
  {
    id: 'p-4',
    batchId: 'SF-221026-013',
    coolboxId: 'SFR-CB-013',
    commodity: 'Tuna',
    weightKg: 110,
    origin: 'Kulambing',
    destination: 'Pangkajene',
    dateStr: '20 Okt 2026',
    lastTemp: 7.4,
    lastTempTime: '11.20 WITA',
    frostScore: 68,
    riskLevel: 'Tinggi',
    syncStatus: 'Tertunda',
    operationalStatus: 'Ditolak',
  },
  {
    id: 'p-5',
    batchId: 'SF-221026-011',
    coolboxId: 'SFR-CB-011',
    commodity: 'Cumi-Cumi',
    weightKg: 40,
    origin: 'Sarappo',
    destination: 'Pangkajene',
    dateStr: '19 Okt 2026',
    lastTemp: 4.8,
    lastTempTime: '13.00 WITA',
    frostScore: 49,
    riskLevel: 'Perhatian',
    syncStatus: 'Tersinkron',
    operationalStatus: 'Perjalanan',
  },
  {
    id: 'p-6',
    batchId: 'SF-221026-014',
    coolboxId: 'SFR-CB-014',
    commodity: 'Kakap Merah',
    weightKg: 50,
    origin: 'Gondongbali',
    destination: 'Pangkajene',
    dateStr: '21 Okt 2026',
    lastTemp: 3.5,
    lastTempTime: '16.40 WITA',
    frostScore: 38,
    riskLevel: 'Perhatian',
    syncStatus: 'Tersinkron',
    operationalStatus: 'Perjalanan',
  },
  {
    id: 'p-7',
    batchId: 'SF-221026-008',
    coolboxId: 'SFR-CB-008',
    commodity: 'Kerapu',
    weightKg: 45,
    origin: 'Karanrang',
    destination: 'Pangkajene',
    dateStr: '16 Okt 2026',
    lastTemp: 3.2,
    lastTempTime: '15.50 WITA',
    frostScore: 35,
    riskLevel: 'Perhatian',
    syncStatus: 'Tersinkron',
    operationalStatus: 'Diterima',
  },
];

export const FrostScorePage: React.FC = () => {
  const [items, setItems] = useState<DispatchSummaryItem[]>(MOCK_DISPATCH_ITEMS);
  const [isLive, setIsLive] = useState<boolean>(false);
  const [isSyncing, setIsSyncing] = useState<boolean>(true);

  // Filters
  const [dateFilter, setDateFilter] = useState<string>('1–22 Okt 2026');
  const [regionFilter, setRegionFilter] = useState<string>('Semua wilayah');
  const [statusFilter, setStatusFilter] = useState<string>('Semua status');
  const [riskFilter, setRiskFilter] = useState<string>('Semua tingkat');
  const [page, setPage] = useState<number>(1);

  useEffect(() => {
    const unsubscribe = DashboardRtdbDatasource.subscribeToDashboardData(
      (data) => {
        if (data.items.length > 0) {
          setItems(data.items);
        } else {
          setItems(MOCK_DISPATCH_ITEMS);
        }
        setIsLive(data.isLiveFromFirestore);
        setIsSyncing(false);
      },
      (err) => {
        console.warn('FrostScore datasource notice:', err);
        setItems(MOCK_DISPATCH_ITEMS);
        setIsSyncing(false);
      }
    );

    return () => {
      if (typeof unsubscribe === 'function') unsubscribe();
    };
  }, []);

  // Compute metrics: 111 low, 12 medium, 5 high out of 128 (matches design)
  // If live data has items, we respect live counts or fallback to baseline design values
  const { lowCount, midCount, highCount, totalShipments } = useMemo(() => {
    if (isLive && items.length > 15) {
      const low = items.filter((i) => i.frostScore < 30).length;
      const mid = items.filter((i) => i.frostScore >= 30 && i.frostScore < 60).length;
      const high = items.filter((i) => i.frostScore >= 60).length;
      return {
        lowCount: low,
        midCount: mid,
        highCount: high,
        totalShipments: items.length,
      };
    }
    // Baseline official design values
    return {
      lowCount: 111,
      midCount: 12,
      highCount: 5,
      totalShipments: MOCK_METRICS.totalShipments, // 128
    };
  }, [items, isLive]);

  // Available regions for dropdown
  const availableRegions = useMemo(() => {
    const set = new Set<string>();
    items.forEach((item) => {
      if (item.origin && item.origin !== '-') set.add(item.origin);
    });
    PRIORITY_MOCK_ITEMS.forEach((item) => {
      if (item.origin && item.origin !== '-') set.add(item.origin);
    });
    return Array.from(set);
  }, [items]);

  // Combine items prioritizing batches needing review (score >= 30)
  const priorityPool: DispatchSummaryItem[] = useMemo(() => {
    // Unique by id or batchId
    const map = new Map<string, DispatchSummaryItem>();
    PRIORITY_MOCK_ITEMS.forEach((item) => map.set(item.batchId, item));
    items.forEach((item) => {
      if (item.frostScore >= 30) {
        map.set(item.batchId, item);
      }
    });
    return Array.from(map.values()).sort((a, b) => b.frostScore - a.frostScore);
  }, [items]);

  // Filter application
  const filteredPriorityItems = useMemo(() => {
    return priorityPool.filter((item) => {
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
      if (riskFilter !== 'Semua tingkat') {
        if (riskFilter.startsWith('Rendah') && item.frostScore >= 30) return false;
        if (riskFilter.startsWith('Perhatian') && (item.frostScore < 30 || item.frostScore >= 60)) return false;
        if (riskFilter.startsWith('Tinggi') && item.frostScore < 60) return false;
      }
      return true;
    });
  }, [priorityPool, dateFilter, regionFilter, statusFilter, riskFilter]);

  // Reset page when filters change
  useEffect(() => {
    setPage(1);
  }, [dateFilter, regionFilter, statusFilter, riskFilter]);

  // Pagination calculation
  const totalFilteredCount = filteredPriorityItems.length;
  const totalPages = Math.max(1, Math.ceil(totalFilteredCount / ITEMS_PER_PAGE));
  const startIndex = totalFilteredCount === 0 ? 0 : (page - 1) * ITEMS_PER_PAGE + 1;
  const endIndex = Math.min(page * ITEMS_PER_PAGE, totalFilteredCount);
  const paginatedItems = useMemo(() => {
    return filteredPriorityItems.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);
  }, [filteredPriorityItems, page]);

  const hasActiveFilter =
    dateFilter !== '1–22 Okt 2026' ||
    regionFilter !== 'Semua wilayah' ||
    statusFilter !== 'Semua status' ||
    riskFilter !== 'Semua tingkat';

  const handleResetFilters = () => {
    setDateFilter('1–22 Okt 2026');
    setRegionFilter('Semua wilayah');
    setStatusFilter('Semua status');
    setRiskFilter('Semua tingkat');
    setPage(1);
  };

  return (
    <div className="space-y-6">
      {/* Title & Synchronization Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
            FrostScore & indikator risiko
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Prioritaskan peninjauan perjalanan, bukan penetapan keamanan pangan.
          </p>
        </div>

        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">
            Kamis, 22 Oktober 2026 - WITA
          </div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>
              {isLive ? 'Realtime Database Live' : 'Data demonstrasi'} &bull; 22 Okt 2026, 10.42 WITA
            </span>
          </div>
        </div>
      </div>

      {/* Info Notice Banner */}
      <div className="rounded-2xl bg-sky-50/80 border border-sky-100 p-4 text-xs text-sky-950 flex items-start gap-3 shadow-2xs">
        <div className="h-5 w-5 rounded-full bg-sky-100 text-sky-600 flex items-center justify-center shrink-0 mt-0.5">
          <Info className="h-3.5 w-3.5" />
        </div>
        <div className="leading-relaxed">
          <span className="font-bold text-sky-900">Indikator risiko, bukan sertifikasi</span> &mdash;{' '}
          FrostScore bukan hasil laboratorium atau sertifikat keamanan pangan. Skala demonstrasi 0–100: makin tinggi skor, makin tinggi risiko operasional. Keputusan penerimaan tetap milik Distributor B.
        </div>
      </div>

      {/* Filter Row */}
      <div className="space-y-2">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {/* 1. Tanggal */}
          <div className="relative">
            <select
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className={SELECT_CLASS}
            >
              <option value="1–22 Okt 2026">Tanggal: 1–22 Okt 2026</option>
              <option value="Hari ini (22 Okt 2026)">Hari ini (22 Okt 2026)</option>
              <option value="Semua tanggal">Semua tanggal</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>

          {/* 2. Wilayah */}
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

          {/* 3. Status */}
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

          {/* 4. Risiko */}
          <div className="relative">
            <select
              value={riskFilter}
              onChange={(e) => setRiskFilter(e.target.value)}
              className={SELECT_CLASS}
            >
              <option value="Semua tingkat">Risiko: Semua tingkat</option>
              <option value="Rendah (0–29)">Rendah (0–29)</option>
              <option value="Perhatian (30–59)">Perlu perhatian (30–59)</option>
              <option value="Tinggi (60–100)">Tinggi (60–100)</option>
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

      {/* 3 Metrics Cards */}
      <FrostScoreMetricsCards
        lowCount={lowCount}
        midCount={midCount}
        highCount={highCount}
        totalCount={totalShipments}
      />

      {/* Middle Grid: Tren Risiko & Cara Membaca */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-stretch">
        <div className="lg:col-span-2">
          <RiskTrendCard
            dataPoints={MOCK_FROSTSCORE_POINTS}
            currentAverage={MOCK_METRICS.averageFrostScore}
            deltaLabel="Turun 6 poin"
          />
        </div>
        <div className="lg:col-span-1">
          <HowToReadFrostScoreCard />
        </div>
      </div>

      {/* Bottom Priority Review Table */}
      <PriorityReviewTable
        items={paginatedItems}
        currentPage={page}
        totalPages={totalPages}
        totalFilteredCount={totalFilteredCount}
        startIndex={startIndex}
        endIndex={endIndex}
        onPageChange={(p) => setPage(p)}
      />

      {/* Bottom Footer Notice */}
      {/* <div className="flex flex-wrap items-center justify-between gap-2 text-xs text-slate-400 pt-2 pb-6">
        <div>&copy; 2026 SMART-FROST &bull; Kabupaten Pangkep</div>
        <div>Data contoh untuk demonstrasi antarmuka</div>
      </div> */}
    </div>
  );
};
