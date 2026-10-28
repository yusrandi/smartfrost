import React, { useState } from 'react';
import { ArrowRight, Eye, EyeOff, Mail, ShieldAlert, Sparkles } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { STATIC_USERS } from '../../data/static_users';

export const LoginPage: React.FC = () => {
  const { login, loginAs } = useAuth();
  const [identifier, setIdentifier] = useState('rahmat@dinas-contoh.id');
  const [password, setPassword] = useState('password123');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);
    setIsLoading(true);

    setTimeout(() => {
      const result = login(identifier, password);
      if (!result.success) {
        setErrorMessage(result.message || 'Gagal masuk. Periksa kembali akun Anda.');
      }
      setIsLoading(false);
    }, 400);
  };

  const handleQuickLogin = (userId: string) => {
    const user = STATIC_USERS.find((u) => u.id === userId);
    if (user) {
      setIdentifier(user.email);
      setPassword(user.password);
      loginAs(user.id);
    }
  };

  return (
    <div className="min-h-screen bg-radial from-[#F0F7FB] via-[#F8FAFC] to-[#EDF4F9] flex flex-col justify-between p-4 sm:p-6 text-slate-800 antialiased font-sans select-none">
      {/* Top Header Logo */}
      <div className="w-full max-w-5xl mx-auto flex items-center justify-between pt-2">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-2xl bg-gradient-to-tr from-cyan-600 to-sky-400 flex items-center justify-center shadow-md shadow-sky-500/25 text-white">
            <svg
              className="h-5 w-5 text-white"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.3"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="12" y1="2" x2="12" y2="22" />
              <line x1="2" y1="12" x2="22" y2="12" />
              <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
              <line x1="19.07" y1="4.93" x2="4.93" y2="19.07" />
              <circle cx="12" cy="12" r="3" fill="#0EA5E9" />
            </svg>
          </div>
          <div>
            <div className="text-base font-black tracking-wider text-slate-900 leading-tight">
              SMART-FROST
            </div>
            <div className="text-[10px] font-extrabold tracking-widest text-sky-600 uppercase">
              RANTAI DINGIN &bull; PANGKEP
            </div>
          </div>
        </div>

        <div className="hidden sm:inline-flex items-center gap-2 rounded-full border border-sky-200/80 bg-white/90 px-3.5 py-1 text-xs font-semibold text-sky-800 shadow-2xs">
          <span className="h-1.5 w-1.5 rounded-full bg-teal-500 animate-pulse" />
          <span>Dinas Perikanan Pangkep</span>
        </div>
      </div>

      {/* Main Login Card */}
      <div className="w-full max-w-md mx-auto my-8">
        <div className="rounded-3xl bg-white/90 backdrop-blur-md border border-slate-200/80 p-7 sm:p-9 shadow-xl shadow-slate-200/50">
          {/* Card Header */}
          <div className="text-center">
            <h1 className="text-2xl font-black text-slate-900 tracking-tight">
              Masuk ke Ruang Pantau
            </h1>
            <p className="text-xs text-slate-500 mt-1.5 leading-relaxed font-medium">
              Sistem Pemantauan Rantai Dingin & Distribusi Ikan Antarpulau
            </p>
          </div>

          {/* Error Alert */}
          {errorMessage && (
            <div className="mt-5 p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2.5 animate-in fade-in">
              <ShieldAlert className="h-4 w-4 shrink-0 text-rose-600 mt-0.5" />
              <span className="leading-snug">{errorMessage}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="mt-6 space-y-4">
            {/* Email / Username */}
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1.5">
                Email atau Username
              </label>
              <div className="relative">
                <input
                  type="text"
                  required
                  value={identifier}
                  onChange={(e) => setIdentifier(e.target.value)}
                  placeholder="nama@dinas-contoh.id"
                  className="w-full rounded-xl bg-white border border-slate-200 px-3.5 py-2.5 pr-10 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
                />
                <Mail className="pointer-events-none absolute right-3.5 top-3 h-4 w-4 text-slate-400" />
              </div>
            </div>

            {/* Kata Sandi */}
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-xs font-bold text-slate-700">
                  Kata Sandi
                </label>
                <span className="text-[11px] text-sky-600 hover:text-sky-700 font-medium cursor-pointer">
                  Lupa sandi?
                </span>
              </div>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Masukkan kata sandi"
                  className="w-full rounded-xl bg-white border border-slate-200 px-3.5 py-2.5 pr-10 text-xs font-semibold text-slate-800 shadow-2xs focus:outline-none focus:ring-1 focus:ring-sky-500"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-2.5 text-slate-400 hover:text-slate-600 cursor-pointer"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            {/* Remember Me */}
            <div className="flex items-center justify-between pt-0.5">
              <label className="flex items-center gap-2 text-xs font-medium text-slate-600 cursor-pointer">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="h-3.5 w-3.5 rounded border-slate-300 text-sky-600 focus:ring-sky-500"
                />
                <span>Ingat saya di perangkat ini</span>
              </label>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-2 inline-flex items-center justify-center gap-2 py-3 px-6 rounded-2xl bg-[#0284C7] hover:bg-sky-700 text-white font-black text-sm shadow-md shadow-sky-600/20 hover:shadow-sky-600/30 transition-all cursor-pointer disabled:opacity-70"
            >
              {isLoading ? (
                <span>Memverifikasi...</span>
              ) : (
                <>
                  <span>Masuk ke Platform</span>
                  <ArrowRight className="h-4 w-4" />
                </>
              )}
            </button>
          </form>

          {/* Quick Login with Static Users */}
          <div className="mt-7 pt-6 border-t border-slate-100">
            <div className="flex items-center justify-between mb-2.5">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
                <Sparkles className="h-3 w-3 text-sky-500" />
                Akun Uji Coba Statis:
              </span>
              <span className="text-[10px] text-slate-400">Klik untuk langsung masuk</span>
            </div>

            <div className="space-y-2">
              {STATIC_USERS.map((usr) => (
                <button
                  key={usr.id}
                  type="button"
                  onClick={() => handleQuickLogin(usr.id)}
                  className="w-full text-left p-2.5 rounded-xl border border-slate-200/80 hover:border-sky-300 hover:bg-sky-50/50 bg-white flex items-center justify-between transition-all group cursor-pointer"
                >
                  <div className="flex items-center gap-2.5">
                    <div className="h-8 w-8 rounded-full bg-sky-100 text-[#0284C7] text-xs font-black flex items-center justify-center border border-sky-200/60">
                      {usr.initials}
                    </div>
                    <div>
                      <div className="text-xs font-bold text-slate-800 group-hover:text-sky-700">
                        {usr.name}
                      </div>
                      <div className="text-[10.5px] text-slate-500">
                        {usr.role} &bull; <span className="font-mono text-[10px]">{usr.email}</span>
                      </div>
                    </div>
                  </div>
                  <span className="text-[11px] font-bold text-sky-600 opacity-0 group-hover:opacity-100 transition-opacity">
                    Pilih &rarr;
                  </span>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Footer Notice */}
      <div className="w-full max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2 text-center text-xs text-slate-400 pb-2">
        <div>&copy; 2026 SMART-FROST &bull; Pemerintah Kabupaten Pangkajene dan Kepulauan</div>
        <div>Sistem Rantai Dingin Perikanan Antarpulau</div>
      </div>
    </div>
  );
};
