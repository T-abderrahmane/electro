"use client";

import React from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  AreaChart,
  Area,
} from "recharts";
import {
  Users,
  Wrench,
  CreditCard,
  Clock,
  FileText,
  MessageSquare,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Activity,
  MapPin,
  Star,
  Bell,
} from "lucide-react";
import {
  dashboardStats,
  requestsPerWilaya,
  electriciansPerWilaya,
  monthlyRevenue,
  subscriptionStatus,
  requestStatus,
  weeklyTrend,
  topElectricians,
  recentActivity,
} from "@/data/mockData";
import { useUI } from "@/context/UIContext";

// Stat Card Component
interface StatCardProps {
  title: string;
  value: number | string;
  icon: React.ReactNode;
  trend?: number;
  color: string;
  trendText: string;
  locale: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon, trend, color, trendText, locale }) => {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6 hover:shadow-md transition-shadow">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-gray-500 dark:text-gray-400 text-sm mb-1">{title}</p>
          <h3 className="text-2xl font-bold text-gray-800 dark:text-gray-100">
            {typeof value === "number" ? value.toLocaleString(locale) : value}
          </h3>
          {trend !== undefined && (
            <div className={`flex items-center mt-2 text-sm ${trend >= 0 ? "text-green-600" : "text-red-600"}`}>
              {trend >= 0 ? <TrendingUp className="w-4 h-4 ml-1" /> : <TrendingDown className="w-4 h-4 ml-1" />}
              <span>{Math.abs(trend)}% {trendText}</span>
            </div>
          )}
        </div>
        <div className={`p-4 rounded-full ${color}`}>{icon}</div>
      </div>
    </div>
  );
};

// Custom Tooltip for charts
const CustomTooltip = ({ active, payload, label, locale }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="bg-white dark:bg-gray-900 p-3 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700">
        <p className="font-semibold text-gray-800 dark:text-gray-100 mb-1">{label}</p>
        {payload.map((entry: any, index: number) => (
          <p key={index} style={{ color: entry.color }} className="text-sm">
            {entry.name}: {entry.value.toLocaleString(locale)}
          </p>
        ))}
      </div>
    );
  }
  return null;
};

