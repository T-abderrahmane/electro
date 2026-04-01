'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  Users, 
  UserCheck, 
  CreditCard, 
  ClipboardList,
  BarChart3,
  LogOut,
  Zap,
  Menu,
  X,
  Moon,
  Sun,
  Languages
} from 'lucide-react';
import { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';

const navItems = [
  { href: '/', key: 'nav.dashboard', icon: LayoutDashboard },
  { href: '/users', key: 'nav.users', icon: Users },
  { href: '/electricians', key: 'nav.electricians', icon: UserCheck },
  { href: '/subscriptions', key: 'nav.subscriptions', icon: CreditCard },
  { href: '/requests', key: 'nav.requests', icon: ClipboardList },
  { href: '/analytics', key: 'nav.analytics', icon: BarChart3 },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { logout, adminEmail } = useAdmin();
  const { t, toggleLanguage, toggleTheme, language, theme } = useUI();
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      {/* Mobile menu button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="lg:hidden fixed top-4 right-4 z-50 p-2 rounded-lg bg-blue-600 text-white shadow-lg"
      >
        {isOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Overlay for mobile */}
      {isOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black/50 z-30"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`
          fixed top-0 right-0 h-full w-64 bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 shadow-xl z-40
          transform transition-transform duration-300 ease-in-out
          lg:translate-x-0 ${isOpen ? 'translate-x-0' : 'translate-x-full lg:translate-x-0'}
        `}
      >
        <div className="flex flex-col h-full">
          {/* Logo */}
          <div className="p-6 border-b border-gray-100 dark:border-gray-700 dark:bg-gray-900">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
                <Zap className="text-white" size={24} />
              </div>
              <div>
                <h1 className="font-bold text-gray-900 dark:text-white">{t('sidebar.title')}</h1>
                <p className="text-xs text-gray-500 dark:text-gray-400">{t('sidebar.subtitle')}</p>
              </div>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 overflow-y-auto">
            <ul className="space-y-1">
              {navItems.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href;
                
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      onClick={() => setIsOpen(false)}
                      className={`
                        flex items-center gap-3 px-4 py-3 rounded-lg transition-all
                        ${isActive 
                          ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 font-medium' 
                          : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-200'}
                      `}
                    >
                      <Icon size={20} />
                      <span>{t(item.key)}</span>
                    </Link>
                  </li>
                );
              })}
            </ul>
          </nav>

          {/* Settings Section */}
          <div className="p-4 border-t border-gray-200 bg-gray-50 dark:bg-gray-900 dark:border-gray-700">
            <div className="space-y-2">
              {/* Language Toggle */}
              <button
                onClick={toggleLanguage}
                className="flex items-center gap-3 w-full px-4 py-2 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-blue-100 dark:hover:bg-blue-900/30 transition-colors"
                title={t('settings.language')}
              >
                <Languages size={20} />
                <span className="text-sm font-medium">{language === 'ar' ? 'العربية' : 'Français'}</span>
              </button>

              {/* Theme Toggle */}
              <button
                onClick={toggleTheme}
                className="flex items-center gap-3 w-full px-4 py-2 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-yellow-100 dark:hover:bg-yellow-900/30 transition-colors"
                title={t('settings.theme')}
              >
                {theme === 'light' ? <Moon size={20} /> : <Sun size={20} />}
                <span className="text-sm font-medium">{theme === 'light' ? t('settings.dark') : t('settings.light')}</span>
              </button>
            </div>
          </div>

          {/* User info & Logout */}
          <div className="p-4 border-t border-gray-100 dark:border-gray-700 dark:bg-gray-900">
            <div className="mb-3 px-4">
              <p className="text-sm text-gray-500 dark:text-gray-400">{t('sidebar.loggedInAs')}</p>
              <p className="text-sm font-medium text-gray-900 dark:text-white truncate">{adminEmail}</p>
            </div>
            <button
              onClick={logout}
              className="flex items-center gap-3 w-full px-4 py-3 rounded-lg text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
            >
              <LogOut size={20} />
              <span>{t('sidebar.logout')}</span>
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
