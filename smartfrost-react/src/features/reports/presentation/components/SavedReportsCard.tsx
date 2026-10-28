import React from 'react';
import { Download, FileText } from 'lucide-react';

interface SavedReportItem {
  id: string;
  code: string;
  title: string;
  author: string;
  createdAt: string;
  fileSize: string;
  format: string;
}

const DEFAULT_SAVED_REPORTS: SavedReportItem[] = [
  {
    id: 'rpt-1',
    code: 'RPT-151026-01',
    title: 'Distribusi 1–15 Oktober 2026',
    author: 'Rahmat Hidayat',
    createdAt: 'dibuat 16 Okt, 08.00 WITA',
    fileSize: '248 KB',
    format: 'PDF',
  },
];

export const SavedReportsCard: React.FC = () => {
  const handleDownload = (rpt: SavedReportItem) => {
    // Generate simple text download simulating report PDF
    const content = `SMART-FROST LAPORAN DISTRIBUSI\nID Laporan: ${rpt.code}\nJudul: ${rpt.title}\nPenyusun: ${rpt.author}\nTanggal: ${rpt.createdAt}\nFormat: ${rpt.format} (${rpt.fileSize})\nStatus: Terverifikasi oleh Dinas Perikanan Kabupaten Pangkep\n`;
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${rpt.code}-distribusi-ikan.txt`;
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
                <span>Unduh</span>
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

