// Mock data for the statistics page

export const algerianWilayas = [
  "أدرار", "الشلف", "الأغواط", "أم البواقي", "باتنة", "بجاية", "بسكرة", "بشار",
  "البليدة", "البويرة", "تمنراست", "تبسة", "تلمسان", "تيارت", "تيزي وزو", "الجزائر",
  "الجلفة", "جيجل", "سطيف", "سعيدة", "سكيكدة", "سيدي بلعباس", "عنابة", "قالمة",
  "قسنطينة", "المدية", "مستغانم", "المسيلة", "معسكر", "ورقلة", "وهران", "البيض",
  "إليزي", "برج بوعريريج", "بومرداس", "الطارف", "تندوف", "تيسمسيلت", "الوادي",
  "خنشلة", "سوق أهراس", "تيبازة", "ميلة", "عين الدفلى", "النعامة", "عين تموشنت",
  "غرداية", "غليزان", "المنيعة", "أولاد جلال", "برج باجي مختار", "بني عباس",
  "تيميمون", "تقرت", "جانت", "المغير", "تولقة"
];

// Dashboard overview stats
export const dashboardStats = {
  totalUsers: 12458,
  totalElectricians: 3245,
  activeSubscriptions: 1856,
  pendingPayments: 127,
  totalRequests: 8934,
  totalOffers: 24567
};

// Requests per wilaya data
export const requestsPerWilaya = [
  { wilaya: "الجزائر", requests: 1245, arabicName: "الجزائر" },
  { wilaya: "وهران", requests: 892, arabicName: "وهران" },
  { wilaya: "قسنطينة", requests: 756, arabicName: "قسنطينة" },
  { wilaya: "عنابة", requests: 634, arabicName: "عنابة" },
  { wilaya: "سطيف", requests: 589, arabicName: "سطيف" },
  { wilaya: "باتنة", requests: 478, arabicName: "باتنة" },
  { wilaya: "بجاية", requests: 445, arabicName: "بجاية" },
  { wilaya: "تلمسان", requests: 398, arabicName: "تلمسان" },
  { wilaya: "البليدة", requests: 367, arabicName: "البليدة" },
  { wilaya: "بسكرة", requests: 312, arabicName: "بسكرة" },
  { wilaya: "تيزي وزو", requests: 298, arabicName: "تيزي وزو" },
  { wilaya: "الشلف", requests: 267, arabicName: "الشلف" },
  { wilaya: "المسيلة", requests: 234, arabicName: "المسيلة" },
  { wilaya: "الجلفة", requests: 212, arabicName: "الجلفة" },
  { wilaya: "سكيكدة", requests: 198, arabicName: "سكيكدة" },
];

// Active electricians per wilaya
export const electriciansPerWilaya = [
  { wilaya: "الجزائر", active: 456, inactive: 123, arabicName: "الجزائر" },
  { wilaya: "وهران", active: 312, inactive: 89, arabicName: "وهران" },
  { wilaya: "قسنطينة", active: 267, inactive: 78, arabicName: "قسنطينة" },
  { wilaya: "عنابة", active: 198, inactive: 56, arabicName: "عنابة" },
  { wilaya: "سطيف", active: 178, inactive: 45, arabicName: "سطيف" },
  { wilaya: "باتنة", active: 156, inactive: 34, arabicName: "باتنة" },
  { wilaya: "بجاية", active: 134, inactive: 28, arabicName: "بجاية" },
  { wilaya: "تلمسان", active: 112, inactive: 23, arabicName: "تلمسان" },
  { wilaya: "البليدة", active: 98, inactive: 19, arabicName: "البليدة" },
  { wilaya: "بسكرة", active: 87, inactive: 15, arabicName: "بسكرة" },
  { wilaya: "تيزي وزو", active: 76, inactive: 12, arabicName: "تيزي وزو" },
  { wilaya: "الشلف", active: 65, inactive: 11, arabicName: "الشلف" },
];

// Monthly subscription revenue
export const monthlyRevenue = [
  { month: "يناير", revenue: 4500000, subscriptions: 1500 },
  { month: "فبراير", revenue: 4800000, subscriptions: 1600 },
  { month: "مارس", revenue: 5100000, subscriptions: 1700 },
  { month: "أبريل", revenue: 5400000, subscriptions: 1800 },
  { month: "مايو", revenue: 5250000, subscriptions: 1750 },
  { month: "يونيو", revenue: 5550000, subscriptions: 1850 },
  { month: "يوليو", revenue: 5700000, subscriptions: 1900 },
  { month: "أغسطس", revenue: 5400000, subscriptions: 1800 },
  { month: "سبتمبر", revenue: 5850000, subscriptions: 1950 },
  { month: "أكتوبر", revenue: 6000000, subscriptions: 2000 },
  { month: "نوفمبر", revenue: 5700000, subscriptions: 1900 },
  { month: "ديسمبر", revenue: 5568000, subscriptions: 1856 },
];

// Subscription status distribution
export const subscriptionStatus = [
  { name: "نشط", value: 1856, color: "#22c55e" },
  { name: "منتهي", value: 892, color: "#ef4444" },
  { name: "معلق", value: 127, color: "#f59e0b" },
  { name: "غير نشط", value: 370, color: "#6b7280" },
];

// Request status distribution
export const requestStatus = [
  { name: "مفتوح", value: 3456, color: "#3b82f6" },
  { name: "قيد التنفيذ", value: 2134, color: "#f59e0b" },
  { name: "مغلق", value: 3344, color: "#22c55e" },
];

// Weekly requests trend
export const weeklyTrend = [
  { day: "السبت", requests: 145, offers: 423 },
  { day: "الأحد", requests: 178, offers: 512 },
  { day: "الإثنين", requests: 234, offers: 678 },
  { day: "الثلاثاء", requests: 256, offers: 734 },
  { day: "الأربعاء", requests: 289, offers: 812 },
  { day: "الخميس", requests: 198, offers: 567 },
  { day: "الجمعة", requests: 123, offers: 345 },
];

// Top performing electricians
export const topElectricians = [
  { name: "محمد أمين", wilaya: "الجزائر", completedJobs: 156, rating: 4.9 },
  { name: "كريم بلقاسم", wilaya: "وهران", completedJobs: 134, rating: 4.8 },
  { name: "يوسف حداد", wilaya: "قسنطينة", completedJobs: 128, rating: 4.9 },
  { name: "أحمد بن علي", wilaya: "عنابة", completedJobs: 112, rating: 4.7 },
  { name: "سمير مراد", wilaya: "سطيف", completedJobs: 98, rating: 4.8 },
];

// Recent activity
export const recentActivity = [
  { type: "subscription", message: "اشتراك جديد من محمد أمين - الجزائر", time: "منذ 5 دقائق" },
  { type: "request", message: "طلب جديد للخدمات الكهربائية - وهران", time: "منذ 12 دقيقة" },
  { type: "payment", message: "دفعة معلقة تنتظر المراجعة - كريم بلقاسم", time: "منذ 23 دقيقة" },
  { type: "offer", message: "عرض جديد مقدم - قسنطينة", time: "منذ 34 دقيقة" },
  { type: "subscription", message: "انتهاء اشتراك - يجب التجديد", time: "منذ 45 دقيقة" },
];
