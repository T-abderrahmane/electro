'use client';

import { ReactNode } from 'react';
import { usePathname } from 'next/navigation';
import Sidebar from '@/components/Sidebar';

function ShellContent({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const isLoginPage = pathname === '/login';

  return (
    <div className="min-h-screen">
      {!isLoginPage && <Sidebar />}
      <main className={isLoginPage ? 'min-h-screen' : 'lg:mr-64 min-h-screen'}>{children}</main>
    </div>
  );
}

export default function AppShell({ children }: { children: ReactNode }) {
  return <ShellContent>{children}</ShellContent>;
}
