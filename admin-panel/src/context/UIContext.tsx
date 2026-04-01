'use client';

import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';

type Language = 'ar' | 'fr';
type Theme = 'light' | 'dark';

interface UIContextType {
  language: Language;
  theme: Theme;
  setLanguage: (language: Language) => void;
  toggleLanguage: () => void;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
  t: (key: string) => string;
}

const UIContext = createContext<UIContextType | undefined>(undefined);

const translations: Record<Language, Record<string, string>> = {
  ar: {
    'nav.dashboard': 'لوحة التحكم',
    'nav.users': 'إدارة المستخدمين',
    'nav.electricians': 'التحقق من الكهربائيين',
    'nav.subscriptions': 'إدارة الاشتراكات',
    'nav.requests': 'إدارة الطلبات',
    'nav.analytics': 'الإحصائيات',
    'sidebar.title': 'لوحة الإدارة',
    'sidebar.subtitle': 'خدمات الكهرباء',
    'sidebar.loggedInAs': 'مسجل الدخول كـ',
    'sidebar.logout': 'تسجيل الخروج',
    'settings.language': 'اللغة',
    'settings.theme': 'المظهر',
    'settings.arabic': 'العربية',
    'settings.french': 'Français',
    'settings.light': 'فاتح',
    'settings.dark': 'داكن',
    'settings.toggleLanguage': 'عربي / فرنسي',
    'settings.toggleTheme': 'تغيير المظهر',
    'login.title': 'تسجيل دخول الإدارة',
    'login.subtitle': 'أدخل بيانات المشرف للوصول إلى لوحة التحكم',
    'login.email': 'البريد الإلكتروني',
    'login.password': 'كلمة المرور',
    'login.submit': 'تسجيل الدخول',
    'login.loading': 'جاري الدخول...',
    'login.invalid': 'بيانات الدخول غير صحيحة',
    'login.checking': 'جاري التحقق من الجلسة...',
    'page.dashboard.title': 'لوحة التحكم',
    'page.dashboard.subtitle': 'نظرة عامة على أداء المنصة',
    'page.users.title': 'إدارة المستخدمين',
    'page.users.subtitle': 'عرض وإدارة جميع مستخدمي المنصة',
    'page.electricians.title': 'التحقق من الكهربائيين',
    'page.electricians.subtitle': 'عرض وإدارة حسابات الكهربائيين والتحقق من هوياتهم',
    'page.subscriptions.title': 'إدارة الاشتراكات',
    'page.subscriptions.subtitle': 'مراجعة المدفوعات وتفعيل الاشتراكات',
    'page.requests.title': 'إدارة الطلبات',
    'page.requests.subtitle': 'عرض وإدارة جميع طلبات الخدمة',
    'page.analytics.title': 'الإحصائيات',
    'page.analytics.subtitle': 'تحليل شامل لأداء المنصة',
  },
  fr: {
    'nav.dashboard': 'Tableau de bord',
    'nav.users': 'Utilisateurs',
    'nav.electricians': 'Electriciens',
    'nav.subscriptions': 'Abonnements',
    'nav.requests': 'Demandes',
    'nav.analytics': 'Statistiques',
    'sidebar.title': 'Panneau Admin',
    'sidebar.subtitle': 'Services electriques',
    'sidebar.loggedInAs': 'Connecte en tant que',
    'sidebar.logout': 'Se deconnecter',
    'settings.language': 'Langue',
    'settings.theme': 'Theme',
    'settings.arabic': 'Arabe',
    'settings.french': 'Français',
    'settings.light': 'Clair',
    'settings.dark': 'Sombre',
    'settings.toggleLanguage': 'Arabe / Français',
    'settings.toggleTheme': 'Changer le theme',
    'login.title': 'Connexion Admin',
    'login.subtitle': 'Entrez vos identifiants administrateur',
    'login.email': 'Email',
    'login.password': 'Mot de passe',
    'login.submit': 'Se connecter',
    'login.loading': 'Connexion...',
    'login.invalid': 'Identifiants invalides',
    'login.checking': 'Verification de session...',
    'page.dashboard.title': 'Tableau de bord',
    'page.dashboard.subtitle': 'Vue d ensemble des performances de la plateforme',
    'page.users.title': 'Gestion des utilisateurs',
    'page.users.subtitle': 'Afficher et gerer tous les utilisateurs',
    'page.electricians.title': 'Verification des electriciens',
    'page.electricians.subtitle': 'Afficher et gerer les comptes electriciens',
    'page.subscriptions.title': 'Gestion des abonnements',
    'page.subscriptions.subtitle': 'Verifier les paiements et activer les abonnements',
    'page.requests.title': 'Gestion des demandes',
    'page.requests.subtitle': 'Afficher et gerer les demandes de service',
    'page.analytics.title': 'Statistiques',
    'page.analytics.subtitle': 'Analyse globale des performances',
  },
};

export function UIProvider({ children }: { children: React.ReactNode }) {
  const [language, setLanguageState] = useState<Language>('ar');
  const [theme, setThemeState] = useState<Theme>('light');

  useEffect(() => {
    if (typeof window === 'undefined') return;

    const savedLanguage = localStorage.getItem('admin_language') as Language | null;
    const savedTheme = localStorage.getItem('admin_theme') as Theme | null;

    if (savedLanguage === 'ar' || savedLanguage === 'fr') {
      setLanguageState(savedLanguage);
    }

    if (savedTheme === 'light' || savedTheme === 'dark') {
      setThemeState(savedTheme);
    }
  }, []);

  useEffect(() => {
    if (typeof document === 'undefined') return;

    document.documentElement.lang = language;
    document.documentElement.dir = language === 'ar' ? 'rtl' : 'ltr';
    localStorage.setItem('admin_language', language);
  }, [language]);

  useEffect(() => {
    if (typeof document === 'undefined') return;

    document.documentElement.classList.toggle('dark', theme === 'dark');
    localStorage.setItem('admin_theme', theme);
  }, [theme]);

  const setLanguage = (nextLanguage: Language) => {
    setLanguageState(nextLanguage);
  };

  const toggleLanguage = () => {
    setLanguageState((prev) => (prev === 'ar' ? 'fr' : 'ar'));
  };

  const setTheme = (nextTheme: Theme) => {
    setThemeState(nextTheme);
  };

  const toggleTheme = () => {
    setThemeState((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  const t = (key: string) => {
    return translations[language][key] || key;
  };

  const value = useMemo(
    () => ({
      language,
      theme,
      setLanguage,
      toggleLanguage,
      setTheme,
      toggleTheme,
      t,
    }),
    [language, theme]
  );

  return <UIContext.Provider value={value}>{children}</UIContext.Provider>;
}

export function useUI() {
  const context = useContext(UIContext);
  if (!context) {
    throw new Error('useUI must be used within UIProvider');
  }
  return context;
}
