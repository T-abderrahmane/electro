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

// GET /api/offers
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const requestId = searchParams.get('requestId');
  const electricianId = searchParams.get('electricianId');
  const status = searchParams.get('status');
  
  const db = await getDatabase();
  let offers = db.offers;
  
  if (requestId) {
    offers = offers.filter(o => o.requestId === requestId);
  }
  
  if (electricianId) {
    offers = offers.filter(o => o.electricianId === electricianId);
  }
  
  if (status) {
    offers = offers.filter(o => o.status === status);
  }
  
  return NextResponse.json(offers);
}

// POST /api/offers
export async function POST(request: NextRequest) {
  const body = await request.json();
  const db = await getDatabase();
  
  // Get electrician info
  const electrician = db.users.find(u => u.id === body.electricianId);
  
  // Check if electrician has active or pending subscription
  if (electrician?.subscriptionStatus !== 'active' && electrician?.subscriptionStatus !== 'pending') {
    return NextResponse.json(
      { error: 'Subscription required to send offers' },
      { status: 403 }
    );
  }
  
  // Check if electrician already sent offer for this request
  const existingOffer = db.offers.find(
    o => o.requestId === body.requestId && o.electricianId === body.electricianId
  );
  if (existingOffer) {
    return NextResponse.json(
      { error: 'You already sent an offer for this request' },
      { status: 400 }
    );
  }
  
  const newOffer = {
    id: `o${Date.now()}`,
    ...body,
    electricianName: electrician?.name || body.electricianName,
    status: 'pending',
    createdAt: new Date().toISOString(),
  };
  
  db.offers.push(newOffer);
  
  // Update request status to open if pending
  const requestIndex = db.requests.findIndex(r => r.id === body.requestId);
  if (requestIndex !== -1 && db.requests[requestIndex].status === 'pending') {
    db.requests[requestIndex].status = 'open';
  }
  
  await saveDatabase(db);
  
  return NextResponse.json(newOffer, { status: 201 });
}
