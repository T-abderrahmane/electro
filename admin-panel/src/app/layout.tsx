import type { Metadata } from "next";
import "./globals.css";
import { AdminProvider } from "@/context/AdminContext";
import { UIProvider } from "@/context/UIContext";
import AppShell from "@/components/AppShell";

export const metadata: Metadata = {
  title: "لوحة الإدارة - منصة الكهربائيين",
  description: "لوحة تحكم إدارية لمنصة الكهربائيين في الجزائر",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className="antialiased bg-gray-50 dark:bg-gray-950 text-gray-900 dark:text-gray-50">
        <UIProvider>
          <AdminProvider>
            <AppShell>{children}</AppShell>
          </AdminProvider>
        </UIProvider>
      </body>
    </html>
  );
}
