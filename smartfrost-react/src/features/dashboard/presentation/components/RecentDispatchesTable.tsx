import React from 'react';
import { ArrowRight, ChevronLeft, ChevronRight, Inbox } from 'lucide-react';
import type { DispatchSummaryItem } from '../../data/models/dashboard_types';

interface RecentDispatchesTableProps {
  items: DispatchSummaryItem[];
  currentPage: number;
  totalPages: number;
  totalFilteredCount: number;
  startIndex: number;
  endIndex: number;
  onPageChange: (page: number) => void;
  onSelectBatch?: (item: DispatchSummaryItem) => void;
  title?: string;
  showViewAll?: boolean;
}

export const RecentDispatchesTable: React.FC<RecentDispatchesTableProps> = ({
  items,
  currentPage,
  totalPages,
  totalFilteredCount,
  startIndex,
  endIndex,
  onPageChange,
  onSelectBatch,
  title = 'Perjalanan terkini',
  showViewAll = true,
}) => {
  // Generate array of page numbers
  const pageNumbers = Array.from({ length: totalPages }, (_, i) => i + 1);

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 shadow-2xs overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between p-5 border-b border-slate-100">
        <div className="flex items-center gap-2">
          <h3 className="text-sm font-bold text-slate-900">
            {title}
          </h3>
          <span className="rounded-full bg-slate-100 px-2.5 py-0.5 text-[10px] font-bold text-slate-600">
            {totalFilteredCount} batch
          </span>
        </div>
        {showViewAll && (
          <button
            type="button"
            onClick={() => onPageChange(1)}
            className="inline-flex items-center gap-1 text-xs font-semibold text-sky-600 hover:text-sky-700 transition-colors cursor-pointer"
          >
            <span>Semua distribusi</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </button>
        )}
      </div>

      {/* Table Content */}
      {items.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-14 px-4 text-center">
          <div className="h-10 w-10 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mb-2">
            <Inbox className="h-5 w-5" />
          </div>
          <p className="text-xs font-bold text-slate-700">Tidak ada pengiriman yang sesuai filter</p>
          <p className="text-[11px] text-slate-400 mt-0.5">Coba ubah opsi filter tanggal, wilayah, status, atau tingkat risiko.</p>
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
                // FrostScore pill style
                let scoreBadge = 'bg-emerald-50 text-emerald-700 border-emerald-200/60';
                let scoreDot = 'bg-emerald-500';
                if (item.riskLevel === 'Perhatian') {
                  scoreBadge = 'bg-amber-50 text-amber-700 border-amber-200/60';
                  scoreDot = 'bg-amber-500';
                } else if (item.riskLevel === 'Tinggi') {
                  scoreBadge = 'bg-rose-50 text-rose-700 border-rose-200/60';
                  scoreDot = 'bg-rose-500';
                }

                // Sync status style
                const isSynced = item.syncStatus === 'Tersinkron';

                return (
                  <tr
                    key={item.id}
                    onClick={() => onSelectBatch?.(item)}
                    className="hover:bg-slate-50/70 transition-colors cursor-pointer group"
                  >
                    {/* Batch / Muatan */}
                    <td className="py-3.5 px-5">
                      <div className="font-bold text-sky-600 font-mono tracking-tight group-hover:underline">
                        {item.batchId}
                      </div>
                      <div className="text-[11px] text-slate-500 mt-0.5">
                        {item.commodity} &bull; {item.weightKg} kg
                      </div>
                    </td>

                    {/* Rute ke Pangkajene */}
                    <td className="py-3.5 px-5">
                      <div className="font-medium text-slate-800 flex items-center gap-1.5">
                        <span>{item.origin}</span>
                        <ArrowRight className="h-3 w-3 text-slate-400" />
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5">
                        {item.destination} &bull; {item.dateStr}
                      </div>
                    </td>

                    {/* Suhu Terakhir */}
                    <td className="py-3.5 px-5">
                      <div className="font-bold text-slate-900 font-mono">
                        {item.lastTemp.toFixed(1).replace('.', ',')} &deg;C
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5">
                        {item.lastTempTime}
                      </div>
                    </td>

                    {/* FrostScore */}
                    <td className="py-3.5 px-5">
                      <div className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[10.5px] font-semibold border ${scoreBadge}`}>
                        <span className={`h-1.5 w-1.5 rounded-full ${scoreDot}`} />
                        <span>{item.frostScore} &bull; {item.riskLevel}</span>
                      </div>
                    </td>

                    {/* Sinkronisasi */}
                    <td className="py-3.5 px-5">
                      <div className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[10.5px] font-medium border ${
                        isSynced 
                          ? 'bg-slate-50 text-slate-600 border-slate-200/80' 
                          : 'bg-amber-50 text-amber-700 border-amber-200/80'
                      }`}>
                        <span className={`h-1.5 w-1.5 rounded-full ${
                          isSynced ? 'bg-slate-400' : 'bg-amber-500'
                        }`} />
                        <span>{item.syncStatus}</span>
                      </div>
                    </td>

                    {/* Status Operasional */}
                    <td className="py-3.5 px-5">
                      <div className="inline-flex items-center gap-1 font-semibold text-sky-600 hover:text-sky-700 text-xs">
                        <span>{item.operationalStatus}</span>
                        <ArrowRight className="h-3 w-3" />
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
      {totalFilteredCount > 0 && (
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3 p-4 border-t border-slate-100 text-xs text-slate-500">
          <div>
            {startIndex}&ndash;{endIndex} dari {totalFilteredCount} pengiriman
          </div>

          <div className="flex items-center gap-1.5 select-none">
            {/* Tombol Sebelumnya */}
            <button
              type="button"
              disabled={currentPage <= 1}
              onClick={() => onPageChange(currentPage - 1)}
              className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg border transition-colors ${
                currentPage <= 1
                  ? 'border-slate-100 bg-slate-50 text-slate-300 cursor-not-allowed'
                  : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50 cursor-pointer shadow-2xs'
              }`}
            >
              <ChevronLeft className="h-3.5 w-3.5" />
              <span>Sebelumnya</span>
            </button>
            
            {/* Nomor Halaman */}
            {pageNumbers.map((num) => {
              const isActive = num === currentPage;
              return (
                <button
                  key={num}
                  type="button"
                  onClick={() => onPageChange(num)}
                  className={`h-7 w-7 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center justify-center ${
                    isActive
                      ? 'bg-sky-600 text-white shadow-2xs'
                      : 'border border-slate-200 bg-white text-slate-600 hover:bg-slate-50'
                  }`}
                >
                  {num}
                </button>
              );
            })}

            {/* Tombol Berikutnya */}
            <button
              type="button"
              disabled={currentPage >= totalPages}
              onClick={() => onPageChange(currentPage + 1)}
              className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg border transition-colors ${
                currentPage >= totalPages
                  ? 'border-slate-100 bg-slate-50 text-slate-300 cursor-not-allowed'
                  : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50 cursor-pointer shadow-2xs'
              }`}
            >
              <span>Berikutnya</span>
              <ChevronRight className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
