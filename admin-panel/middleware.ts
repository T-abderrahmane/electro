import { NextRequest, NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  // Temporarily disabled - causes edge runtime issues on Vercel
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
