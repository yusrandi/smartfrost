import React from 'react';
import { ChevronLeft, ChevronRight, Inbox } from 'lucide-react';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';

interface PriorityReviewTableProps {
  items: DispatchSummaryItem[];
  currentPage: number;
  totalPages: number;
  totalFilteredCount: number;
  startIndex: number;
  endIndex: number;
  onPageChange: (page: number) => void;
  onSelectBatch?: (item: DispatchSummaryItem) => void;
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
          {subtitle ?? `${totalFilteredCount} batch memiliki skor ≥30 • termasuk data terakhir yang tertunda`}
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
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-slate-50/70 border-b border-slate-100 text-[11px] font-bold text-slate-500">
                <th className="py-3 px-5">Batch / muatan</th>
                <th className="py-3 px-5">Rute ke Pangkajene</th>
                <th className="py-3 px-5">Suhu terakhir</th>
                <th className="py-3 px-5">FrostScore</th>
                <th className="py-3 px-5">Sinkronisasi</th>
                <th className="py-3 px-5">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {items.map((item) => {
                // FrostScore Pill Style
                let scoreBadge = 'bg-emerald-50 text-emerald-700 border-emerald-200/60';
                let scoreDot = 'bg-emerald-500';
                let scoreLabel = 'Rendah';

                if (item.frostScore >= 60 || item.riskLevel === 'Tinggi') {
                  scoreBadge = 'bg-rose-50 text-rose-700 border-rose-200/60';
                  scoreDot = 'bg-rose-500';
                  scoreLabel = 'Tinggi';
                } else if (item.frostScore >= 30 || item.riskLevel === 'Perhatian') {
                  scoreBadge = 'bg-amber-50 text-amber-700 border-amber-200/60';
                  scoreDot = 'bg-amber-500';
                  scoreLabel = 'Perhatian';
                }

                // Sync status style
                const isSynced = item.syncStatus === 'Tersinkron';

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
                      <div className="font-extrabold text-sky-600 group-hover:text-sky-700">
                        {item.batchId}
                      </div>
                      <div className="text-[11px] text-slate-500 mt-0.5">
                        {item.commodity} &bull; {item.weightKg} kg
                      </div>
                    </td>

                    {/* 2. Rute */}
                    <td className="py-3.5 px-5">
                      <div className="font-semibold text-slate-800">
                        {item.origin} &rarr;
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5">
                        {item.destination} &bull; {item.dateStr.includes('•') ? item.dateStr.split('•')[0].trim() : item.dateStr}
                      </div>
                    </td>

                    {/* 3. Suhu Terakhir */}
                    <td className="py-3.5 px-5">
                      <div className="font-bold text-slate-900">
                        {item.lastTemp.toFixed(1).replace('.', ',')} &deg;C
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5 font-mono">
                        {item.lastTempTime}
                      </div>
                    </td>

                    {/* 4. FrostScore Pill */}
                    <td className="py-3.5 px-5">
                      <span
                        className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[11px] font-bold border ${scoreBadge}`}
                      >
                        <span className={`h-1.5 w-1.5 rounded-full ${scoreDot}`} />
                        <span>
                          {item.frostScore} &bull; {scoreLabel}
                        </span>
                      </span>
                    </td>

                    {/* 5. Sinkronisasi */}
                    <td className="py-3.5 px-5">
                      <div className="inline-flex items-center gap-1.5 text-xs text-slate-600 font-medium">
                        <span
                          className={`h-2 w-2 rounded-full ${
                            isSynced ? 'bg-slate-400' : 'bg-amber-500'
                          }`}
                        />
                        <span className={isSynced ? 'text-slate-600' : 'text-amber-700 font-semibold'}>
                          {item.syncStatus}
                        </span>
                      </div>
                    </td>

                    {/* 6. Status */}
                    <td className="py-3.5 px-5">
                      <div className={`inline-flex items-center gap-1 font-bold ${statusColor}`}>
                        <span>{item.operationalStatus}</span>
                        <span className="text-[10px]">&rarr;</span>
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
      <div className="flex flex-wrap items-center justify-between gap-4 p-4 border-t border-slate-100 text-xs text-slate-500 bg-slate-50/30">
        <div>
          {totalFilteredCount === 0 ? (
            '0 dari 0 batch'
          ) : (
            <>
              {startIndex}–{endIndex} dari {totalFilteredCount} batch perhatian / tinggi
            </>
          )}
        </div>

        <div className="flex items-center gap-1.5">
          <button
            type="button"
            disabled={currentPage === 1}
            onClick={() => onPageChange(currentPage - 1)}
            className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg border border-slate-200 bg-white font-semibold text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors cursor-pointer"
          >
            <ChevronLeft className="h-3.5 w-3.5" />
            <span>Sebelumnya</span>
          </button>

          <div className="flex items-center gap-1 px-1">
            {pageNumbers.map((p) => (
              <button
                key={p}
                type="button"
                onClick={() => onPageChange(p)}
                className={`h-7 w-7 rounded-lg text-xs font-bold transition-colors cursor-pointer ${
                  currentPage === p
                    ? 'bg-sky-50 text-sky-700 border border-sky-200'
                    : 'text-slate-600 hover:bg-slate-100'
                }`}
              >
                {p}
              </button>
            ))}
          </div>

          <button
            type="button"
            disabled={currentPage === totalPages || totalPages === 0}
            onClick={() => onPageChange(currentPage + 1)}
            className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg border border-slate-200 bg-white font-semibold text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors cursor-pointer"
          >
            <span>Berikutnya</span>
            <ChevronRight className="h-3.5 w-3.5" />
          </button>
        </div>
      </div>
    </div>
  );
};

