import { NextRequest, NextResponse } from 'next/server';
import { getDatabase, saveDatabase } from '@/lib/database';

// OPTIONS - CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}

// GET /api/payments/[id]
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const db = await getDatabase();
  const payment = db.payments.find(p => p.id === id);
  
  if (!payment) {
    return NextResponse.json({ error: 'Payment not found' }, { status: 404 });
  }
  
  return NextResponse.json(payment);
}

// PUT /api/payments/[id] - Approve/reject payment
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();
  const db = await getDatabase();
  
  const paymentIndex = db.payments.findIndex(p => p.id === id);
  if (paymentIndex === -1) {
    return NextResponse.json({ error: 'Payment not found' }, { status: 404 });
  }
  
  const payment = db.payments[paymentIndex];
  db.payments[paymentIndex] = { ...payment, ...body };
  
  // If payment is approved, activate subscription
  if (body.status === 'approved') {
    const userIndex = db.users.findIndex(u => u.id === payment.electricianId);
    if (userIndex !== -1) {
      const startDate = new Date();
      const endDate = new Date();
      endDate.setMonth(endDate.getMonth() + 1);
      
      db.users[userIndex] = {
        ...db.users[userIndex],
        subscriptionStatus: 'active',
        subscriptionStartDate: startDate.toISOString().split('T')[0],
        subscriptionEndDate: endDate.toISOString().split('T')[0],
      };
    }
  }
  
  await saveDatabase(db);
  
  return NextResponse.json(db.payments[paymentIndex]);
}
