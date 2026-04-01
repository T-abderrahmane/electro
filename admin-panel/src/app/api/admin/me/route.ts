import { NextRequest, NextResponse } from 'next/server';

const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'admin@example.com';

export async function GET(request: NextRequest) {
  const token = request.cookies.get('admin_auth')?.value;

  if (token !== '1') {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  return NextResponse.json({ authenticated: true, email: ADMIN_EMAIL });
}
