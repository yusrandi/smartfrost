import React from 'react';
import { ChevronLeft, ChevronRight, Inbox } from 'lucide-react';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';
import { findCoolboxSuhu, type CoolboxSuhuState } from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator } from '../../../dashboard/domain/services/frost_score_calculator';

interface PriorityReviewTableProps {
  items: DispatchSummaryItem[];
  currentPage: number;
  totalPages: number;
  totalFilteredCount: number;
  startIndex: number;
  endIndex: number;
  onPageChange: (page: number) => void;
  onSelectBatch?: (item: DispatchSummaryItem) => void;
  suhuMap?: Record<string, CoolboxSuhuState>;
  title?: string;
  subtitle?: string;
}

export const PriorityReviewTable: React.FC<PriorityReviewTableProps> = ({
  items,
  currentPage,
  totalPages,
  totalFilteredCount,
  startIndex,
  endIndex,
  onPageChange,
  onSelectBatch,
  suhuMap,
  title = 'Batch prioritas peninjauan',
  subtitle,
}) => {
  const pageNumbers = Array.from({ length: totalPages }, (_, i) => i + 1);

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 shadow-2xs overflow-hidden">
      {/* Header */}
      <div className="p-5 border-b border-slate-100">
        <h3 className="text-base font-bold text-slate-900">{title}</h3>
        <p className="text-xs text-slate-500 mt-0.5">
          {subtitle ?? `${totalFilteredCount} batch prioritas • Skor < 75 atau data tertunda`}
        </p>
      </div>

      {/* Table Content */}
      {items.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-14 px-4 text-center">
          <div className="h-10 w-10 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mb-2">
            <Inbox className="h-5 w-5" />
          </div>
          <p className="text-xs font-bold text-slate-700">Tidak ada batch prioritas pada filter ini</p>
          <p className="text-[11px] text-slate-400 mt-0.5">
            Semua pengiriman dalam batas aman atau sesuaikan parameter filter di atas.
          </p>
        </div>
      ) : (
        <div className="overflow-x-auto scrollbar-thin">
          <table className="w-full min-w-[640px] text-left text-xs">
            <thead>
              <tr className="bg-slate-50/70 border-b border-slate-100 text-[11px] font-bold text-slate-500">
                <th className="py-3 px-5">Batch / muatan</th>
                <th className="py-3 px-5">Rute ke Pangkajene</th>
                <th className="py-3 px-5">Suhu sensor terkini</th>
                <th className="py-3 px-5">FrostScore mutu</th>
                <th className="py-3 px-5">Sinkronisasi</th>
                <th className="py-3 px-5">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((item) => {
                const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, item.coolboxId) : null;
                const realTemp = boxSuhu?.latestAirTemp;
                const score = boxSuhu?.frostScore?.score ?? item.frostScore;
                const category = FrostScoreCalculator.getCategory(score);
                const badgeStyle = FrostScoreCalculator.getBadgeStyle(score);

                // Sync status style
                const isSynced = item.syncStatus === 'Tersinkron' || realTemp != null;

                // Operational Status style
                const statusStyles: Record<string, string> = {
                  Menunggu: 'text-amber-600',
                  Perjalanan: 'text-sky-600',
                  Diperiksa: 'text-purple-600',
                  Diterima: 'text-emerald-600',
                  Ditolak: 'text-rose-600',
                };
                const statusColor = statusStyles[item.operationalStatus] || 'text-slate-600';

                return (
                  <tr
                    key={item.id}
                    onClick={() => onSelectBatch?.(item)}
                    className="hover:bg-slate-50/70 transition-colors cursor-pointer group"
                  >
                    {/* 1. Batch & Muatan */}
                    <td className="py-3.5 px-5">
                      <div className="font-extrabold text-sky-600 group-hover:text-sky-700 font-mono">
                        {item.batchId}
                      </div>
                      <div className="text-[11px] text-slate-600 mt-0.5">
                        {item.commodity} &bull; {item.weightDisplay || `${item.weightKg} kg`}
                      </div>
                      <div className="text-[10px] text-slate-400 font-mono mt-0.5">
                        {boxSuhu?.coolboxId || item.coolboxId}
                      </div>
                    </td>

                    {/* 2. Rute */}
                    <td className="py-3.5 px-5">
                      <div className="font-semibold text-slate-800">
                        {item.origin} &rarr; {item.destination}
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5">
                        {item.dateStr.includes('•') ? item.dateStr.split('•')[0].trim() : item.dateStr}
                      </div>
                    </td>

                    {/* 3. Suhu Terakhir valid dari /suhu */}
                    <td className="py-3.5 px-5">
                      {realTemp != null ? (
                        <>
                          <div className="font-bold text-slate-900 font-mono flex items-center gap-1.5">
                            <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                            <span>{realTemp.toFixed(1).replace('.', ',')} &deg;C</span>
                          </div>
                          <div className="text-[11px] text-slate-400 mt-0.5">
                            {boxSuhu?.lastTimestampStr || item.lastTempTime}
                          </div>
                        </>
                      ) : (
                        <>
                          <div className="font-bold text-slate-900 font-mono">
                            {item.lastTemp.toFixed(1).replace('.', ',')} &deg;C
                          </div>
                          <div className="text-[11px] text-slate-400 mt-0.5 font-mono">
                            {item.lastTempTime}
                          </div>
                        </>
                      )}
                    </td>

                    {/* 4. FrostScore Pill */}
                    <td className="py-3.5 px-5">
                      <span
                        className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[11px] font-bold border ${badgeStyle.badgeClass}`}
                      >
                        <span className={`h-1.5 w-1.5 rounded-full ${badgeStyle.dotClass}`} />
                        <span>
                          {score} &bull; {category}
                        </span>
                      </span>
                    </td>

                    {/* 5. Sinkronisasi */}
                    <td className="py-3.5 px-5">
                      <div className="inline-flex items-center gap-1.5 text-xs text-slate-600 font-medium">
                        <span
                          className={`h-2 w-2 rounded-full ${
                            isSynced ? 'bg-emerald-500' : 'bg-amber-500'
                          }`}
                        />
                        <span className={isSynced ? 'text-slate-600' : 'text-amber-700 font-semibold'}>
                          {isSynced ? 'Tersinkron' : item.syncStatus}
                        </span>
                      </div>
                    </td>

                    {/* 6. Status */}
                    <td className="py-3.5 px-5">
                      <div className={`inline-flex items-center gap-1 font-bold ${statusColor}`}>
                        <span>{item.operationalStatus}</span>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination Footer */}
      {totalPages > 1 && (
        <div className="p-4 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
          <div>
            Menampilkan <span className="font-bold text-slate-800">{startIndex}</span>&ndash;
            <span className="font-bold text-slate-800">{endIndex}</span> dari{' '}
            <span className="font-bold text-slate-800">{totalFilteredCount}</span> batch prioritas
          </div>

          <div className="flex items-center gap-1">
            <button
              type="button"
              disabled={currentPage <= 1}
              onClick={() => onPageChange(currentPage - 1)}
              className="p-1.5 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>

            {pageNumbers.map((num) => (
              <button
                key={num}
                type="button"
                onClick={() => onPageChange(num)}
                className={`h-8 w-8 rounded-lg font-bold transition-all cursor-pointer ${
                  num === currentPage
                    ? 'bg-sky-600 text-white'
                    : 'text-slate-600 hover:bg-slate-100 border border-slate-200'
                }`}
              >
                {num}
              </button>
            ))}

            <button
              type="button"
              disabled={currentPage >= totalPages}
              onClick={() => onPageChange(currentPage + 1)}
              className="p-1.5 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
