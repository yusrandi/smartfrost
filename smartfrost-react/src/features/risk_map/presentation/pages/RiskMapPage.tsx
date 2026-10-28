import React, { useEffect, useMemo, useState } from 'react';
import { AlertTriangle, ChevronDown, RefreshCw, RotateCcw } from 'lucide-react';
import {
  DashboardRtdbDatasource,
  findCoolboxSuhu,
  type CoolboxSuhuState,
} from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator } from '../../../dashboard/domain/services/frost_score_calculator';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import {
  DistributorRtdbDatasource,
  type RtdbDistributor,
} from '../../data/datasources/distributor_rtdb_datasource';
import { aggregateDistributorsRisk } from '../../data/utils/risk_aggregator';
import { RiskMetricsCards } from '../components/RiskMetricsCards';
import { RegionalRiskMapCard } from '../components/RegionalRiskMapCard';
import { PriorityRegionsCard } from '../components/PriorityRegionsCard';
import { SelectedRegionDetailCard } from '../components/SelectedRegionDetailCard';

const SELECT_CLASS =
  'w-full appearance-none rounded-xl bg-white border border-slate-200/80 px-4 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer';

export const RiskMapPage: React.FC = () => {
  const [distributors, setDistributors] = useState<RtdbDistributor[]>([]);
  const [items, setItems] = useState<DispatchSummaryItem[]>([]);
  const [suhuMap, setSuhuMap] = useState<Record<string, CoolboxSuhuState>>({});
  const [isLive, setIsLive] = useState<boolean>(false);
  const [isSyncing, setIsSyncing] = useState<boolean>(true);
  const [selectedRegionId, setSelectedRegionId] = useState<string>('');

  // Filters
  const [dateFilter, setDateFilter] = useState<string>('Semua tanggal');
  const [regionFilter, setRegionFilter] = useState<string>('Semua wilayah');
  const [statusFilter, setStatusFilter] = useState<string>('Semua status');
  const [riskFilter, setRiskFilter] = useState<string>('Semua tingkat');

  // 1. Subscribe to real `distributors` table in Firebase Realtime Database
  useEffect(() => {
    const unsubDistributors = DistributorRtdbDatasource.subscribeToDistributors(
      (list, liveStatus) => {
        setDistributors(list);
        if (liveStatus) setIsLive(true);
      },
      (err) => {
        console.warn('Distributors datasource notice:', err);
      }
    );

    // 2. Subscribe to real `dispatches` table in Firebase Realtime Database
    const unsubDispatches = DashboardRtdbDatasource.subscribeToDashboardData(
      (data) => {
        setItems(data.items);
        setIsLive(data.isLiveFromFirestore);
        setIsSyncing(false);
      },
      (err) => {
        console.warn('Dispatches datasource notice:', err);
        setIsSyncing(false);
      }
    );

    // 3. Subscribe to real `suhu` table for live cold-chain telemetry
    const unsubSuhu = DashboardRtdbDatasource.subscribeToSuhuData(
      (map) => {
        setSuhuMap(map);
      },
      (err) => {
        console.warn('RiskMap suhu RTDB notice:', err);
      }
    );

    return () => {
      if (typeof unsubDistributors === 'function') unsubDistributors();
      if (typeof unsubDispatches === 'function') unsubDispatches();
      if (typeof unsubSuhu === 'function') unsubSuhu();
    };
  }, []);

  // Filter distribution batches based on active dropdown controls
  const filteredItems = useMemo(() => {
    return items.filter((item) => {
      if (dateFilter === 'Hari ini (22 Okt 2026)' && !item.dateStr.includes('22 Okt')) {
        return false;
      }
      if (regionFilter !== 'Semua wilayah') {
        const matchesOrigin = item.origin.toLowerCase().includes(regionFilter.toLowerCase());
        if (!matchesOrigin) return false;
      }
      if (statusFilter !== 'Semua status' && item.operationalStatus.toLowerCase() !== statusFilter.toLowerCase()) {
        return false;
      }

      if (riskFilter !== 'Semua tingkat') {
        const boxSuhu = findCoolboxSuhu(suhuMap, item.coolboxId);
        const score = boxSuhu?.frostScore?.score ?? item.frostScore;
        const cat = FrostScoreCalculator.getCategory(score);
        if (riskFilter === 'Sangat Baik' && cat !== 'Sangat Baik') return false;
        if (riskFilter === 'Baik' && cat !== 'Baik') return false;
        if (riskFilter === 'Waspada' && cat !== 'Waspada') return false;
        if (riskFilter === 'Risiko Tinggi' && cat !== 'Risiko Tinggi') return false;
      }

      return true;
    });
  }, [items, dateFilter, regionFilter, statusFilter, riskFilter, suhuMap]);

  // Dynamically compute regional risk summaries from pure RTDB `distributors` correlated with `dispatches` and `/suhu`
  const regions = useMemo(() => {
    return aggregateDistributorsRisk(distributors, filteredItems, suhuMap);
  }, [distributors, filteredItems, suhuMap]);

  // Keep selected region valid
  useEffect(() => {
    if (regions.length > 0 && (!selectedRegionId || !regions.some((r) => r.id === selectedRegionId))) {
      setSelectedRegionId(regions[0].id);
    }
  }, [regions, selectedRegionId]);

  // Distinct sender regions from real items & distributor origins
  const availableOrigins = useMemo(() => {
    const set = new Set<string>();
    items.forEach((item) => {
      if (item.origin && item.origin !== '-') set.add(item.origin);
    });
    distributors.forEach((d) => {
      const name = d.name || d.storeLocation;
      if (name && !name.toLowerCase().includes('pangkajene')) {
        set.add(name);
      }
    });
    return Array.from(set);
  }, [items, distributors]);

  // Currently selected region
  const selectedRegion = useMemo(() => {
    return regions.find((r) => r.id === selectedRegionId) ?? regions[0];
  }, [regions, selectedRegionId]);

  // Derived metrics from real database distributor data
  const coveredRegionsCount = regions.length;

  const priorityRegionsCount = useMemo(() => {
    return regions.filter((r) => r.highRiskCount > 0 || r.mediumRiskCount > 0).length;
  }, [regions]);

  const priorityRegionsText = useMemo(() => {
    const highRiskRegions = regions.filter((r) => r.highRiskCount > 0);
    if (highRiskRegions.length >= 2) {
      return `${highRiskRegions[0].name} dan ${highRiskRegions[1].name}`;
    }
    if (highRiskRegions.length === 1) {
      return highRiskRegions[0].name;
    }
    const warnRegions = regions.filter((r) => r.mediumRiskCount > 0);
    if (warnRegions.length > 0) {
      return warnRegions[0].name;
    }
    if (regions.length > 0) {
      return 'Semua wilayah aman';
    }
    return 'Belum ada data';
  }, [regions]);

  const delayedBatches = useMemo(() => {
    return items.filter((b) => b.syncStatus === 'Tertunda');
  }, [items]);
  const delayedBatchesCount = delayedBatches.length;
  const delayedSample = delayedBatches[0];

  const totalBatchCount = items.length;

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
  };

  const today = new Date().toLocaleDateString('id-ID', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  return (
    <div className="space-y-6">
      {/* Title & Synchronization Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
            Peta risiko distribusi
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Pola risiko berdasarkan data pangkalan distributor resmi dari Realtime Database & telemetri IoT.
          </p>
        </div>

        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">
            {today} - WITA
          </div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>
              {isLive
                ? `Realtime Database Live (${distributors.length} distributor • ${items.length} batch)`
                : 'Memuat data...'}
            </span>
          </div>
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
              <option value="Semua tanggal">Semua tanggal</option>
              <option value="Hari ini (22 Okt 2026)">Hari ini (22 Okt 2026)</option>
              <option value="1–22 Okt 2026">1–22 Okt 2026</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>

          {/* 2. Wilayah */}
          <div className="relative">
            <select
              value={regionFilter}
              onChange={(e) => {
                const val = e.target.value;
                setRegionFilter(val);
                if (val !== 'Semua wilayah') {
                  const match = regions.find(
                    (r) => r.name.toLowerCase() === val.toLowerCase()
                  );
                  if (match) setSelectedRegionId(match.id);
                }
              }}
              className={SELECT_CLASS}
            >
              <option value="Semua wilayah">Wilayah: Semua wilayah</option>
              {availableOrigins.map((orig) => (
                <option key={orig} value={orig}>
                  {orig}
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
              <option value="Semua tingkat">Tingkat Mutu: Semua tingkat</option>
              <option value="Sangat Baik">Sangat Baik (Skor ≥90)</option>
              <option value="Baik">Baik (Skor 75–89)</option>
              <option value="Waspada">Waspada (Skor 60–74)</option>
              <option value="Risiko Tinggi">Risiko Tinggi (Skor &lt;60)</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
          </div>
        </div>

        {hasActiveFilter && (
          <div className="flex items-center justify-between text-xs pt-1 px-1">
            <span className="text-slate-500">
              Menampilkan {regions.length} wilayah distributor hasil filter
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

      {/* Top 3 Summary Metrics Cards */}
      <RiskMetricsCards
        coveredRegionsCount={coveredRegionsCount}
        priorityRegionsCount={priorityRegionsCount}
        priorityRegionsText={priorityRegionsText}
        delayedBatchesCount={delayedBatchesCount}
      />

      {/* Main Grid: Left Map & Right Detail Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-stretch">
        {/* Left 2/3: Interactive Map */}
        <div className="lg:col-span-2">
          <RegionalRiskMapCard
            regions={regions}
            selectedId={selectedRegionId}
            onSelect={(id) => setSelectedRegionId(id)}
            totalBatchCount={totalBatchCount}
          />
        </div>

        {/* Right 1/3: Priority List & Selected Detail */}
        <div className="lg:col-span-1 flex flex-col gap-4">
          <PriorityRegionsCard
            regions={regions}
            selectedId={selectedRegionId}
            onSelect={(id) => setSelectedRegionId(id)}
          />

          {selectedRegion && <SelectedRegionDetailCard region={selectedRegion} />}
        </div>
      </div>

      {/* Bottom Alert Notice: Lokasi Tidak Lengkap */}
      {delayedBatchesCount > 0 && (
        <div className="rounded-2xl bg-amber-50/90 border border-amber-200/80 p-4 text-xs text-amber-950 flex items-start gap-3 shadow-2xs">
          <div className="h-5 w-5 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center shrink-0 mt-0.5">
            <AlertTriangle className="h-3.5 w-3.5" />
          </div>
          <div className="leading-relaxed">
            <span className="font-extrabold text-amber-900">
              Lokasi tidak lengkap pada {delayedBatchesCount} batch
            </span>{' '}
            &mdash; GPS terakhir {delayedSample ? `${delayedSample.batchId}: ${delayedSample.lastTempTime}` : '-'}. Lokasi baru belum tersedia. Agregat tetap memuat data terakhir dan ditandai tertunda.
          </div>
        </div>
      )}
    </div>
  );
};
