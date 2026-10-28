import React from 'react';
import { Download, FileText } from 'lucide-react';
import {
  findCoolboxSuhu,
  type CoolboxSuhuState,
} from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';

interface SavedReportItem {
  id: string;
  code: string;
  title: string;
  author: string;
  createdAt: string;
  fileSize: string;
  format: string;
}

interface SavedReportsCardProps {
  items?: DispatchSummaryItem[];
  suhuMap?: Record<string, CoolboxSuhuState>;
}

const DEFAULT_SAVED_REPORTS: SavedReportItem[] = [
  {
    id: 'rpt-1',
    code: 'RPT-151026-01',
    title: 'Rekap Pemantauan Cold Chain Periode Berjalan',
    author: 'Pengawas Rantai Dingin Pangkep',
    createdAt: 'Terverifikasi IoT Realtime',
    fileSize: '312 KB',
    format: 'TXT/DOC',
  },
];

export const SavedReportsCard: React.FC<SavedReportsCardProps> = ({ items = [], suhuMap }) => {
  const handleDownload = (rpt: SavedReportItem) => {
    // Generate an official cold-chain report text with real database snapshot
    const totalBatches = items.length;
    const totalWeightKg = items.reduce((acc, c) => acc + (c.weightKg || 0), 0);
    const anomalies = items.filter((b) => {
      const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, b.coolboxId) : null;
      const t = boxSuhu?.latestAirTemp != null ? boxSuhu.latestAirTemp : b.lastTemp;
      return t > 4.0;
    }).length;

    const criticalBatches = items.filter((b) => {
      const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, b.coolboxId) : null;
      const s = boxSuhu?.frostScore?.score != null ? boxSuhu.frostScore.score : b.frostScore;
      return s < 60;
    }).length;

    const batchSummaryLines = items
      .map((it, idx) => {
        const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, it.coolboxId) : null;
        const temp = boxSuhu?.latestAirTemp != null ? boxSuhu.latestAirTemp : it.lastTemp;
        const score = boxSuhu?.frostScore?.score != null ? boxSuhu.frostScore.score : it.frostScore;
        const cat = boxSuhu?.frostScore?.status ?? it.riskLevel;
        return `${idx + 1}. Batch [${it.batchId}] (${it.commodity}, ${it.weightKg} kg) | Asal: ${it.origin} -> Tujuan: ${it.destination} | Suhu Sensor: ${temp.toFixed(1)}°C | FrostScore: ${score} (${cat})`;
      })
      .join('\n');

    const content = `======================================================================
           SMART-FROST &bull; LAPORAN AUDIT DISTRIBUSI RANTAI DINGIN
======================================================================
ID Laporan      : ${rpt.code}
Judul           : ${rpt.title}
Penyusun        : ${rpt.author}
Status Sinkron  : ${rpt.createdAt}
Tanggal Cetak   : ${new Date().toLocaleString('id-ID')}
Wilayah Yurisdiksi : Kabupaten Pangkajene dan Kepulauan, Sulawesi Selatan

----------------------------------------------------------------------
RINGKASAN EKSEKUTIF PEMANTAUAN IOT
----------------------------------------------------------------------
Total Batch Pengiriman  : ${totalBatches} batch
Total Tonase Komoditas  : ${(totalWeightKg / 1000).toFixed(3)} ton (${totalWeightKg} kg)
Batch Anomali Suhu (>4°C): ${anomalies} batch
Batch Risiko Tinggi (<60): ${criticalBatches} batch
Batas Suhu Aman Standar : 0.0°C s/d 4.0°C
Skala FrostScore Resmi  :
  - 90 - 100 : Sangat Baik (Aman)
  - 75 - 89  : Baik (Aman Terkendali)
  - 60 - 74  : Waspada (Perlu Perhatian)
  - < 60     : Risiko Tinggi (Tindakan Cepat Rantai Dingin)

----------------------------------------------------------------------
DAFTAR BATCH TERVERIFIKASI
----------------------------------------------------------------------
${batchSummaryLines || 'Tidak ada data batch aktif.'}

======================================================================
Dokumen ini disusun secara otomatis oleh sistem SMART-FROST
Berdasarkan telemetri sensor udara, GPS, dan durasi pengiriman.
======================================================================
`;

    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${rpt.code}-audit-rantai-dingin.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="rounded-2xl bg-white border border-slate-200/80 p-5 shadow-2xs">
      <h3 className="text-sm font-bold text-slate-900 border-b border-slate-100 pb-3">
        Laporan tersimpan
      </h3>

      <div className="mt-3 space-y-3">
        {DEFAULT_SAVED_REPORTS.map((rpt) => (
          <div
            key={rpt.id}
            className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-4 rounded-xl border border-slate-200/80 hover:border-slate-300 bg-white transition-all"
          >
            <div className="flex items-start gap-3">
              <div className="h-10 w-10 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center shrink-0 border border-sky-100">
                <FileText className="h-5 w-5" />
              </div>

              <div>
                <h4 className="text-sm font-bold text-slate-900">{rpt.title}</h4>
                <p className="text-xs text-slate-400 mt-0.5">
                  {rpt.code} &bull; {rpt.author} &bull; {rpt.createdAt}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-3 self-end sm:self-auto">
              <span className="text-xs font-semibold text-slate-500 bg-slate-100 px-2.5 py-1 rounded-lg">
                &bull; {rpt.format} - {rpt.fileSize}
              </span>

              <button
                type="button"
                onClick={() => handleDownload(rpt)}
                className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-xs font-bold text-slate-700 shadow-2xs transition-colors cursor-pointer"
              >
                <Download className="h-3.5 w-3.5 text-slate-500" />
                <span>Unduh Ringkasan</span>
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

