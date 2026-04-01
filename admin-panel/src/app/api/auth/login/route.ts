import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '@/lib/database';

function normalizePhone(value: unknown): string {
  return String(value ?? '').replace(/\s+/g, '');
}

// OPTIONS /api/auth/login - CORS preflight
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

// POST /api/auth/login
export async function POST(request: NextRequest) {
  const { phone, password, role } = await request.json();
  const normalizedPhone = normalizePhone(phone);

  if (!normalizedPhone || !password || !role) {
    return NextResponse.json(
      { error: 'Phone, password and role are required' },
      { status: 400 }
    );
  }
  
  const db = await getDatabase();
  const user = db.users.find(
    (u) => normalizePhone(u.phone) === normalizedPhone && u.role === role
  );
  
  if (!user) {
    return NextResponse.json(
      { error: 'Invalid credentials' },
      { status: 401 }
    );
  }

  const storedPassword = (user as { password?: string }).password;
  // Backward-compatibility: legacy seeded users may not have a password field.
  if (storedPassword != null && storedPassword !== '' && storedPassword !== password) {
    return NextResponse.json(
      { error: 'Invalid credentials' },
      { status: 401 }
    );
  }
  
  if (user.accountStatus === 'suspended') {
    return NextResponse.json(
      { error: 'Account suspended' },
      { status: 403 }
    );
  }
  
  // In production, verify password hash and generate JWT token
  // For now, return user data directly
  return NextResponse.json({
    user,
    token: `mock_token_${user.id}_${Date.now()}`,
  });
}
