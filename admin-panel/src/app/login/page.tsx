'use client';

import { FormEvent, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';
import { Languages, Moon, Sun } from 'lucide-react';

export default function LoginPage() {
  const { login, isAuthLoading } = useAdmin();
  const router = useRouter();
  const { t, language, toggleLanguage, theme, toggleTheme } = useUI();
  const [email, setEmail] = useState('admin@example.com');
  const [password, setPassword] = useState('admin123');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);

    const ok = await login(email, password);
    if (!ok) {
      setError(t('login.invalid'));
    } else {
      router.push('/');
    }

    setIsSubmitting(false);
  };

  if (isAuthLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p className="text-gray-500">{t('login.checking')}</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div className="w-full max-w-md bg-white rounded-2xl border border-gray-100 shadow-sm p-8">
        <div className="flex items-center justify-end gap-2 mb-4">
          <button
            type="button"
            onClick={toggleLanguage}
            className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs bg-gray-100 text-gray-700 hover:bg-gray-200"
          >
            <Languages size={14} />
            {language === 'ar' ? t('settings.french') : t('settings.arabic')}
          </button>
          <button
            type="button"
            onClick={toggleTheme}
            className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs bg-gray-100 text-gray-700 hover:bg-gray-200"
          >
            {theme === 'dark' ? <Sun size={14} /> : <Moon size={14} />}
            {theme === 'dark' ? t('settings.light') : t('settings.dark')}
          </button>
        </div>

        <h1 className="text-2xl font-bold text-gray-900 mb-2 text-center">{t('login.title')}</h1>
        <p className="text-gray-500 text-sm text-center mb-6">{t('login.subtitle')}</p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">{t('login.email')}</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-3 py-2 rounded-lg border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">{t('login.password')}</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-3 py-2 rounded-lg border border-gray-200 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          {error && (
            <p className="text-sm text-red-600">{error}</p>
          )}

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full py-2.5 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700 disabled:opacity-60"
          >
            {isSubmitting ? t('login.loading') : t('login.submit')}
          </button>
        </form>
      </div>
    </div>
  );
}
