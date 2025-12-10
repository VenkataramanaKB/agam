// API client for Agam Cloud backend

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

export interface UserInput {
  name: string;
  email: string;
  phone: number;
  password: string;
}

export interface VerifyUserRegistrationRequest {
  email: string;
  otp: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  message: string;
  user_id: number;
}

export interface VerifyOTPRequest {
  email: string;
  otp: string;
}

export interface VerifyOTPResponse {
  token: string;
  user_id: number;
  email: string;
  name: string;
}

export interface Vault {
  id: string;
  name: string;
  type: string;
  user_id: number;
  created_timestamp: string;
}

export interface VaultInput {
  name: string;
  type: string;
}

export interface File {
  id: string;
  vault_id: string;
  name: string;
  type: string;
  date: string;
  time: string;
  size: number;
  minio_key: string;
  thumbnail?: string;
  folder_id?: string;
}

// Get auth token from localStorage
export function getAuthToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('auth_token');
}

// Set auth token in localStorage
export function setAuthToken(token: string): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem('auth_token', token);
  }
}

// Set user ID in localStorage
export function setUserId(userId: number): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem('user_id', userId.toString());
  }
}

// Get user ID from localStorage
export function getUserId(): number | null {
  if (typeof window === 'undefined') return null;
  const userIdStr = localStorage.getItem('user_id');
  if (!userIdStr) return null;
  const userId = parseInt(userIdStr, 10);
  return isNaN(userId) ? null : userId;
}

// Remove auth token from localStorage
export function removeAuthToken(): void {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_id');
  }
}

// API request helper
async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getAuthToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(errorText || `HTTP error! status: ${response.status}`);
  }

  // Handle empty responses
  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    return response.json();
  }
  return {} as T;
}

// Auth API
export const authAPI = {
  register: async (input: UserInput): Promise<{ message: string }> => {
    return apiRequest('/users', {
      method: 'POST',
      body: JSON.stringify(input),
    });
  },

  verifyRegistration: async (
    req: VerifyUserRegistrationRequest
  ): Promise<{ id: number; name: string; email: string; phone: number; createdTimestamp: string }> => {
    return apiRequest('/users/verify-otp', {
      method: 'POST',
      body: JSON.stringify(req),
    });
  },

  login: async (req: LoginRequest): Promise<LoginResponse> => {
    return apiRequest('/auth/login', {
      method: 'POST',
      body: JSON.stringify(req),
    });
  },

  verifyOTP: async (req: VerifyOTPRequest): Promise<VerifyOTPResponse> => {
    return apiRequest('/auth/verify-otp', {
      method: 'POST',
      body: JSON.stringify(req),
    });
  },
};

// Vault API
export const vaultAPI = {
  list: async (userId: number): Promise<Vault[]> => {
    return apiRequest(`/vaults?user_id=${userId}`);
  },

  create: async (input: VaultInput, userId: number): Promise<Vault> => {
    return apiRequest('/vaults/create', {
      method: 'POST',
      body: JSON.stringify({ ...input, user_id: userId }),
    });
  },

  delete: async (vaultId: string, userId: number): Promise<void> => {
    return apiRequest(`/vaults/delete?vault_id=${vaultId}&user_id=${userId}`, {
      method: 'DELETE',
    });
  },

  getThumbnail: async (vaultId: string): Promise<any> => {
    return apiRequest(`/thumbnail?vault_id=${vaultId}`);
  },
};

// File API
export const fileAPI = {
  upload: async (file: globalThis.File, vaultId: string): Promise<any> => {
    const formData = new FormData();
    formData.append('file', file as Blob);
    formData.append('vault_id', vaultId);

    const token = getAuthToken();
    const headers: Record<string, string> = {};
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${API_BASE_URL}/files/upload`, {
      method: 'POST',
      headers,
      body: formData,
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(errorText || `HTTP error! status: ${response.status}`);
    }

    return response.json();
  },

  delete: async (fileId: string, vaultId: string): Promise<void> => {
    return apiRequest(`/files/delete?file_id=${fileId}&vault_id=${vaultId}`, {
      method: 'DELETE',
    });
  },
};

