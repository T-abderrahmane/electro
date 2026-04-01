import { NextRequest, NextResponse } from 'next/server';
import { getDatabase, saveDatabase } from '@/lib/database';

function normalizePhone(value: unknown): string {
  return String(value ?? '').replace(/\s+/g, '');
}

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

// GET /api/users - Get all users or filter by role
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const role = searchParams.get('role');
  const phone = searchParams.get('phone');
  const normalizedPhone = phone ? normalizePhone(phone) : null;
  
  const db = await getDatabase();
  let users = db.users;
  
  if (role) {
    users = users.filter(u => u.role === role);
  }
  
  if (normalizedPhone) {
    users = users.filter((u) => normalizePhone(u.phone) === normalizedPhone);
  }
  
  return NextResponse.json(users);
}

// POST /api/users - Create new user
export async function POST(request: NextRequest) {
  const body = await request.json();
  const db = await getDatabase();
  const normalizedPhone = normalizePhone(body.phone);

  if (!body.name || !normalizedPhone || !body.password || !body.role) {
    return NextResponse.json(
      { error: 'name, phone, password and role are required' },
      { status: 400 }
    );
  }

  if (body.role !== 'client' && body.role !== 'electrician') {
    return NextResponse.json(
      { error: 'Invalid role' },
      { status: 400 }
    );
  }
  
  // Allow one account per role for the same phone.
  const existingUser = db.users.find(
    (u) => normalizePhone(u.phone) === normalizedPhone && u.role === body.role
  );
  if (existingUser) {
    return NextResponse.json(
      { error: 'Phone number already registered for this role' },
      { status: 400 }
    );
  }
  
  const newUser = {
    id: `u${Date.now()}`,
    ...body,
    phone: normalizedPhone,
    createdAt: new Date().toISOString(),
    accountStatus: 'active',
    subscriptionStatus: body.role === 'electrician' ? 'pending' : undefined,
  };
  
  db.users.push(newUser);
  await saveDatabase(db);
  
  return NextResponse.json(newUser, { status: 201 });
}
