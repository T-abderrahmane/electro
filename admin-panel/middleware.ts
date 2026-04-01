import { NextRequest, NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  try {
    const { pathname } = request.nextUrl;

    if (pathname === '/login') {
      const token = request.cookies.get('admin_auth')?.value;
      if (token === '1') {
        return NextResponse.redirect(new URL('/', request.url));
      }
      return NextResponse.next();
    }

    const token = request.cookies.get('admin_auth')?.value;
    if (token !== '1') {
      return NextResponse.redirect(new URL('/login', request.url));
    }

    return NextResponse.next();
  } catch (error) {
    // If middleware fails, allow request through
    return NextResponse.next();
  }
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};

export const runtime = 'nodejs';
