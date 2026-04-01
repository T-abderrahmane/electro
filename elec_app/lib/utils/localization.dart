import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class AppLocalizer {
  AppLocalizer._(this._language);

  final AppLanguage _language;

  static AppLocalizer of(BuildContext context) {
    final language = context.watch<AppProvider>().language;
    return AppLocalizer._(language);
  }

  static AppLocalizer fromLanguage(AppLanguage language) {
    return AppLocalizer._(language);
  }

  bool get isFrench => _language == AppLanguage.fr;

  TextDirection get direction =>
      isFrench ? TextDirection.ltr : TextDirection.rtl;

  String tr(String ar, String fr) => isFrench ? fr : ar;

  String place(String value) {
    if (!isFrench) return value;
    return _placeMap[value] ?? value;
  }

  String location(String wilaya, String commune) {
    return '${place(wilaya)} - ${place(commune)}';
  }

  String relativeTime(Duration difference) {
    if (difference.inMinutes < 60) {
      return isFrench
          ? 'il y a ${difference.inMinutes} min'
          : 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 24) {
      return isFrench
          ? 'il y a ${difference.inHours} h'
          : 'منذ ${difference.inHours} ساعة';
    }

    return isFrench
        ? 'il y a ${difference.inDays} jour(s)'
        : 'منذ ${difference.inDays} يوم';
  }

  static const Map<String, String> _placeMap = {
    'الجزائر': 'Alger',
    'وهران': 'Oran',
    'قسنطينة': 'Constantine',
    'عنابة': 'Annaba',
    'سطيف': 'Setif',
    'باتنة': 'Batna',
    'بجاية': 'Bejaia',
    'تلمسان': 'Tlemcen',
    'البليدة': 'Blida',
    'الشلف': 'Chlef',
    'تيزي وزو': 'Tizi Ouzou',
    'ورقلة': 'Ouargla',
    'سيدي بلعباس': 'Sidi Bel Abbes',
    'تيبازة': 'Tipaza',
    'باب الوادي': 'Bab El Oued',
    'الجزائر الوسطى': 'Alger Centre',
    'سيدي امحمد': 'Sidi Mhamed',
    'القبة': 'El Kouba',
    'الحراش': 'El Harrach',
    'بئر مراد رايس': 'Bir Mourad Rais',
    'بئر خادم': 'Bir Khadem',
    'الأبيار': 'El Biar',
    'براقي': 'Baraki',
    'حسين داي': 'Hussein Dey',
    'السانية': 'Es Senia',
    'بير الجير': 'Bir El Djir',
    'حاسي بونيف': 'Hassi Bounif',
    'الكرمة': 'El Kerma',
    'وادي تليلات': 'Oued Tlelat',
    'عين الترك': 'Ain El Turk',
    'مرسى الكبير': 'Mers El Kebir',
    'الخروب': 'El Khroub',
    'عين سمارة': 'Ain Smara',
    'ديدوش مراد': 'Didouche Mourad',
    'زيغود يوسف': 'Zighoud Youcef',
    'حامة بوزيان': 'Hamma Bouziane',
    'الحجار': 'El Hadjar',
    'سيدي عمار': 'Sidi Amar',
    'البوني': 'El Bouni',
    'الشرفة': 'Echatt',
  };
}
