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

// GET /api/payments
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const electricianId = searchParams.get('electricianId');
  const status = searchParams.get('status');
  
  const db = await getDatabase();
  let payments = db.payments;
  
  if (electricianId) {
    payments = payments.filter(p => p.electricianId === electricianId);
  }
  
  if (status) {
    payments = payments.filter(p => p.status === status);
  }
  
  // Sort by creation date descending
  payments.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  
  return NextResponse.json(payments);
}

// POST /api/payments - Submit subscription payment
export async function POST(request: NextRequest) {
  const body = await request.json();
  const db = await getDatabase();
  
  // Get electrician info
  const electrician = db.users.find(u => u.id === body.electricianId);
  if (!electrician) {
    return NextResponse.json({ error: 'Electrician not found' }, { status: 404 });
  }
  
  const newPayment = {
    id: `p${Date.now()}`,
    ...body,
    electricianName: electrician.name,
    amount: 3000, // Fixed subscription price
    status: 'pending',
    createdAt: new Date().toISOString(),
  };
  
  db.payments.push(newPayment);
  await saveDatabase(db);
  
  return NextResponse.json(newPayment, { status: 201 });
}