export default function StatisticsPage() {
  const { language } = useUI();
  const [selectedPeriod, setSelectedPeriod] = React.useState("month");
  const tx = (ar: string, fr: string) => (language === "fr" ? fr : ar);
  const locale = language === "fr" ? "fr-FR" : "ar-DZ";

  const wilayaFr: Record<string, string> = {
    "الجزائر": "Alger",
    "وهران": "Oran",
    "قسنطينة": "Constantine",
    "عنابة": "Annaba",
    "سطيف": "Setif",
    "باتنة": "Batna",
    "بجاية": "Bejaia",
    "تلمسان": "Tlemcen",
    "البليدة": "Blida",
    "بسكرة": "Biskra",
    "تيزي وزو": "Tizi Ouzou",
    "الشلف": "Chlef",
    "المسيلة": "M'Sila",
    "الجلفة": "Djelfa",
    "سكيكدة": "Skikda",
  };

  const monthFr: Record<string, string> = {
    "يناير": "Janvier",
    "فبراير": "Fevrier",
    "مارس": "Mars",
    "أبريل": "Avril",
    "مايو": "Mai",
    "يونيو": "Juin",
    "يوليو": "Juillet",
    "أغسطس": "Aout",
    "سبتمبر": "Septembre",
    "أكتوبر": "Octobre",
    "نوفمبر": "Novembre",
    "ديسمبر": "Decembre",
  };

  const dayFr: Record<string, string> = {
    "السبت": "Samedi",
    "الأحد": "Dimanche",
    "الإثنين": "Lundi",
    "الثلاثاء": "Mardi",
    "الأربعاء": "Mercredi",
    "الخميس": "Jeudi",
    "الجمعة": "Vendredi",
  };

  const localizedRequestsPerWilaya = requestsPerWilaya.map((item) => ({
    ...item,
    label: language === "fr" ? (wilayaFr[item.arabicName] || item.arabicName) : item.arabicName,
  }));

  const localizedElectriciansPerWilaya = electriciansPerWilaya.map((item) => ({
    ...item,
    label: language === "fr" ? (wilayaFr[item.arabicName] || item.arabicName) : item.arabicName,
  }));

  const localizedMonthlyRevenue = monthlyRevenue.map((item) => ({
    ...item,
    month: language === "fr" ? (monthFr[item.month] || item.month) : item.month,
  }));

  const localizedSubscriptionStatus = subscriptionStatus.map((item) => ({
    ...item,
    name:
      item.name === "نشط"
        ? tx("نشط", "Actif")
        : item.name === "منتهي"
          ? tx("منتهي", "Expire")
          : item.name === "معلق"
            ? tx("معلق", "En attente")
            : tx("غير نشط", "Inactif"),
  }));

  const localizedRequestStatus = requestStatus.map((item) => ({
    ...item,
    name:
      item.name === "مفتوح"
        ? tx("مفتوح", "Ouvert")
        : item.name === "قيد التنفيذ"
          ? tx("قيد التنفيذ", "En cours")
          : tx("مغلق", "Ferme"),
  }));

  const localizedWeeklyTrend = weeklyTrend.map((item) => ({
    ...item,
    day: language === "fr" ? (dayFr[item.day] || item.day) : item.day,
  }));

  const localizedTopElectricians = topElectricians.map((item) => ({
    ...item,
    wilaya: language === "fr" ? (wilayaFr[item.wilaya] || item.wilaya) : item.wilaya,
  }));

  const activityMsgFr: Record<string, string> = {
    "اشتراك جديد من محمد أمين - الجزائر": "Nouvel abonnement de Mohamed Amine - Alger",
    "طلب جديد للخدمات الكهربائية - وهران": "Nouvelle demande de services electriques - Oran",
    "دفعة معلقة تنتظر المراجعة - كريم بلقاسم": "Paiement en attente de verification - Karim Belkacem",
    "عرض جديد مقدم - قسنطينة": "Nouvelle offre soumise - Constantine",
    "انتهاء اشتراك - يجب التجديد": "Abonnement expire - renouvellement requis",
  };

  const activityTimeFr: Record<string, string> = {
    "منذ 5 دقائق": "il y a 5 min",
    "منذ 12 دقيقة": "il y a 12 min",
    "منذ 23 دقيقة": "il y a 23 min",
    "منذ 34 دقيقة": "il y a 34 min",
    "منذ 45 دقيقة": "il y a 45 min",
  };

  const localizedRecentActivity = recentActivity.map((item) => ({
    ...item,
    message: language === "fr" ? (activityMsgFr[item.message] || item.message) : item.message,
    time: language === "fr" ? (activityTimeFr[item.time] || item.time) : item.time,
  }));

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="mb-8">
        <div className="flex flex-col md:flex-row md:items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{tx("لوحة الإحصائيات", "Tableau de statistiques")}</h1>
            <p className="text-gray-500 dark:text-gray-400 text-sm mt-1">{tx("نظرة عامة على أداء المنصة", "Vue d'ensemble des performances de la plateforme")}</p>
          </div>
          <div className="flex items-center gap-4 mt-4 md:mt-0">
            {/* Period Selector */}
            <div className="flex bg-gray-100 dark:bg-gray-800 rounded-lg p-1">
              {["week", "month", "year"].map((period) => (
                <button
                  key={period}
                  onClick={() => setSelectedPeriod(period)}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                    selectedPeriod === period
                      ? "bg-white dark:bg-gray-700 text-blue-600 dark:text-blue-400 shadow-sm"
                      : "text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100"
                  }`}
                >
                  {period === "week" ? tx("أسبوع", "Semaine") : period === "month" ? tx("شهر", "Mois") : tx("سنة", "Annee")}
                </button>
              ))}
            </div>
            {/* Notification Bell */}
            <button className="relative p-2 text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full">
              <Bell className="w-6 h-6" />
              <span className="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
            </button>
          </div>
        </div>
      </div>

      <div>
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-8">
          <StatCard
            title={tx("إجمالي المستخدمين", "Total utilisateurs")}
            value={dashboardStats.totalUsers}
            icon={<Users className="w-6 h-6 text-blue-600" />}
            trend={12.5}
            color="bg-blue-100"
            trendText={tx("من الشهر الماضي", "vs mois precedent")}
            locale={locale}
          />
          <StatCard
            title={tx("إجمالي الكهربائيين", "Total electriciens")}
            value={dashboardStats.totalElectricians}
            icon={<Wrench className="w-6 h-6 text-purple-600" />}
            trend={8.3}
            color="bg-purple-100"
            trendText={tx("من الشهر الماضي", "vs mois precedent")}
            locale={locale}
          />
          <StatCard
            title={tx("الاشتراكات النشطة", "Abonnements actifs")}
            value={dashboardStats.activeSubscriptions}
            icon={<CreditCard className="w-6 h-6 text-green-600" />}
            trend={15.2}
            color="bg-green-100"
            trendText={tx("من الشهر الماضي", "vs mois precedent")}
            locale={locale}
          />
          <StatCard
            title={tx("المدفوعات المعلقة", "Paiements en attente")}
            value={dashboardStats.pendingPayments}
            icon={<Clock className="w-6 h-6 text-amber-600" />}
            trend={-5.4}
            color="bg-amber-100"
            trendText={tx("من الشهر الماضي", "vs mois precedent")}
            locale={locale}
          />
          <StatCard
            title={tx("إجمالي الطلبات", "Total demandes")}
            value={dashboardStats.totalRequests}
            icon={<FileText className="w-6 h-6 text-cyan-600" />}
            trend={22.1}
            color="bg-cyan-100"
            trendText={tx("من الشهر الماضي", "vs mois precedent")}
            locale={locale}
          />
          <StatCard
            title={tx("إجمالي العروض", "Total offres")}
            value={dashboardStats.totalOffers}
            icon={<MessageSquare className="w-6 h-6 text-rose-600" />}
            trend={18.7}
            color="bg-rose-100"
            trendText={tx("من الشهر الماضي", "vs mois precedent")}
            locale={locale}
          />
        </div>

        {/* Charts Row 1 */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Requests per Wilaya */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100">{tx("الطلبات حسب الولاية", "Demandes par wilaya")}</h2>
              <MapPin className="w-5 h-5 text-gray-400 dark:text-gray-500" />
            </div>
            <ResponsiveContainer width="100%" height={350}>
              <BarChart data={localizedRequestsPerWilaya} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis type="number" tick={{ fill: "#6b7280", fontSize: 12 }} />
                <YAxis
                  dataKey="label"
                  type="category"
                  tick={{ fill: "#374151", fontSize: 12 }}
                  width={80}
                />
                <Tooltip content={<CustomTooltip locale={locale} />} />
                <Bar
                  dataKey="requests"
                  name={tx("الطلبات", "Demandes")}
                  fill="#3b82f6"
                  radius={[0, 4, 4, 0]}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Active Electricians per Wilaya */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100">{tx("الكهربائيون حسب الولاية", "Electriciens par wilaya")}</h2>
              <Wrench className="w-5 h-5 text-gray-400 dark:text-gray-500" />
            </div>
            <ResponsiveContainer width="100%" height={350}>
              <BarChart data={localizedElectriciansPerWilaya} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis type="number" tick={{ fill: "#6b7280", fontSize: 12 }} />
                <YAxis
                  dataKey="label"
                  type="category"
                  tick={{ fill: "#374151", fontSize: 12 }}
                  width={80}
                />
                <Tooltip content={<CustomTooltip locale={locale} />} />
                <Legend />
                <Bar
                  dataKey="active"
                  name={tx("نشط", "Actif")}
                  stackId="a"
                  fill="#22c55e"
                  radius={[0, 0, 0, 0]}
                />
                <Bar
                  dataKey="inactive"
                  name={tx("غير نشط", "Inactif")}
                  stackId="a"
                  fill="#ef4444"
                  radius={[0, 4, 4, 0]}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Charts Row 2 */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Subscription Revenue */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6 lg:col-span-2">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100">إيرادات الاشتراكات</h2>
                <p className="text-sm text-gray-500 dark:text-gray-400">{tx("الإيرادات الشهرية بالدينار الجزائري", "Revenus mensuels en DZD")}</p>
              </div>
              <div className="flex items-center gap-2 bg-green-100 text-green-700 px-3 py-1 rounded-full text-sm">
                <TrendingUp className="w-4 h-4" />
                <span>+23.5%</span>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={localizedMonthlyRevenue}>
                <defs>
                  <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="month" tick={{ fill: "#6b7280", fontSize: 12 }} />
                <YAxis
                  tick={{ fill: "#6b7280", fontSize: 12 }}
                  tickFormatter={(value) => `${(value / 1000000).toFixed(1)}M`}
                />
                <Tooltip
                  content={({ active, payload, label }) => {
                    if (active && payload && payload.length) {
                      return (
                        <div className="bg-white dark:bg-gray-900 p-3 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700">
                          <p className="font-semibold text-gray-800 dark:text-gray-100 mb-1">{label}</p>
                          <p className="text-blue-600 text-sm">
                            {tx("الإيرادات", "Revenus")}: {payload[0].value?.toLocaleString(locale)} {tx("د.ج", "DZD")}
                          </p>
                          <p className="text-green-600 text-sm">
                            {tx("الاشتراكات", "Abonnements")}: {payload[1]?.value?.toLocaleString(locale)}
                          </p>
                        </div>
                      );
                    }
                    return null;
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="revenue"
                  name={tx("الإيرادات", "Revenus")}
                  stroke="#3b82f6"
                  strokeWidth={2}
                  fillOpacity={1}
                  fill="url(#colorRevenue)"
                />
                <Line
                  type="monotone"
                  dataKey="subscriptions"
                  name={tx("الاشتراكات", "Abonnements")}
                  stroke="#22c55e"
                  strokeWidth={2}
                  dot={false}
                  yAxisId={0}
                />
              </AreaChart>
            </ResponsiveContainer>
            {/* Revenue Summary */}
            <div className="grid grid-cols-3 gap-4 mt-6 pt-6 border-t border-gray-100 dark:border-gray-700">
              <div className="text-center">
                <p className="text-gray-500 dark:text-gray-400 text-sm">{tx("إجمالي الإيرادات السنوية", "Revenus annuels totaux")}</p>
                <p className="text-xl font-bold text-gray-800 dark:text-gray-100">
                  {localizedMonthlyRevenue.reduce((sum, m) => sum + m.revenue, 0).toLocaleString(locale)} {tx("د.ج", "DZD")}
                </p>
              </div>
              <div className="text-center">
                <p className="text-gray-500 dark:text-gray-400 text-sm">{tx("متوسط الإيرادات الشهرية", "Revenu mensuel moyen")}</p>
                <p className="text-xl font-bold text-gray-800 dark:text-gray-100">
                  {Math.round(localizedMonthlyRevenue.reduce((sum, m) => sum + m.revenue, 0) / 12).toLocaleString(locale)} {tx("د.ج", "DZD")}
                </p>
              </div>
              <div className="text-center">
                <p className="text-gray-500 text-sm">{tx("سعر الاشتراك", "Prix abonnement")}</p>
                <p className="text-xl font-bold text-green-600">3,000 {tx("د.ج/شهر", "DZD/mois")}</p>
              </div>
            </div>
          </div>

          {/* Subscription Status Pie Chart */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
            <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100 mb-6">{tx("حالة الاشتراكات", "Statut des abonnements")}</h2>
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie
                  data={localizedSubscriptionStatus}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={2}
                  dataKey="value"
                >
                  {localizedSubscriptionStatus.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  content={({ active, payload }) => {
                    if (active && payload && payload.length) {
                      return (
                        <div className="bg-white dark:bg-gray-900 p-2 rounded shadow border border-gray-200 dark:border-gray-700">
                          <p className="font-medium text-gray-800 dark:text-gray-100">{payload[0].name}</p>
                          <p className="text-sm text-gray-600 dark:text-gray-300">{payload[0].value?.toLocaleString(locale)}</p>
                        </div>
                      );
                    }
                    return null;
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
            {/* Legend */}
            <div className="grid grid-cols-2 gap-2 mt-4">
              {localizedSubscriptionStatus.map((status, index) => (
                <div key={index} className="flex items-center gap-2">
                  <div
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: status.color }}
                  ></div>
                  <span className="text-sm text-gray-600 dark:text-gray-300">{status.name}</span>
                  <span className="text-sm font-semibold text-gray-800 dark:text-gray-100">
                    {status.value.toLocaleString(locale)}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Charts Row 3 */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Weekly Trend */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6 lg:col-span-2">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100">{tx("نشاط الأسبوع", "Activite hebdomadaire")}</h2>
              <Activity className="w-5 h-5 text-gray-400 dark:text-gray-500" />
            </div>
            <ResponsiveContainer width="100%" height={280}>
              <LineChart data={localizedWeeklyTrend}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="day" tick={{ fill: "#6b7280", fontSize: 12 }} />
                <YAxis tick={{ fill: "#6b7280", fontSize: 12 }} />
                <Tooltip content={<CustomTooltip locale={locale} />} />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="requests"
                  name={tx("الطلبات", "Demandes")}
                  stroke="#3b82f6"
                  strokeWidth={3}
                  dot={{ fill: "#3b82f6", strokeWidth: 2 }}
                />
                <Line
                  type="monotone"
                  dataKey="offers"
                  name={tx("العروض", "Offres")}
                  stroke="#22c55e"
                  strokeWidth={3}
                  dot={{ fill: "#22c55e", strokeWidth: 2 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Request Status Pie */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
            <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100 mb-6">{tx("حالة الطلبات", "Statut des demandes")}</h2>
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie
                  data={localizedRequestStatus}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={2}
                  dataKey="value"
                >
                  {localizedRequestStatus.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  content={({ active, payload }) => {
                    if (active && payload && payload.length) {
                      return (
                        <div className="bg-white dark:bg-gray-900 p-2 rounded shadow border border-gray-200 dark:border-gray-700">
                          <p className="font-medium text-gray-800 dark:text-gray-100">{payload[0].name}</p>
                          <p className="text-sm text-gray-600 dark:text-gray-300">{payload[0].value?.toLocaleString(locale)}</p>
                        </div>
                      );
                    }
                    return null;
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
            {/* Legend */}
            <div className="space-y-2 mt-4">
              {localizedRequestStatus.map((status, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div
                      className="w-3 h-3 rounded-full"
                      style={{ backgroundColor: status.color }}
                    ></div>
                    <span className="text-sm text-gray-600 dark:text-gray-300">{status.name}</span>
                  </div>
                  <span className="text-sm font-semibold text-gray-800 dark:text-gray-100">
                    {status.value.toLocaleString(locale)}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Bottom Row */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Top Electricians */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100">{tx("أفضل الكهربائيين", "Top electriciens")}</h2>
              <Star className="w-5 h-5 text-amber-400" />
            </div>
            <div className="space-y-4">
              {localizedTopElectricians.map((electrician, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-semibold text-gray-800 dark:text-gray-100">{electrician.name}</p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">{electrician.wilaya}</p>
                    </div>
                  </div>
                  <div className="text-left">
                    <p className="font-semibold text-gray-800 dark:text-gray-100">{electrician.completedJobs} {tx("عمل", "travaux")}</p>
                    <div className="flex items-center gap-1 text-amber-500">
                      <Star className="w-4 h-4 fill-current" />
                      <span className="text-sm">{electrician.rating}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Recent Activity */}
          <div className="bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold text-gray-800 dark:text-gray-100">{tx("النشاط الأخير", "Activite recente")}</h2>
              <Bell className="w-5 h-5 text-gray-400 dark:text-gray-500" />
            </div>
            <div className="space-y-4">
              {localizedRecentActivity.map((activity, index) => (
                <div
                  key={index}
                  className="flex items-start gap-3 p-3 border-r-4 bg-gray-50 dark:bg-gray-800 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                  style={{
                    borderRightColor:
                      activity.type === "subscription"
                        ? "#22c55e"
                        : activity.type === "request"
                        ? "#3b82f6"
                        : activity.type === "payment"
                        ? "#f59e0b"
                        : "#8b5cf6",
                  }}
                >
                  <div
                    className="w-10 h-10 rounded-full flex items-center justify-center"
                    style={{
                      backgroundColor:
                        activity.type === "subscription"
                          ? "#dcfce7"
                          : activity.type === "request"
                          ? "#dbeafe"
                          : activity.type === "payment"
                          ? "#fef3c7"
                          : "#ede9fe",
                    }}
                  >
                    {activity.type === "subscription" && (
                      <CreditCard className="w-5 h-5 text-green-600" />
                    )}
                    {activity.type === "request" && (
                      <FileText className="w-5 h-5 text-blue-600" />
                    )}
                    {activity.type === "payment" && (
                      <DollarSign className="w-5 h-5 text-amber-600" />
                    )}
                    {activity.type === "offer" && (
                      <MessageSquare className="w-5 h-5 text-purple-600" />
                    )}
                  </div>
                  <div className="flex-1">
                    <p className="text-gray-800 dark:text-gray-100 text-sm">{activity.message}</p>
                    <p className="text-gray-400 dark:text-gray-500 text-xs mt-1">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
