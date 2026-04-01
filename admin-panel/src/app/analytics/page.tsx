'use client';

import { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  Legend,
  AreaChart,
  Area
} from 'recharts';
import {
  TrendingUp,
  Users,
  DollarSign,
  ClipboardList,
  MapPin,
  Calendar,
  Zap,
  UserCheck,
  Clock
} from 'lucide-react';

export default function AnalyticsPage() {
  const { users, requests, payments } = useAdmin();
  const { language } = useUI();
  const tx = (ar: string, fr: string) => (language === 'fr' ? fr : ar);
  const [timeRange, setTimeRange] = useState('month');

  // Calculate stats
  const totalClients = users.filter(u => u.role === 'client').length;
  const totalElectricians = users.filter(u => u.role === 'electrician').length;
  const activeElectricians = users.filter(u => u.role === 'electrician' && u.subscriptionStatus === 'active').length;
  const approvedPayments = payments.filter(p => p.status === 'approved');
  const totalRevenue = approvedPayments.reduce((sum, p) => sum + p.amount, 0);

  // Requests by status
  const openRequests = requests.filter(r => r.status === 'open').length;
  const assignedRequests = requests.filter(r => r.status === 'assigned').length;
  const closedRequests = requests.filter(r => r.status === 'closed').length;

  // Data for charts
  const requestsByStatus = [
    { name: tx('مفتوح', 'Ouvert'), value: openRequests, color: '#3B82F6' },
    { name: tx('قيد التنفيذ', 'En cours'), value: assignedRequests, color: '#F59E0B' },
    { name: tx('مغلق', 'Ferme'), value: closedRequests, color: '#10B981' },
  ];

  const usersByRole = [
    { name: tx('عملاء', 'Clients'), value: totalClients, color: '#6366F1' },
    { name: tx('كهربائيين', 'Electriciens'), value: totalElectricians, color: '#8B5CF6' },
  ];

  // Requests by wilaya
  const requestsByWilaya = requests.reduce((acc, req) => {
    const existing = acc.find(w => w.wilaya === req.wilaya);
    if (existing) {
      existing.count++;
    } else {
      acc.push({ wilaya: req.wilaya, count: 1 });
    }
    return acc;
  }, [] as { wilaya: string; count: number }[]).sort((a, b) => b.count - a.count);

  // Electricians by wilaya
  const electricians = users.filter(u => u.role === 'electrician');
  const electriciansByWilaya = electricians.reduce((acc, elec) => {
    const existing = acc.find(w => w.wilaya === elec.wilaya);
    if (existing) {
      existing.count++;
    } else {
      acc.push({ wilaya: elec.wilaya || tx('غير محدد', 'Non specifie'), count: 1 });
    }
    return acc;
  }, [] as { wilaya: string; count: number }[]).sort((a, b) => b.count - a.count);

  // Monthly revenue simulation
  const monthlyRevenue = [
    { month: tx('يناير', 'Janvier'), revenue: 24000, target: 30000 },
    { month: tx('فبراير', 'Fevrier'), revenue: 27000, target: 30000 },
    { month: tx('مارس', 'Mars'), revenue: 33000, target: 35000 },
    { month: tx('أبريل', 'Avril'), revenue: 36000, target: 35000 },
    { month: tx('مايو', 'Mai'), revenue: 42000, target: 40000 },
    { month: tx('يونيو', 'Juin'), revenue: 45000, target: 45000 },
  ];

  // Weekly requests trend
  const weeklyTrend = [
    { day: tx('السبت', 'Samedi'), requests: 5, offers: 12 },
    { day: tx('الأحد', 'Dimanche'), requests: 8, offers: 18 },
    { day: tx('الاثنين', 'Lundi'), requests: 12, offers: 25 },
    { day: tx('الثلاثاء', 'Mardi'), requests: 10, offers: 22 },
    { day: tx('الأربعاء', 'Mercredi'), requests: 15, offers: 30 },
    { day: tx('الخميس', 'Jeudi'), requests: 9, offers: 20 },
    { day: tx('الجمعة', 'Vendredi'), requests: 6, offers: 14 },
  ];

  const COLORS = ['#3B82F6', '#F59E0B', '#10B981', '#6366F1', '#8B5CF6', '#EC4899'];

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{tx('التحليلات والإحصائيات', 'Analyses et statistiques')}</h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">{tx('نظرة شاملة على أداء المنصة', 'Vue d ensemble des performances de la plateforme')}</p>
        </div>
        <div className="mt-4 md:mt-0">
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value)}
            className="px-4 py-2 border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="week">{tx('الأسبوع الحالي', 'Semaine en cours')}</option>
            <option value="month">{tx('الشهر الحالي', 'Mois en cours')}</option>
            <option value="quarter">{tx('الربع الحالي', 'Trimestre en cours')}</option>
            <option value="year">{tx('السنة الحالية', 'Annee en cours')}</option>
          </select>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-5 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm">{tx('إجمالي المستخدمين', 'Total utilisateurs')}</p>
              <p className="text-3xl font-bold mt-1">{users.length}</p>
              <p className="text-blue-100 text-xs mt-2">{tx('+15% من الشهر الماضي', '+15% vs mois precedent')}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-xl">
              <Users size={28} />
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl p-5 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm">{tx('الكهربائيين النشطين', 'Electriciens actifs')}</p>
              <p className="text-3xl font-bold mt-1">{activeElectricians}</p>
              <p className="text-purple-100 text-xs mt-2">{tx('من أصل', 'sur')} {totalElectricians} {tx('مسجل', 'inscrits')}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-xl">
              <Zap size={28} />
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-5 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">{tx('إجمالي الإيرادات', 'Revenus totaux')}</p>
              <p className="text-3xl font-bold mt-1">{totalRevenue.toLocaleString('ar-DZ')}</p>
              <p className="text-green-100 text-xs mt-2">د.ج</p>
            </div>
            <div className="p-3 bg-white/20 rounded-xl">
              <DollarSign size={28} />
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-500 to-amber-600 rounded-xl p-5 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-amber-100 text-sm">{tx('إجمالي الطلبات', 'Total demandes')}</p>
              <p className="text-3xl font-bold mt-1">{requests.length}</p>
              <p className="text-amber-100 text-xs mt-2">{openRequests} {tx('طلب مفتوح', 'demandes ouvertes')}</p>
            </div>
            <div className="p-3 bg-white/20 rounded-xl">
              <ClipboardList size={28} />
            </div>
          </div>
        </div>
      </div>

      {/* Charts Row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        {/* Revenue Chart */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-semibold text-gray-900 dark:text-gray-100 flex items-center gap-2">
              <TrendingUp size={20} className="text-green-500" />
              {tx('الإيرادات الشهرية', 'Revenus mensuels')}
            </h3>
          </div>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={monthlyRevenue}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="month" tick={{ fill: '#6B7280', fontSize: 12 }} />
                <YAxis tick={{ fill: '#6B7280', fontSize: 12 }} />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#111827', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                  labelStyle={{ color: '#f3f4f6' }}
                  itemStyle={{ color: '#f3f4f6' }}
                  formatter={(value: any) => [`${Number(value).toLocaleString('ar-DZ')} د.ج`, '']}
                />
                <Legend />
                <Area 
                  type="monotone" 
                  dataKey="revenue" 
                  name={tx('الإيرادات', 'Revenus')} 
                  stroke="#10B981" 
                  fill="#10B98133" 
                  strokeWidth={2}
                />
                <Area 
                  type="monotone" 
                  dataKey="target" 
                  name={tx('الهدف', 'Objectif')} 
                  stroke="#6366F1" 
                  fill="#6366F133" 
                  strokeWidth={2}
                  strokeDasharray="5 5"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Weekly Trend */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-semibold text-gray-900 dark:text-gray-100 flex items-center gap-2">
              <Calendar size={20} className="text-blue-500" />
              {tx('النشاط الأسبوعي', 'Activite hebdomadaire')}
            </h3>
          </div>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={weeklyTrend}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="day" tick={{ fill: '#6B7280', fontSize: 12 }} />
                <YAxis tick={{ fill: '#6B7280', fontSize: 12 }} />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#111827', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                  labelStyle={{ color: '#f3f4f6' }}
                  itemStyle={{ color: '#f3f4f6' }}
                />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="requests" 
                  name={tx('الطلبات', 'Demandes')} 
                  stroke="#3B82F6" 
                  strokeWidth={2}
                  dot={{ fill: '#3B82F6', strokeWidth: 2 }}
                />
                <Line 
                  type="monotone" 
                  dataKey="offers" 
                  name={tx('العروض', 'Offres')} 
                  stroke="#8B5CF6" 
                  strokeWidth={2}
                  dot={{ fill: '#8B5CF6', strokeWidth: 2 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Charts Row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        {/* Requests by Status */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-6 flex items-center gap-2">
            <ClipboardList size={20} className="text-amber-500" />
            {tx('الطلبات حسب الحالة', 'Demandes par statut')}
          </h3>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={requestsByStatus}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {requestsByStatus.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip 
                  formatter={(value: any) => [value, tx('طلب', 'demande')]}
                  contentStyle={{ 
                    backgroundColor: '#111827', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                  labelStyle={{ color: '#f3f4f6' }}
                  itemStyle={{ color: '#f3f4f6' }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex justify-center gap-4 mt-4">
            {requestsByStatus.map((item, index) => (
              <div key={index} className="flex items-center gap-2">
                <div 
                  className="w-3 h-3 rounded-full" 
                  style={{ backgroundColor: item.color }}
                />
                <span className="text-sm text-gray-600 dark:text-gray-300">{item.name}: {item.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Users Distribution */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-6 flex items-center gap-2">
            <Users size={20} className="text-purple-500" />
            {tx('توزيع المستخدمين', 'Repartition des utilisateurs')}
          </h3>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={usersByRole}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {usersByRole.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip 
                  formatter={(value: any) => [value, tx('مستخدم', 'utilisateur')]}
                  contentStyle={{ 
                    backgroundColor: '#111827', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                  labelStyle={{ color: '#f3f4f6' }}
                  itemStyle={{ color: '#f3f4f6' }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex justify-center gap-4 mt-4">
            {usersByRole.map((item, index) => (
              <div key={index} className="flex items-center gap-2">
                <div 
                  className="w-3 h-3 rounded-full" 
                  style={{ backgroundColor: item.color }}
                />
                <span className="text-sm text-gray-600 dark:text-gray-300">{item.name}: {item.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Stats */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-6 flex items-center gap-2">
            <Clock size={20} className="text-blue-500" />
            {tx('إحصائيات سريعة', 'Statistiques rapides')}
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <span className="text-gray-600 dark:text-gray-300">{tx('معدل التحويل', 'Taux de conversion')}</span>
              <span className="font-semibold text-gray-900 dark:text-gray-100">68%</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <span className="text-gray-600 dark:text-gray-300">{tx('متوسط العروض/طلب', 'Moyenne offres/demande')}</span>
              <span className="font-semibold text-gray-900 dark:text-gray-100">3.2</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <span className="text-gray-600 dark:text-gray-300">{tx('وقت الاستجابة المتوسط', 'Temps moyen de reponse')}</span>
              <span className="font-semibold text-gray-900 dark:text-gray-100">45 دقيقة</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-600">{tx('رضا العملاء', 'Satisfaction clients')}</span>
              <span className="font-semibold text-green-600">4.7/5</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <span className="text-gray-600 dark:text-gray-300">{tx('معدل تجديد الاشتراك', 'Taux de renouvellement')}</span>
              <span className="font-semibold text-gray-900 dark:text-gray-100">85%</span>
            </div>
          </div>
        </div>
      </div>

      {/* Geographic Distribution */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Requests by Wilaya */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-6 flex items-center gap-2">
            <MapPin size={20} className="text-red-500" />
            {tx('الطلبات حسب الولاية', 'Demandes par wilaya')}
          </h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={requestsByWilaya} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis type="number" tick={{ fill: '#6B7280', fontSize: 12 }} />
                <YAxis 
                  dataKey="wilaya" 
                  type="category" 
                  tick={{ fill: '#6B7280', fontSize: 12 }}
                  width={80}
                />
                <Tooltip 
                  formatter={(value: any) => [value, tx('طلب', 'demande')]}
                  contentStyle={{ 
                    backgroundColor: '#111827', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                  labelStyle={{ color: '#f3f4f6' }}
                  itemStyle={{ color: '#f3f4f6' }}
                />
                <Bar dataKey="count" fill="#3B82F6" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Electricians by Wilaya */}
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-700 shadow-sm p-6">
          <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-6 flex items-center gap-2">
            <UserCheck size={20} className="text-purple-500" />
            {tx('الكهربائيين حسب الولاية', 'Electriciens par wilaya')}
          </h3>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={electriciansByWilaya} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis type="number" tick={{ fill: '#6B7280', fontSize: 12 }} />
                <YAxis 
                  dataKey="wilaya" 
                  type="category" 
                  tick={{ fill: '#6B7280', fontSize: 12 }}
                  width={80}
                />
                <Tooltip 
                  formatter={(value: any) => [value, tx('كهربائي', 'electricien')]}
                  contentStyle={{ 
                    backgroundColor: '#111827', 
                    border: '1px solid #374151',
                    borderRadius: '8px'
                  }}
                  labelStyle={{ color: '#f3f4f6' }}
                  itemStyle={{ color: '#f3f4f6' }}
                />
                <Bar dataKey="count" fill="#8B5CF6" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}
