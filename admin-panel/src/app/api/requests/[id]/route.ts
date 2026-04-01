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

// GET /api/requests/[id]
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const db = await getDatabase();
  const serviceRequest = db.requests.find(r => r.id === id);
  
  if (!serviceRequest) {
    return NextResponse.json({ error: 'Request not found' }, { status: 404 });
  }
  
  return NextResponse.json(serviceRequest);
}

// PUT /api/requests/[id]
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();
  const db = await getDatabase();
  
  const requestIndex = db.requests.findIndex(r => r.id === id);
  if (requestIndex === -1) {
    return NextResponse.json({ error: 'Request not found' }, { status: 404 });
  }
  
  db.requests[requestIndex] = { ...db.requests[requestIndex], ...body };
  await saveDatabase(db);
  
  return NextResponse.json(db.requests[requestIndex]);
}

// DELETE /api/requests/[id]
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const db = await getDatabase();
  
  const requestIndex = db.requests.findIndex(r => r.id === id);
  if (requestIndex === -1) {
    return NextResponse.json({ error: 'Request not found' }, { status: 404 });
  }
  
  db.requests.splice(requestIndex, 1);
  await saveDatabase(db);
  
  return NextResponse.json({ success: true });
}
