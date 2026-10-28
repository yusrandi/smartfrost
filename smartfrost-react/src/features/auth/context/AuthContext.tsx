import React, { createContext, useContext, useEffect, useState } from 'react';
import { STATIC_USERS, type StaticUser } from '../data/static_users';

interface AuthContextType {
  user: StaticUser | null;
  isAuthenticated: boolean;
  login: (identifier: string, password: string) => { success: boolean; message?: string };
  loginAs: (userId: string) => void;
  logout: () => void;
  updateProfile: (updatedData: Partial<StaticUser>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const AUTH_STORAGE_KEY = 'smartfrost_auth_user';

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<StaticUser | null>(() => {
    try {
      const saved = localStorage.getItem(AUTH_STORAGE_KEY);
      if (saved) {
        const parsed = JSON.parse(saved);
        if (parsed && typeof parsed === 'object' && parsed.id) {
          return parsed;
        }
      }
    } catch {
      // ignore
    }
    // Jika belum login atau sudah logout, default adalah null (wajib ke halaman login)
    return null;
  });

  useEffect(() => {
    try {
      if (user) {
        localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(user));
      } else {
        localStorage.removeItem(AUTH_STORAGE_KEY);
      }
    } catch {
      // ignore
    }
  }, [user]);

  const login = (identifier: string, pass: string): { success: boolean; message?: string } => {
    const cleanId = identifier.trim().toLowerCase();
    const cleanPass = pass.trim();

    const found = STATIC_USERS.find(
      (u) =>
        (u.email.toLowerCase() === cleanId || u.username.toLowerCase() === cleanId) &&
        u.password === cleanPass
    );

    if (found) {
      setUser(found);
      try {
        localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(found));
      } catch {
        // ignore
      }
      return { success: true };
    }

    return {
      success: false,
      message: 'Email/username atau kata sandi tidak valid. Coba gunakan akun demo yang tersedia.',
    };
  };

  const loginAs = (userId: string) => {
    const target = STATIC_USERS.find((u) => u.id === userId) || STATIC_USERS[0];
    setUser(target);
    try {
      localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(target));
    } catch {
      // ignore
    }
  };

  const logout = () => {
    try {
      localStorage.removeItem(AUTH_STORAGE_KEY);
    } catch {
      // ignore
    }
    setUser(null);
  };

  const updateProfile = (updatedData: Partial<StaticUser>) => {
    if (!user) return;
    setUser((prev) => {
      if (!prev) return null;
      const updated = { ...prev, ...updatedData };
      try {
        localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(updated));
      } catch {
        // ignore
      }
      return updated;
    });
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        login,
        loginAs,
        logout,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
