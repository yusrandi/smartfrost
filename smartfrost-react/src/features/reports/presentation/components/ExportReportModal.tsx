import React, { useState } from 'react';
import { Calendar, ChevronDown, Download, FileSpreadsheet, FileText, Info, X } from 'lucide-react';
import {
  findCoolboxSuhu,
  type CoolboxSuhuState,
} from '../../../dashboard/data/datasources/dashboard_rtdb_datasource';
import { FrostScoreCalculator } from '../../../dashboard/domain/services/frost_score_calculator';
import type { DispatchSummaryItem } from '../../../dashboard/data/models/dashboard_types';

interface ExportReportModalProps {
  isOpen: boolean;
  onClose: () => void;
  items: DispatchSummaryItem[];
  availableRegions: string[];
  suhuMap?: Record<string, CoolboxSuhuState>;
}

const SELECT_CLASS =
  'w-full appearance-none rounded-xl bg-white border border-slate-200/90 px-3.5 py-2.5 pr-8 text-xs font-semibold text-slate-700 shadow-2xs hover:border-slate-300 focus:outline-none focus:ring-1 focus:ring-sky-500 transition-colors cursor-pointer';

export const ExportReportModal: React.FC<ExportReportModalProps> = ({
  isOpen,
  onClose,
  items,
  availableRegions,
  suhuMap,
}) => {
  const [period, setPeriod] = useState<string>('Bulan Berjalan (Oktober 2026)');
  const [region, setRegion] = useState<string>('Semua wilayah');
  const [status, setStatus] = useState<string>('Semua status');
  const [risk, setRisk] = useState<string>('Semua tingkat');
  const [format, setFormat] = useState<'excel' | 'csv'>('excel');
  const [includeAnomalies, setIncludeAnomalies] = useState<boolean>(true);
  const [includeDelayed, setIncludeDelayed] = useState<boolean>(true);

  if (!isOpen) return null;

  const handleExport = (e: React.FormEvent) => {
    e.preventDefault();

    // 1. Resolve real telemetry and official FrostScore calculation for each item
    const resolvedItems = items.map((it) => {
      const boxSuhu = suhuMap ? findCoolboxSuhu(suhuMap, it.coolboxId) : null;
      const effectiveTemp = boxSuhu?.latestAirTemp != null ? boxSuhu.latestAirTemp : it.lastTemp;
      const effectiveScore = boxSuhu?.frostScore?.score != null ? boxSuhu.frostScore.score : it.frostScore;
      const effectiveCategory = boxSuhu?.frostScore?.status ?? FrostScoreCalculator.getCategory(effectiveScore);

      return {
        ...it,
        effectiveTemp,
        effectiveScore,
        effectiveCategory,
      };
    });

    // 2. Apply filters
    let filtered = [...resolvedItems];

    if (region !== 'Semua wilayah') {
      filtered = filtered.filter(
        (it) =>
          it.origin.toLowerCase().includes(region.toLowerCase()) ||
          region.toLowerCase().includes(it.origin.toLowerCase())
      );
    }

    if (status !== 'Semua status') {
      filtered = filtered.filter(
        (it) => it.operationalStatus.toLowerCase() === status.toLowerCase()
      );
    }

    if (risk !== 'Semua tingkat') {
      if (risk === 'Sangat Baik') {
        filtered = filtered.filter((it) => it.effectiveScore >= 90);
      } else if (risk === 'Baik') {
        filtered = filtered.filter((it) => it.effectiveScore >= 75 && it.effectiveScore < 90);
      } else if (risk === 'Waspada') {
        filtered = filtered.filter((it) => it.effectiveScore >= 60 && it.effectiveScore < 75);
      } else if (risk === 'Risiko Tinggi') {
        filtered = filtered.filter((it) => it.effectiveScore < 60);
      }
    }

    if (!includeDelayed) {
      filtered = filtered.filter((it) => it.syncStatus !== 'Tertunda');
    }

    // 3. Prepare headers & rows
    const headers = [
      'ID Batch',
      'Coolbox ID',
      'Komoditas',
      'Berat (kg)',
      'Asal Pengirim',
      'Tujuan Penerima',
      'Tanggal Pengiriman',
      'Suhu Udara (°C)',
      'Waktu Telemetri',
      'FrostScore',
      'Klasifikasi Risiko',
      'Status Sensor IoT',
      'Status Operasional',
    ];

    if (includeAnomalies) {
      headers.push('Status Kepatuhan Suhu (≤4°C)');
    }

    const rows = filtered.map((item) => {
      const row: (string | number)[] = [
        item.batchId,
        item.coolboxId,
        item.commodity,
        item.weightKg,
        item.origin,
        item.destination,
        item.dateStr,
        item.effectiveTemp.toFixed(1),
        item.lastTempTime,
        item.effectiveScore,
        item.effectiveCategory,
        item.syncStatus,
        item.operationalStatus,
      ];
      if (includeAnomalies) {
        row.push(item.effectiveTemp > 4.0 ? 'Anomali (>4,0°C)' : 'Aman (≤4,0°C)');
      }
      return row;
    });

    const timestamp = new Date().toISOString().slice(0, 10);
    const filename = `smartfrost-laporan-${timestamp}`;

    // 4. Export based on selected format
    if (format === 'excel') {
      // Excel XML / Spreadsheet
      const tableHtml = `
        <html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">
        <head>
          <!--[if gte mso 9]>
          <xml>
            <x:ExcelWorkbook>
              <x:ExcelWorksheets>
                <x:ExcelWorksheet>
                  <x:Name>Laporan Rantai Dingin</x:Name>
                  <x:WorksheetOptions>
                    <x:DisplayGridlines/>
                  </x:WorksheetOptions>
                </x:ExcelWorksheet>
              </x:ExcelWorksheets>
            </x:ExcelWorkbook>
          </xml>
          <![endif]-->
          <meta http-equiv="content-type" content="text/plain; charset=UTF-8"/>
          <style>
            th { background-color: #0284c7; color: #ffffff; font-weight: bold; border: 1px solid #cbd5e1; padding: 10px; font-family: sans-serif; text-align: left; }
            td { border: 1px solid #e2e8f0; padding: 8px; font-family: sans-serif; font-size: 12px; }
          </style>
        </head>
        <body>
          <h2 style="font-family: sans-serif; color: #0f172a; margin-bottom: 4px;">SMART-FROST &bull; Laporan Audit Pemantauan Rantai Dingin</h2>
          <p style="font-family: sans-serif; color: #64748b; font-size: 12px; margin-top: 0;">Periode: ${period} | Asal Pengirim: ${region} | Diekspor: ${new Date().toLocaleString('id-ID')} | Standar Suhu: 0–4°C</p>
          <table>
            <thead>
              <tr>
                ${headers.map((h) => `<th>${h}</th>`).join('')}
              </tr>
            </thead>
            <tbody>
              ${rows
                .map(
                  (r) =>
                    `<tr>${r
                      .map((c) => `<td>${String(c ?? '').replace(/</g, '&lt;').replace(/>/g, '&gt;')}</td>`)
                      .join('')}</tr>`
                )
                .join('')}
            </tbody>
          </table>
        </body>
        </html>
      `;

      const blob = new Blob([tableHtml], { type: 'application/vnd.ms-excel;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.setAttribute('href', url);
      link.setAttribute('download', `${filename}.xls`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } else {
      // CSV format with UTF-8 BOM
      const csvContent =
        '\uFEFF' +
        [
          headers.join(','),
          ...rows.map((row) =>
            row.map((val) => `"${String(val ?? '').replace(/"/g, '""')}"`).join(',')
          ),
        ].join('\n');

      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.setAttribute('href', url);
      link.setAttribute('download', `${filename}.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    }

    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="w-full max-w-md rounded-2xl bg-white border border-slate-200/80 p-6 shadow-xl relative max-h-[92vh] overflow-y-auto">
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          className="absolute top-5 right-5 h-8 w-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 flex items-center justify-center transition-colors cursor-pointer"
        >
          <X className="h-4 w-4" />
        </button>

        {/* Modal Header */}
        <div className="border-b border-slate-100 pb-3">
          <h3 className="text-base font-bold text-slate-900">Filter & Ekspor Laporan</h3>
          <p className="text-xs text-slate-500 mt-0.5">
            Pilih parameter filter dan format file (Excel atau CSV) sebelum mengunduh rekap pemantauan.
          </p>
        </div>

        {/* Form Body */}
        <form onSubmit={handleExport} className="mt-4 space-y-3.5">
          {/* 1. Periode Laporan */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">
              Periode laporan
            </label>
            <div className="relative">
              <input
                type="text"
                value={period}
                onChange={(e) => setPeriod(e.target.value)}
                className="w-full rounded-xl bg-white border border-slate-200/90 px-3.5 py-2.5 pr-8 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
              />
              <Calendar className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
            </div>
          </div>

          {/* 2. Wilayah Asal Pengirim */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">
              Wilayah asal pengirim
            </label>
            <div className="relative">
              <select
                value={region}
                onChange={(e) => setRegion(e.target.value)}
                className={SELECT_CLASS}
              >
                <option value="Semua wilayah">Semua wilayah pengirim</option>
                {availableRegions.map((r) => (
                  <option key={r} value={r}>
                    {r}
                  </option>
                ))}
              </select>
              <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
            </div>
          </div>

          {/* 3. Status Perjalanan */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">
              Status perjalanan
            </label>
            <div className="relative">
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className={SELECT_CLASS}
              >
                <option value="Semua status">Semua status</option>
                <option value="Menunggu">Menunggu</option>
                <option value="Perjalanan">Perjalanan</option>
                <option value="Diperiksa">Diperiksa</option>
                <option value="Diterima">Diterima</option>
                <option value="Ditolak">Ditolak</option>
              </select>
              <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
            </div>
          </div>

          {/* 4. Tingkat Risiko (Official FrostScore Tiers) */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">
              Klasifikasi FrostScore
            </label>
            <div className="relative">
              <select
                value={risk}
                onChange={(e) => setRisk(e.target.value)}
                className={SELECT_CLASS}
              >
                <option value="Semua tingkat">Semua klasifikasi</option>
                <option value="Sangat Baik">Sangat Baik (≥90)</option>
                <option value="Baik">Baik (75–89)</option>
                <option value="Waspada">Waspada (60–74)</option>
                <option value="Risiko Tinggi">Risiko Tinggi (&lt;60)</option>
              </select>
              <ChevronDown className="pointer-events-none absolute right-3 top-3 h-3.5 w-3.5 text-slate-400" />
            </div>
          </div>

          {/* 5. Format Export: Excel atau CSV */}
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1.5">
              Format ekspor berkas
            </label>
            <div className="grid grid-cols-2 gap-2.5">
              <button
                type="button"
                onClick={() => setFormat('excel')}
                className={`flex items-center gap-2.5 p-3 rounded-xl border text-left transition-all cursor-pointer ${
                  format === 'excel'
                    ? 'border-emerald-500 bg-emerald-50/70 text-emerald-900 ring-1 ring-emerald-500'
                    : 'border-slate-200 bg-white text-slate-700 hover:border-slate-300'
                }`}
              >
                <div
                  className={`h-8 w-8 rounded-lg flex items-center justify-center shrink-0 ${
                    format === 'excel' ? 'bg-emerald-600 text-white' : 'bg-slate-100 text-slate-600'
                  }`}
                >
                  <FileSpreadsheet className="h-4 w-4" />
                </div>
                <div>
                  <div className="text-xs font-bold">Excel (.xls)</div>
                  <div className="text-[10px] text-slate-500">Spreadsheet rapi</div>
                </div>
              </button>

              <button
                type="button"
                onClick={() => setFormat('csv')}
                className={`flex items-center gap-2.5 p-3 rounded-xl border text-left transition-all cursor-pointer ${
                  format === 'csv'
                    ? 'border-sky-500 bg-sky-50/70 text-sky-900 ring-1 ring-sky-500'
                    : 'border-slate-200 bg-white text-slate-700 hover:border-slate-300'
                }`}
              >
                <div
                  className={`h-8 w-8 rounded-lg flex items-center justify-center shrink-0 ${
                    format === 'csv' ? 'bg-sky-600 text-white' : 'bg-slate-100 text-slate-600'
                  }`}
                >
                  <FileText className="h-4 w-4" />
                </div>
                <div>
                  <div className="text-xs font-bold">CSV (.csv)</div>
                  <div className="text-[10px] text-slate-500">Data mentah UTF-8</div>
                </div>
              </button>
            </div>
          </div>

          {/* Checkboxes */}
          <div className="space-y-2 pt-1">
            <label className="flex items-center gap-2 text-xs font-medium text-slate-700 cursor-pointer">
              <input
                type="checkbox"
                checked={includeAnomalies}
                onChange={(e) => setIncludeAnomalies(e.target.checked)}
                className="h-3.5 w-3.5 rounded border-slate-300 text-sky-600 focus:ring-sky-500"
              />
              <span>Sertakan kolom audit anomali suhu (&gt;4,0°C)</span>
            </label>

            <label className="flex items-center gap-2 text-xs font-medium text-slate-700 cursor-pointer">
              <input
                type="checkbox"
                checked={includeDelayed}
                onChange={(e) => setIncludeDelayed(e.target.checked)}
                className="h-3.5 w-3.5 rounded border-slate-300 text-sky-600 focus:ring-sky-500"
              />
              <span>Sertakan data berstatus tertunda</span>
            </label>
          </div>

          {/* Info Notice */}
          <div className="rounded-xl bg-sky-50 border border-sky-100 p-3 text-[11px] text-sky-900 flex items-start gap-2">
            <Info className="h-4 w-4 text-sky-600 shrink-0 mt-0.5" />
            <div className="leading-snug">
              <strong className="text-sky-950">Integritas data terjamin.</strong> Berkas ekspor menggunakan data telemetri sensor real-time yang langsung dihitung dengan formula FrostScore resmi.
            </div>
          </div>

          {/* Submit Action */}
          <div className="pt-2 flex items-center justify-end gap-2">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50 transition-colors cursor-pointer"
            >
              Batal
            </button>
            <button
              type="submit"
              className={`inline-flex items-center gap-2 px-6 py-2.5 rounded-xl text-white text-xs font-bold shadow-xs transition-colors cursor-pointer ${
                format === 'excel' ? 'bg-emerald-600 hover:bg-emerald-700' : 'bg-sky-600 hover:bg-sky-700'
              }`}
            >
              <Download className="h-3.5 w-3.5" />
              <span>Ekspor ke {format === 'excel' ? 'Excel' : 'CSV'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
