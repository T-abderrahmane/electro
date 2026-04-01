import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('عن التطبيق', 'A propos de l application')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.electrical_services,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              l10n.tr('منصة الكهربائيين', 'Plateforme des electriciens'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tr('الإصدار 1.0.0', 'Version 1.0.0'),
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('عن التطبيق', 'A propos'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tr(
                      'منصة الكهربائيين هي تطبيق جزائري يربط بين العملاء والكهربائيين المحترفين في جميع أنحاء الجزائر.\n\nيمكن للعملاء نشر طلبات الخدمات الكهربائية واستقبال عروض من كهربائيين معتمدين، واختيار العرض الأنسب لهم.\n\nنسعى لتوفير منصة آمنة وموثوقة تسهل التواصل بين أصحاب المهارات والباحثين عن خدماتهم.',
                      'La plateforme des electriciens est une application algerienne qui relie les clients et les electriciens professionnels dans toute l Algerie.\n\nLes clients peuvent publier des demandes de services electriques, recevoir des offres d electriciens verifies et choisir la meilleure offre.\n\nNotre objectif est de fournir une plateforme sure et fiable qui facilite la mise en relation.',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Features
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('المميزات', 'Fonctionnalites'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeatureItem(
                    icon: Icons.search,
                    title: l10n.tr('سهولة البحث', 'Recherche facile'),
                    description: l10n.tr(
                      'ابحث عن كهربائيين في منطقتك',
                      'Trouvez des electriciens dans votre zone',
                    ),
                  ),
                  _FeatureItem(
                    icon: Icons.verified_user,
                    title: l10n.tr(
                      'كهربائيون معتمدون',
                      'Electriciens verifies',
                    ),
                    description: l10n.tr(
                      'جميع الكهربائيين موثقون ومعتمدون',
                      'Tous les electriciens sont verifies',
                    ),
                  ),
                  _FeatureItem(
                    icon: Icons.chat,
                    title: l10n.tr('تواصل مباشر', 'Contact direct'),
                    description: l10n.tr(
                      'تحدث مع الكهربائي مباشرة',
                      'Discutez directement avec l electricien',
                    ),
                  ),
                  _FeatureItem(
                    icon: Icons.star,
                    title: l10n.tr('تقييمات موثوقة', 'Avis fiables'),
                    description: l10n.tr(
                      'اطلع على تقييمات العملاء السابقين',
                      'Consultez les avis des anciens clients',
                    ),
                  ),
                  _FeatureItem(
                    icon: Icons.security,
                    title: l10n.tr(
                      'آمان وخصوصية',
                      'Securite et confidentialite',
                    ),
                    description: l10n.tr(
                      'بياناتك محمية ومشفرة',
                      'Vos donnees sont protegees et chiffrees',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: '+500',
                    label: l10n.tr('كهربائي', 'Electricien'),
                  ),
                  _StatItem(value: '+1000', label: l10n.tr('عميل', 'Client')),
                  _StatItem(value: '48', label: l10n.tr('ولاية', 'Wilaya')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Developer Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    l10n.tr(
                      'تم التطوير بـ ❤️ في الجزائر',
                      'Developpe avec ❤️ en Algerie',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      '© 2026 جميع الحقوق محفوظة',
                      '© 2026 Tous droits reserves',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
