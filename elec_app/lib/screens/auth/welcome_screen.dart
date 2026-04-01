import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AppProvider>().toggleLanguage(),
                  icon: const Icon(Icons.language),
                  label: Text(l10n.tr('Français', 'العربية')),
                ),
              ),
              const SizedBox(height: 24),
              // Logo and Title
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.electrical_services,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.tr('منصة الكهربائيين', 'Plateforme des electriciens'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.tr(
                  'اتصل بأفضل الكهربائيين في الجزائر',
                  'Contactez les meilleurs electriciens en Algerie',
                ),
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Features
              _buildFeatureItem(
                l10n,
                Icons.search,
                l10n.tr('ابحث عن كهربائي', 'Trouvez un electricien'),
                l10n.tr(
                  'اعثر على كهربائيين محترفين في منطقتك',
                  'Trouvez des professionnels pres de chez vous',
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                l10n,
                Icons.local_offer,
                l10n.tr('احصل على عروض', 'Recevez des offres'),
                l10n.tr(
                  'قارن الأسعار واختر العرض المناسب',
                  'Comparez les prix et choisissez la meilleure offre',
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                l10n,
                Icons.chat,
                l10n.tr('تواصل مباشرة', 'Communiquez directement'),
                l10n.tr(
                  'دردش مع الكهربائي لتنسيق العمل',
                  'Discutez avec l electricien pour organiser le travail',
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/client-login');
                },
                child: Text(l10n.tr('أنا عميل', 'Je suis client')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/electrician-login');
                },
                child: Text(l10n.tr('أنا كهربائي', 'Je suis electricien')),
              ),
              const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    AppLocalizer l10n,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textDirection: l10n.direction,
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textDirection: l10n.direction,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
