import React from 'react';
import { APP_METADATA } from '../../../core/constants/navigation';

export const Footer: React.FC = () => {
  return (
    <footer className="mt-auto border-t border-slate-200/80 bg-white/50 px-6 py-5 text-xs text-slate-500 backdrop-blur-xs">
      <div className="flex flex-col sm:flex-row items-center justify-between gap-2">
        <p className="font-medium">{APP_METADATA.footerCopyright}</p>
        <p className="text-[11px] text-slate-400">{APP_METADATA.footerDisclaimer}</p>
      </div>
    </footer>
  );
};
