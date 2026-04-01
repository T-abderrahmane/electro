'use client';

import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, ReactNode } from 'react';
import { User, SubscriptionPayment, ServiceRequest, Offer } from '@/data/adminMockData';

interface AdminContextType {
  // Auth
  isLoggedIn: boolean;
  isAuthLoading: boolean;
  adminEmail: string;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  
  // Users
  users: User[];
  updateUserStatus: (userId: string, status: 'active' | 'suspended') => void;
  deleteUser: (userId: string) => void;
  
  // Subscriptions
  payments: SubscriptionPayment[];
  approvePayment: (paymentId: string) => void;
  rejectPayment: (paymentId: string) => void;
  activateSubscription: (electricianId: string, months: number) => void;
  
  // Requests
  requests: ServiceRequest[];
  offers: Offer[];
  closeRequest: (requestId: string) => void;
  deleteRequest: (requestId: string) => void;
}

const AdminContext = createContext<AdminContextType | undefined>(undefined);
const GET_CACHE_TTL_MS = 10000;
const getResponseCache = new Map<string, { timestamp: number; data: unknown }>();

type RawRequest = {
  id: string;
  clientId: string;
  clientName?: string;
  serviceType?: string;
  title?: string;
  description: string;
  wilaya: string;
  commune: string;
  status: string;
  createdAt: string;
};

type RawOffer = {
  id: string;
  requestId: string;
  electricianId: string;
  electricianName?: string;
  price: number;
  message?: string;
  description?: string;
  estimatedTime?: string;
  estimatedDuration?: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: string;
};

type RawPayment = {
  id: string;
  electricianId: string;
  electricianName: string;
  paymentProofImage?: string;
  screenshotUrl?: string;
  amount: number;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: string;
};

type AdminMeResponse = {
  authenticated: boolean;
  email: string;
};

const serviceTypeLabel: Record<string, string> = {
  installation: 'تركيب كهربائي',
  repair: 'إصلاح كهربائي',
  maintenance: 'صيانة كهربائية',
  consultation: 'استشارة كهربائية',
  other: 'خدمة كهربائية',
};

const toRequestStatus = (status: string): 'open' | 'assigned' | 'closed' => {
  if (status === 'assigned' || status === 'in_progress' || status === 'completed') {
    return 'assigned';
  }
  if (status === 'closed' || status === 'cancelled') {
    return 'closed';
  }
  return 'open';
};

const normalizeOffer = (offer: RawOffer): Offer => ({
  id: offer.id,
  requestId: offer.requestId,
  electricianId: offer.electricianId,
  electricianName: offer.electricianName || 'Unknown',
  price: Number(offer.price || 0),
  message: offer.message || offer.description || '',
  estimatedTime: offer.estimatedTime || offer.estimatedDuration || '',
  status: offer.status,
  createdAt: offer.createdAt,
});

const normalizePayment = (payment: RawPayment): SubscriptionPayment => ({
  id: payment.id,
  electricianId: payment.electricianId,
  electricianName: payment.electricianName,
  paymentProofImage: payment.paymentProofImage || payment.screenshotUrl || '',
  amount: Number(payment.amount || 0),
  status: payment.status,
  createdAt: payment.createdAt,
});

const normalizeRequest = (request: RawRequest, allOffers: Offer[]): ServiceRequest => ({
  id: request.id,
  clientId: request.clientId,
  clientName: request.clientName || 'Unknown',
  title: request.title || serviceTypeLabel[request.serviceType || 'other'] || serviceTypeLabel.other,
  description: request.description,
  wilaya: request.wilaya,
  commune: request.commune,
  status: toRequestStatus(request.status),
  offersCount: allOffers.filter((o) => o.requestId === request.id).length,
  createdAt: request.createdAt,
});

