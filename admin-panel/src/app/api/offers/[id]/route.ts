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

// GET /api/offers/[id]
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const db = await getDatabase();
  const offer = db.offers.find(o => o.id === id);
  
  if (!offer) {
    return NextResponse.json({ error: 'Offer not found' }, { status: 404 });
  }
  
  return NextResponse.json(offer);
}

// PUT /api/offers/[id] - Update offer (accept/reject)
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();
  const db = await getDatabase();
  
  const offerIndex = db.offers.findIndex(o => o.id === id);
  if (offerIndex === -1) {
    return NextResponse.json({ error: 'Offer not found' }, { status: 404 });
  }
  
  const offer = db.offers[offerIndex];
  db.offers[offerIndex] = { ...offer, ...body };
  
  // If offer is accepted, update request and reject other offers
  if (body.status === 'accepted') {
    // Update request
    const requestIndex = db.requests.findIndex(r => r.id === offer.requestId);
    if (requestIndex !== -1) {
      db.requests[requestIndex].status = 'assigned';
      db.requests[requestIndex].assignedElectricianId = offer.electricianId;
    }
    
    // Reject other offers for same request
    db.offers.forEach((o, i) => {
      if (o.requestId === offer.requestId && o.id !== id) {
        db.offers[i].status = 'rejected';
      }
    });
  }
  
  await saveDatabase(db);
  
  return NextResponse.json(db.offers[offerIndex]);
}

// DELETE /api/offers/[id]
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const db = await getDatabase();
  
  const offerIndex = db.offers.findIndex(o => o.id === id);
  if (offerIndex === -1) {
    return NextResponse.json({ error: 'Offer not found' }, { status: 404 });
  }
  
  db.offers.splice(offerIndex, 1);
  await saveDatabase(db);
  
  return NextResponse.json({ success: true });
}
