'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getAuthToken, setAuthToken, removeAuthToken, getUserId, setUserId } from './api';

interface AuthContextType {
  isAuthenticated: boolean;
  token: string | null;
  userId: number | null;
  login: (token: string, userId: number) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [userId, setUserIdState] = useState<number | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const router = useRouter();

  useEffect(() => {
    const storedToken = getAuthToken();
    const storedUserId = getUserId();
    if (storedToken && storedUserId) {
      setToken(storedToken);
      setUserIdState(storedUserId);
      setIsAuthenticated(true);
    }
  }, []);

  const login = (newToken: string, newUserId: number) => {
    setAuthToken(newToken);
    setUserId(newUserId);
    setToken(newToken);
    setUserIdState(newUserId);
    setIsAuthenticated(true);
  };

  const logout = () => {
    removeAuthToken();
    setToken(null);
    setUserIdState(null);
    setIsAuthenticated(false);
    router.push('/login');
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, token, userId, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

