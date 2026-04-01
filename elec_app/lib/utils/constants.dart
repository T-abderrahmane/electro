import 'dart:ui';

// Algerian Wilayas data
const List<String> algerianWilayas = [
  'أدرار',
  'الشلف',
  'الأغواط',
  'أم البواقي',
  'باتنة',
  'بجاية',
  'بسكرة',
  'بشار',
  'البليدة',
  'البويرة',
  'تمنراست',
  'تبسة',
  'تلمسان',
  'تيارت',
  'تيزي وزو',
  'الجزائر',
  'الجلفة',
  'جيجل',
  'سطيف',
  'سعيدة',
  'سكيكدة',
  'سيدي بلعباس',
  'عنابة',
  'قالمة',
  'قسنطينة',
  'المدية',
  'مستغانم',
  'المسيلة',
  'معسكر',
  'ورقلة',
  'وهران',
  'البيض',
  'إليزي',
  'برج بوعريريج',
  'بومرداس',
  'الطارف',
  'تندوف',
  'تيسمسيلت',
  'الوادي',
  'خنشلة',
  'سوق أهراس',
  'تيبازة',
  'ميلة',
  'عين الدفلى',
  'النعامة',
  'عين تموشنت',
  'غرداية',
  'غليزان',
  'المنيعة',
  'أولاد جلال',
  'برج باجي مختار',
  'بني عباس',
  'تيميمون',
  'تقرت',
  'جانت',
  'المغير',
  'تولقة',
];

// Communes per wilaya (sample data)
const Map<String, List<String>> communesByWilaya = {
  'الجزائر': [
    'باب الوادي',
    'الجزائر الوسطى',
    'سيدي امحمد',
    'القبة',
    'الحراش',
    'بئر مراد رايس',
    'بئر خادم',
    'الأبيار',
    'براقي',
    'حسين داي',
  ],
  'وهران': [
    'وهران',
    'السانية',
    'بير الجير',
    'حاسي بونيف',
    'الكرمة',
    'وادي تليلات',
    'عين الترك',
    'مرسى الكبير',
  ],
  'قسنطينة': [
    'قسنطينة',
    'الخروب',
    'عين سمارة',
    'ديدوش مراد',
    'زيغود يوسف',
    'حامة بوزيان',
  ],
  'عنابة': [
    'عنابة',
    'الحجار',
    'سيدي عمار',
    'البوني',
    'الشرفة',
  ],
  'سطيف': [
    'سطيف',
    'العلمة',
    'عين ولمان',
    'عين أزال',
    'بوعنداس',
  ],
  'باتنة': [
    'باتنة',
    'بريكة',
    'عين التوتة',
    'نقاوس',
    'مروانة',
  ],
  'بجاية': [
    'بجاية',
    'أقبو',
    'سيدي عيش',
    'القل',
    'تيشي',
  ],
  'تلمسان': [
    'تلمسان',
    'مغنية',
    'الرمشي',
    'بن سكران',
    'سبدو',
  ],
  'البليدة': [
    'البليدة',
    'بوفاريك',
    'الأربعاء',
    'موزاية',
    'بوعينان',
  ],
};

// App colors
class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1D4ED8);
  static const secondary = Color(0xFF10B981);
  static const accent = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const inactive = Color(0xFF9CA3AF);
}
