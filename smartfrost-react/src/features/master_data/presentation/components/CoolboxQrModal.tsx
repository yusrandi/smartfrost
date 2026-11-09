import React, { useState, useRef } from 'react';
import { 
  QrCode, 
  Printer, 
  Download, 
  X, 
  Sliders, 
  Info
} from 'lucide-react';
import type { MasterCoolboxItem } from '../../data/datasources/master_data_rtdb_service';

interface CoolboxQrModalProps {
  coolbox: MasterCoolboxItem | null;
  onClose: () => void;
}

const SIZE_PRESETS = [
  { label: 'Kecil (160 px)', value: 160 },
  { label: 'Sedang (240 px)', value: 240 },
  { label: 'Besar (320 px)', value: 320 },
  { label: 'Stiker Fisik (400 px)', value: 400 },
];

export const CoolboxQrModal: React.FC<CoolboxQrModalProps> = ({ coolbox, onClose }) => {
  const [qrSize, setQrSize] = useState<number>(240);
  const [includeLabel, setIncludeLabel] = useState<boolean>(true);
  const printRef = useRef<HTMLDivElement>(null);

  if (!coolbox) return null;

  // Layanan QR Code gratis & resmi tanpa API Key (QRServer API)
  const qrImageUrl = `https://api.qrserver.com/v1/create-qr-code/?size=${qrSize}x${qrSize}&margin=8&data=${encodeURIComponent(
    coolbox.code
  )}`;

  const handlePrint = () => {
    window.print();
  };

  const handleDownload = async () => {
    try {
      const response = await fetch(qrImageUrl);
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `QRCode_${coolbox.code}_${qrSize}px.png`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
    } catch {
      // Fallback jika direct fetch CORS terkendala: buka di tab baru untuk disimpan
      window.open(qrImageUrl, '_blank');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-xs select-none animate-in fade-in duration-150">
      {/* Modal Dialog Card */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xl w-full max-w-xl max-h-[92vh] flex flex-col overflow-hidden">
        {/* Header Modal */}
        <div className="px-6 py-4.5 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-2xl bg-gradient-to-tr from-[#0284C7] to-cyan-400 text-white flex items-center justify-center shadow-md shadow-sky-600/20">
              <QrCode className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-base font-black text-slate-900 tracking-tight flex items-center gap-2">
                <span>QR Code Coolbox</span>
                <span className="font-mono text-xs px-2 py-0.5 rounded-md bg-sky-100 text-[#0284C7] font-bold">
                  {coolbox.code}
                </span>
              </h2>
              <p className="text-[11.5px] text-slate-500 font-medium">
                Generate kode QR gratis untuk label fisik coolbox IoT
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
            aria-label="Tutup Modal"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Modal Body: Scrollable */}
        <div className="p-6 overflow-y-auto space-y-6">
          {/* Custom Size Controls */}
          <div className="bg-slate-50 rounded-2xl p-4 border border-slate-200/70 space-y-3">
            <div className="flex items-center justify-between">
              <label className="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                <Sliders className="h-3.5 w-3.5 text-sky-600" />
                <span>Kustomisasi Ukuran QR Code:</span>
              </label>
              <span className="text-xs font-mono font-bold text-sky-700 bg-white px-2.5 py-0.5 rounded-lg border border-slate-200 shadow-2xs">
                {qrSize} x {qrSize} px
              </span>
            </div>

            {/* Presets */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
              {SIZE_PRESETS.map((preset) => (
                <button
                  key={preset.value}
                  type="button"
                  onClick={() => setQrSize(preset.value)}
                  className={`py-1.5 px-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer text-center ${
                    qrSize === preset.value
                      ? 'bg-[#0284C7] text-white shadow-xs'
                      : 'bg-white text-slate-700 border border-slate-200/80 hover:bg-slate-100'
                  }`}
                >
                  {preset.label}
                </button>
              ))}
            </div>

            {/* Slider */}
            <div className="pt-1 flex items-center gap-3">
              <span className="text-[10px] text-slate-400 font-bold">120px</span>
              <input
                type="range"
                min="120"
                max="500"
                step="20"
                value={qrSize}
                onChange={(e) => setQrSize(Number(e.target.value))}
                className="w-full h-1.5 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-[#0284C7]"
              />
              <span className="text-[10px] text-slate-400 font-bold">500px</span>
            </div>

            {/* Checkbox Sertakan Label */}
            <label className="flex items-center gap-2 pt-1 text-xs text-slate-700 font-semibold cursor-pointer">
              <input
                type="checkbox"
                checked={includeLabel}
                onChange={(e) => setIncludeLabel(e.target.checked)}
                className="h-3.5 w-3.5 rounded border-slate-300 text-sky-600 focus:ring-sky-500"
              />
              <span>Sertakan bingkai stiker label & informasi unit saat mencetak</span>
            </label>
          </div>

          {/* Printable Label Card Preview */}
          <div className="flex flex-col items-center">
            <div
              ref={printRef}
              id="printable-coolbox-label"
              className="bg-white p-6 rounded-2xl border-2 border-dashed border-slate-300 shadow-sm flex flex-col items-center text-center max-w-sm w-full transition-all"
            >
              {includeLabel && (
                <div className="w-full pb-3 mb-3 border-b border-slate-200 flex items-center justify-between">
                  <div className="flex items-center gap-2 text-left">
                    <div className="h-6 w-6 rounded-lg bg-sky-600 text-white flex items-center justify-center font-black text-[10px]">
                      SF
                    </div>
                    <div>
                      <div className="text-[10.5px] font-black tracking-tight text-slate-900 leading-none">
                        SMART-FROST
                      </div>
                      <div className="text-[8px] font-extrabold text-sky-600 tracking-wider uppercase">
                        IOT COOLBOX
                      </div>
                    </div>
                  </div>
                  <span className="text-[9px] font-mono text-slate-400">PANGKEP</span>
                </div>
              )}

              {/* QR Image */}
              <div className="bg-white p-2 rounded-xl border border-slate-100 shadow-2xs">
                <img
                  src={qrImageUrl}
                  alt={`QR Code ${coolbox.code}`}
                  style={{ width: `${Math.min(qrSize, 260)}px`, height: `${Math.min(qrSize, 260)}px` }}
                  className="object-contain"
                />
              </div>

              {includeLabel && (
                <div className="mt-3.5 space-y-1">
                  <div className="text-xl font-black text-slate-900 font-mono tracking-wider">
                    {coolbox.code}
                  </div>
                  <div className="text-xs text-slate-600 font-medium max-w-[240px]">
                    {coolbox.label || 'Unit Coolbox Sensor Suhu IoT'}
                  </div>
                  <div className="text-[9px] text-slate-400 pt-1 border-t border-slate-100 mt-2 font-mono">
                    Scan untuk registrasi / pelacakan batch
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Info footnote */}
          <div className="flex items-start gap-2 p-3 rounded-xl bg-sky-50/70 border border-sky-100 text-[11px] text-sky-800 leading-relaxed font-medium">
            <Info className="h-4 w-4 shrink-0 text-sky-600 mt-0.5" />
            <span>
              QR Code ini berisi teks identifier <strong>{coolbox.code}</strong>. Dapat langsung dipindai oleh kamera barcode scanner pada aplikasi mobile Android SmartFrost saat nelayan/distributor memilih coolbox pengiriman.
            </span>
          </div>
        </div>

        {/* Modal Footer: Action Buttons */}
        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/60 flex items-center justify-between gap-3">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-200/70 transition-colors cursor-pointer"
          >
            Tutup
          </button>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleDownload}
              className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-white border border-slate-200 text-xs font-bold text-slate-700 hover:bg-slate-100 shadow-2xs transition-all cursor-pointer"
            >
              <Download className="h-3.5 w-3.5 text-slate-500" />
              <span>Unduh PNG</span>
            </button>

            <button
              type="button"
              onClick={handlePrint}
              className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#0284C7] hover:bg-sky-700 text-white text-xs font-bold shadow-md shadow-sky-600/20 transition-all cursor-pointer"
            >
              <Printer className="h-3.5 w-3.5" />
              <span>Cetak Label (Print)</span>
            </button>
          </div>
        </div>
      </div>

      {/* Global CSS for Clean Sticker Printing */}
      <style>{`
        @media print {
          body * {
            visibility: hidden !important;
          }
          #printable-coolbox-label, #printable-coolbox-label * {
            visibility: visible !important;
          }
          #printable-coolbox-label {
            position: fixed !important;
            left: 50% !important;
            top: 50% !important;
            transform: translate(-50%, -50%) !important;
            border: 2px solid #000 !important;
            padding: 24px !important;
            box-shadow: none !important;
            background: #fff !important;
          }
        }
      `}</style>
    </div>
  );
};
