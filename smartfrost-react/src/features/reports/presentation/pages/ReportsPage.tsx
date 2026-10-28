import React, { useEffect, useMemo, useState } from 'react';
import { Download, RefreshCw } from 'lucide-react';
import { DashboardRtdbDatasource } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { MOCK_DISPATCH_ITEMS } from '../../../dashboard/data/mock/dashboard_mock_data';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import { ReportPreviewCard } from '../components/ReportPreviewCard';
import { SavedReportsCard } from '../components/SavedReportsCard';
import { ExportReportModal } from '../components/ExportReportModal';

export const ReportsPage: React.FC = () => {
  const [items, setItems] = useState<DispatchSummaryItem[]>(MOCK_DISPATCH_ITEMS);
  const [isLive, setIsLive] = useState<boolean>(false);
  const [isSyncing, setIsSyncing] = useState<boolean>(true);
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

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
        console.warn('Reports datasource notice:', err);
        setItems(MOCK_DISPATCH_ITEMS);
        setIsSyncing(false);
      }
    );

    return () => {
      if (typeof unsubscribe === 'function') unsubscribe();
    };
  }, []);

  const availableRegions = useMemo(() => {
    const set = new Set<string>();
    items.forEach((item) => {
      if (item.origin && item.origin !== '-') set.add(item.origin);
    });
    return Array.from(set);
  }, [items]);

  return (
    <div className="space-y-6">
      {/* Title & Synchronization Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">
            Laporan distribusi
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Susun ringkasan pemantauan dengan sumber dan kelengkapan data yang transparan.
          </p>
        </div>

        <div className="text-left sm:text-right space-y-1">
          <div className="text-xs text-slate-600 font-medium">
            Kamis, 22 Oktober 2026 - WITA
          </div>
          <div className="inline-flex items-center gap-1.5 text-[11px] text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full border border-teal-200/60 font-medium">
            <RefreshCw className={`h-3 w-3 text-teal-600 ${isSyncing ? 'animate-spin' : ''}`} />
            <span>
              {isLive ? `Realtime Database Live (${items.length} batch)` : 'Data demonstrasi'} &bull; 22 Okt 2026, 10.42 WITA
            </span>
          </div>
        </div>
      </div>

      {/* Main Report Document Preview Card */}
      <ReportPreviewCard items={items} isLive={isLive} />

      {/* Primary Export Action (Only One Export Button) */}
      <div className="flex items-center justify-end">
        <button
          type="button"
          onClick={() => setIsModalOpen(true)}
          className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 py-3 px-8 rounded-2xl bg-[#0284C7] hover:bg-sky-700 text-white font-extrabold text-sm shadow-sm hover:shadow-md transition-all cursor-pointer"
        >
          <Download className="h-4 w-4" />
          <span>Export</span>
        </button>
      </div>

      {/* Saved Reports Section */}
      <SavedReportsCard />

      {/* Export Configuration Modal (Opens Dialog on Click) */}
      <ExportReportModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        items={items}
        availableRegions={availableRegions}
      />

      {/* Bottom Footer Notice */}
      <div className="flex flex-wrap items-center justify-between gap-2 text-xs text-slate-400 pt-2 pb-6">
        <div>&copy; 2026 SMART-FROST &bull; Kabupaten Pangkep</div>
        <div>Data contoh untuk demonstrasi antarmuka</div>
      </div>
    </div>
  );
};
