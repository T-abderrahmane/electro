import { NextResponse } from 'next/server';
import { getDatabase } from '@/lib/database';

// GET /api/analytics
export async function GET() {
  const db = await getDatabase();
  
  const users = db.users;
  const requests = db.requests;
  const payments = db.payments;
  
  const clients = users.filter(u => u.role === 'client');
  const electricians = users.filter(u => u.role === 'electrician');
  const activeSubscriptions = electricians.filter(e => e.subscriptionStatus === 'active');
  const pendingPayments = payments.filter(p => p.status === 'pending');
  const approvedPayments = payments.filter(p => p.status === 'approved');
  
  const totalRevenue = approvedPayments.reduce((sum, p) => sum + p.amount, 0);
  
  const requestsByStatus = {
    pending: requests.filter(r => r.status === 'pending').length,
    open: requests.filter(r => r.status === 'open').length,
    assigned: requests.filter(r => r.status === 'assigned').length,
    completed: requests.filter(r => r.status === 'completed').length,
    closed: requests.filter(r => r.status === 'closed').length,
  };
  
  // Group by wilaya
  const requestsByWilaya: Record<string, number> = {};
  requests.forEach(r => {
    requestsByWilaya[r.wilaya] = (requestsByWilaya[r.wilaya] || 0) + 1;
  });
  
  const electriciansByWilaya: Record<string, number> = {};
  electricians.forEach(e => {
    if (e.wilaya) {
      electriciansByWilaya[e.wilaya] = (electriciansByWilaya[e.wilaya] || 0) + 1;
    }
  });
  
  return NextResponse.json({
    overview: {
      totalUsers: users.length,
      totalClients: clients.length,
      totalElectricians: electricians.length,
      activeSubscriptions: activeSubscriptions.length,
      totalRequests: requests.length,
      pendingPayments: pendingPayments.length,
      totalRevenue,
    },
    requestsByStatus,
    requestsByWilaya,
    electriciansByWilaya,
    recentActivity: {
      recentRequests: requests.slice(0, 5),
      recentPayments: payments.slice(0, 5),
    },
  });
}
