import React from 'react';
import { ArrowRight, ChevronLeft, ChevronRight, Inbox } from 'lucide-react';
import type { DispatchSummaryItem } from '../../data/models/dashboard_types';
import { findCoolboxSuhu, type CoolboxSuhuState } from '../../data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator } from '../../domain/services/frost_score_calculator';

interface RecentDispatchesTableProps {
  items: DispatchSummaryItem[];
  currentPage: number;
  totalPages: number;
  totalFilteredCount: number;
  startIndex: number;
  endIndex: number;
  onPageChange: (page: number) => void;
  onSelectBatch?: (item: DispatchSummaryItem) => void;
  selectedBatchId?: string;
  suhuMap?: Record<string, CoolboxSuhuState>;
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
  selectedBatchId,
  suhuMap,
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
        <div className="overflow-x-auto scrollbar-thin">
          <table className="w-full min-w-[640px] text-left text-xs">
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
                const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, item.coolboxId) : null;
                const realTemp = boxSuhu?.latestAirTemp;
                const realTime = boxSuhu?.lastTimestampStr;

                // Ambil FrostScore dari kalkulasi RTDB /suhu atau dari Firestore
                const calculatedScore = boxSuhu?.frostScore?.score;
                const displayScore = calculatedScore != null ? calculatedScore : item.frostScore;
                const hasTelemetry = boxSuhu != null && (boxSuhu.dataPoints.length > 0 || boxSuhu.latestAirTemp != null);

                // Kategori dan style resmi SMART-FROST
                const scoreCategory = FrostScoreCalculator.getCategory(displayScore);
                const badgeStyle = FrostScoreCalculator.getBadgeStyle(displayScore);

                // Sync status style
                const isSynced = item.syncStatus === 'Tersinkron' || realTemp != null;
                const isSelected = selectedBatchId ? (item.batchId === selectedBatchId || item.id === selectedBatchId) : false;

                return (
                  <tr
                    key={item.id}
                    onClick={() => onSelectBatch?.(item)}
                    className={`transition-colors cursor-pointer group ${
                      isSelected
                        ? 'bg-sky-50/80 ring-1 ring-inset ring-sky-300'
                        : 'hover:bg-slate-50/70'
                    }`}
                  >
                    {/* Batch / Muatan */}
                    <td className="py-3.5 px-5">
                      <div className="flex items-center gap-1.5 font-bold text-sky-600 font-mono tracking-tight group-hover:underline">
                        <span>{item.batchId}</span>
                        {isSelected && (
                          <span className="text-[9px] font-bold text-sky-700 bg-sky-100/90 border border-sky-300/60 px-1.5 py-0.5 rounded-full font-sans">
                            Terpilih
                          </span>
                        )}
                      </div>
                      <div className="text-[11px] text-slate-600 mt-0.5">
                        {item.commodity} &bull; {item.weightDisplay || `${item.weightKg} kg`}
                      </div>
                      <div className="text-[10px] text-slate-400 font-mono mt-0.5">
                        {boxSuhu?.coolboxId || item.coolboxId}
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

                    {/* Suhu Terakhir (Suhu valid dari tabel /suhu) */}
                    <td className="py-3.5 px-5">
                      {realTemp != null ? (
                        <>
                          <div className="font-bold text-slate-900 font-mono flex items-center gap-1.5">
                            <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                            <span>{realTemp.toFixed(1).replace('.', ',')} &deg;C</span>
                          </div>
                          <div className="text-[11px] text-slate-400 mt-0.5">
                            {realTime || item.lastTempTime}
                          </div>
                        </>
                      ) : (
                        <>
                          <div className="font-medium text-slate-400 text-xs flex items-center gap-1.5">
                            <span className="h-1.5 w-1.5 rounded-full bg-slate-300" />
                            <span>Menunggu sensor</span>
                          </div>
                          <div className="text-[11px] text-slate-400 mt-0.5">
                            Coldbox siap kirim
                          </div>
                        </>
                      )}
                    </td>

                    {/* FrostScore (Rumus Resmi PDF: 90-100 Sangat Baik, 75-89 Baik, 60-74 Waspada, <60 Risiko Tinggi) */}
                    <td className="py-3.5 px-5">
                      {!hasTelemetry && (item.frostScore === 0 || item.frostScore == null) ? (
                        <div className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[10.5px] font-semibold border bg-slate-50 text-slate-600 border-slate-200/60">
                          <span className="h-1.5 w-1.5 rounded-full bg-slate-400" />
                          <span>Menunggu sensor</span>
                        </div>
                      ) : (
                        <div className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[10.5px] font-semibold border ${badgeStyle.badgeClass}`}>
                          <span className={`h-1.5 w-1.5 rounded-full ${badgeStyle.dotClass}`} />
                          <span>{displayScore} &bull; {scoreCategory}</span>
                        </div>
                      )}
                    </td>

                    {/* Sinkronisasi */}
                    <td className="py-3.5 px-5">
                      <div className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[10.5px] font-medium border ${
                        isSynced 
                          ? 'bg-slate-50 text-slate-600 border-slate-200/80' 
                          : 'bg-amber-50 text-amber-700 border-amber-200/80'
                      }`}>
                        <span className={`h-1.5 w-1.5 rounded-full ${
                          isSynced ? 'bg-emerald-500' : 'bg-amber-500'
                        }`} />
                        <span>{isSynced ? 'Tersinkron' : item.syncStatus}</span>
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