async function apiFetch<T>(url: string, init?: RequestInit): Promise<T> {
  const method = (init?.method || 'GET').toUpperCase();

  if (method == 'GET') {
    const cached = getResponseCache.get(url);
    if (cached && Date.now() - cached.timestamp < GET_CACHE_TTL_MS) {
      return cached.data as T;
    }
  }

  const response = await fetch(url, {
    ...init,
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      ...(init?.headers || {}),
    },
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `Request failed: ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  const data = await response.json() as T;

  if (method == 'GET') {
    getResponseCache.set(url, { timestamp: Date.now(), data });
  }

  return data;
}

export function AdminProvider({ children }: { children: ReactNode }) {
  const DASHBOARD_REFRESH_MIN_MS = 15000;
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isAuthLoading, setIsAuthLoading] = useState(true);
  const [adminEmail, setAdminEmail] = useState('');
  const [users, setUsers] = useState<User[]>([]);
  const [payments, setPayments] = useState<SubscriptionPayment[]>([]);
  const [requests, setRequests] = useState<ServiceRequest[]>([]);
  const [offers, setOffers] = useState<Offer[]>([]);
  const isLoadingDashboardRef = useRef(false);
  const lastDashboardLoadAtRef = useRef(0);

  const loadDashboardData = useCallback(async (force = false) => {
    const now = Date.now();
    if (!force && now - lastDashboardLoadAtRef.current < DASHBOARD_REFRESH_MIN_MS) {
      return;
    }

    if (isLoadingDashboardRef.current) {
      return;
    }

    isLoadingDashboardRef.current = true;

    try {
      if (force) {
        getResponseCache.clear();
      }

      const [usersResult, paymentsResult, requestsResult, offersResult] = await Promise.allSettled([
        apiFetch<User[]>('/api/users'),
        apiFetch<RawPayment[]>('/api/payments'),
        apiFetch<RawRequest[]>('/api/requests'),
        apiFetch<RawOffer[]>('/api/offers'),
      ]);

      let nextOffers: Offer[] | null = null;
      if (offersResult.status === 'fulfilled') {
        nextOffers = offersResult.value.map(normalizeOffer);
        setOffers(nextOffers);
      }

      if (usersResult.status === 'fulfilled') {
        setUsers(usersResult.value);
      }

      if (paymentsResult.status === 'fulfilled') {
        setPayments(paymentsResult.value.map(normalizePayment));
      }

      if (requestsResult.status === 'fulfilled') {
        const offersForCounts = nextOffers ?? [];
        setRequests(requestsResult.value.map((request) => normalizeRequest(request, offersForCounts)));
      }

      lastDashboardLoadAtRef.current = Date.now();
    } catch (error) {
      console.error('Failed to load admin dashboard data', error);
    } finally {
      isLoadingDashboardRef.current = false;
    }
  }, []);

  useEffect(() => {
    let mounted = true;

    const bootstrapAuth = async () => {
      try {
        const data = await apiFetch<AdminMeResponse>('/api/admin/me');
        if (!mounted) return;
        const authenticated = Boolean(data.authenticated);
        setIsLoggedIn(authenticated);
        setAdminEmail(data.email || '');

        if (authenticated) {
          await loadDashboardData(true);
        }
      } catch {
        if (!mounted) return;
        setIsLoggedIn(false);
        setAdminEmail('');
        setUsers([]);
        setPayments([]);
        setRequests([]);
        setOffers([]);
      } finally {
        if (mounted) {
          setIsAuthLoading(false);
        }
      }
    };

    void bootstrapAuth();

    return () => {
      mounted = false;
    };
  }, []);

  // Auto polling and passive auth-state reloading are disabled to avoid API spam.

  useEffect(() => {
    if (!isLoggedIn) return;

    const onFocus = () => {
      void loadDashboardData(true);
    };

    if (typeof window !== 'undefined') {
      window.addEventListener('focus', onFocus);
    }

    return () => {
      if (typeof window !== 'undefined') {
        window.removeEventListener('focus', onFocus);
      }
    };
  }, [isLoggedIn, loadDashboardData]);

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      setIsAuthLoading(true);
      await apiFetch<{ success: boolean; email: string }>('/api/admin/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });

      setIsLoggedIn(true);
      setAdminEmail(email);
      await loadDashboardData(true);
      return true;
    } catch {
      setIsLoggedIn(false);
      setAdminEmail('');
      return false;
    } finally {
      setIsAuthLoading(false);
    }
  };

  const logout = () => {
    void (async () => {
      try {
        await apiFetch('/api/admin/logout', { method: 'POST' });
      } catch (error) {
        console.error('Logout failed', error);
      } finally {
        setIsLoggedIn(false);
        setAdminEmail('');
        setUsers([]);
        setPayments([]);
        setRequests([]);
        setOffers([]);
        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }
      }
    })();
  };

  const updateUserStatus = (userId: string, status: 'active' | 'suspended') => {
    setUsers((prev) => prev.map((user) => (user.id === userId ? { ...user, accountStatus: status } : user)));

    void (async () => {
      try {
        const targetUser = users.find((u) => u.id === userId);
        const shouldActivateElectricianSubscription =
          status === 'active' && targetUser?.role === 'electrician';

        const startDate = new Date();
        const endDate = new Date(startDate);
        endDate.setMonth(endDate.getMonth() + 1);

        const payload: Record<string, unknown> = { accountStatus: status };
        if (shouldActivateElectricianSubscription) {
          payload.subscriptionStatus = 'active';
          payload.subscriptionStartDate = startDate.toISOString().split('T')[0];
          payload.subscriptionEndDate = endDate.toISOString().split('T')[0];
        }

        const updated = await apiFetch<User>(`/api/users/${userId}`, {
          method: 'PUT',
          body: JSON.stringify(payload),
        });
        setUsers((prev) => prev.map((user) => (user.id === userId ? updated : user)));
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const deleteUser = (userId: string) => {
    setUsers((prev) => prev.filter((user) => user.id !== userId));

    void (async () => {
      try {
        await apiFetch(`/api/users/${userId}`, { method: 'DELETE' });
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const approvePayment = (paymentId: string) => {
    setPayments((prev) => prev.map((payment) => (payment.id === paymentId ? { ...payment, status: 'approved' } : payment)));

    void (async () => {
      try {
        await apiFetch(`/api/payments/${paymentId}`, {
          method: 'PUT',
          body: JSON.stringify({ status: 'approved' }),
        });
        await loadDashboardData();
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const rejectPayment = (paymentId: string) => {
    setPayments((prev) => prev.map((payment) => (payment.id === paymentId ? { ...payment, status: 'rejected' } : payment)));

    void (async () => {
      try {
        await apiFetch(`/api/payments/${paymentId}`, {
          method: 'PUT',
          body: JSON.stringify({ status: 'rejected' }),
        });
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const activateSubscription = (electricianId: string, months: number) => {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + months);

    void (async () => {
      try {
        await apiFetch(`/api/users/${electricianId}`, {
          method: 'PUT',
          body: JSON.stringify({
            subscriptionStatus: 'active',
            subscriptionStartDate: startDate.toISOString().split('T')[0],
            subscriptionEndDate: endDate.toISOString().split('T')[0],
          }),
        });
        await loadDashboardData();
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const closeRequest = (requestId: string) => {
    setRequests((prev) => prev.map((request) => (request.id === requestId ? { ...request, status: 'closed' } : request)));

    void (async () => {
      try {
        await apiFetch(`/api/requests/${requestId}`, {
          method: 'PUT',
          body: JSON.stringify({ status: 'closed' }),
        });
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const deleteRequest = (requestId: string) => {
    setRequests((prev) => prev.filter((request) => request.id !== requestId));

    void (async () => {
      try {
        await apiFetch(`/api/requests/${requestId}`, { method: 'DELETE' });
      } catch {
        await loadDashboardData();
      }
    })();
  };

  const value = useMemo(
    () => ({
      isLoggedIn,
      isAuthLoading,
      adminEmail,
      login,
      logout,
      users,
      updateUserStatus,
      deleteUser,
      payments,
      approvePayment,
      rejectPayment,
      activateSubscription,
      requests,
      offers,
      closeRequest,
      deleteRequest,
    }),
    [
      isLoggedIn,
      isAuthLoading,
      adminEmail,
      users,
      payments,
      requests,
      offers,
    ]
  );

  return (
    <AdminContext.Provider value={value}>
      {children}
    </AdminContext.Provider>
  );
}

export function useAdmin() {
  const context = useContext(AdminContext);
  if (context === undefined) {
    throw new Error('useAdmin must be used within an AdminProvider');
  }
  return context;
}
