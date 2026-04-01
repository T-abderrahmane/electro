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

// GET /api/requests
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const clientId = searchParams.get('clientId');
  const wilaya = searchParams.get('wilaya');
  const status = searchParams.get('status');
  const electricianId = searchParams.get('electricianId');
  
  const db = await getDatabase();
  let requests = db.requests;
  
  if (clientId) {
    requests = requests.filter(r => r.clientId === clientId);
  }
  
  if (wilaya) {
    requests = requests.filter(r => r.wilaya === wilaya);
  }
  
  if (status) {
    requests = requests.filter(r => r.status === status);
  }
  
  if (electricianId) {
    requests = requests.filter(r => r.assignedElectricianId === electricianId);
  }
  
  // Sort by creation date descending
  requests.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  
  return NextResponse.json(requests);
}

// POST /api/requests
export async function POST(request: NextRequest) {
  const body = await request.json();
  const db = await getDatabase();
  
  // Get client info
  const client = db.users.find(u => u.id === body.clientId);
  
  const newRequest = {
    id: `r${Date.now()}`,
    ...body,
    clientName: client?.name || body.clientName,
    clientPhone: client?.phone || body.clientPhone,
    status: 'open',
    createdAt: new Date().toISOString(),
  };
  
  db.requests.push(newRequest);
  await saveDatabase(db);
  
  return NextResponse.json(newRequest, { status: 201 });
}
