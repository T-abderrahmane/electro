import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('المساعدة والدعم', 'Aide et support')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Card
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
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tr('هل تحتاج مساعدة؟', 'Besoin d aide ?'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      'فريق الدعم متاح على مدار الساعة',
                      'L equipe support est disponible 24h/24',
                    ),
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ContactButton(
                        icon: Icons.phone,
                        label: l10n.tr('اتصل بنا', 'Appelez-nous'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('0555 123 456')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _ContactButton(
                        icon: Icons.email,
                        label: l10n.tr('راسلنا', 'Ecrivez-nous'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('support@elec-dz.com'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Text(
              l10n.tr('الأسئلة الشائعة', 'FAQ'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _FAQItem(
              question: l10n.tr(
                'كيف أنشئ طلب جديد؟',
                'Comment creer une nouvelle demande ?',
              ),
              answer: l10n.tr(
                'من الصفحة الرئيسية، اضغط على زر "طلب جديد" (+) ثم أدخل تفاصيل الطلب والموقع والصور إن وجدت.',
                'Depuis l accueil, appuyez sur "Nouvelle demande" (+), puis ajoutez les details, la localisation et des photos si besoin.',
              ),
            ),
            _FAQItem(
              question: l10n.tr(
                'كيف أشترك كفني كهربائي؟',
                'Comment souscrire comme electricien ?',
              ),
              answer: l10n.tr(
                'قم بإنشاء حساب كفني كهربائي، ثم اذهب لصفحة الاشتراك وقم بتحويل 3000 د.ج عبر BaridiMob وارفع صورة إثبات الدفع.',
                'Creez un compte electricien, allez a la page abonnement, transferez 3000 DA via BaridiMob puis envoyez la preuve.',
              ),
            ),
            _FAQItem(
              question: l10n.tr(
                'متى يتم تفعيل اشتراكي؟',
                'Quand mon abonnement est-il active ?',
              ),
              answer: l10n.tr(
                'يتم مراجعة إثبات الدفع خلال 24 ساعة كحد أقصى، وسيتم تفعيل اشتراكك فور الموافقة.',
                'La preuve de paiement est verifiee sous 24h maximum, puis votre abonnement est active.',
              ),
            ),
            _FAQItem(
              question: l10n.tr(
                'كيف أتواصل مع الكهربائي؟',
                'Comment contacter un electricien ?',
              ),
              answer: l10n.tr(
                'بعد قبول عرض من كهربائي، يمكنك التواصل معه مباشرة عبر المحادثة داخل التطبيق.',
                'Apres avoir accepte une offre, vous pouvez discuter directement via le chat de l application.',
              ),
            ),
            _FAQItem(
              question: l10n.tr(
                'هل يمكنني إلغاء طلب؟',
                'Puis-je annuler une demande ?',
              ),
              answer: l10n.tr(
                'نعم، يمكنك إغلاق الطلب في أي وقت من صفحة تفاصيل الطلب.',
                'Oui, vous pouvez fermer une demande a tout moment depuis la page de details.',
              ),
            ),
            _FAQItem(
              question: l10n.tr(
                'ما هي طرق الدفع المتاحة؟',
                'Quels moyens de paiement sont disponibles ?',
              ),
              answer: l10n.tr(
                'حالياً يتم الدفع عبر BaridiMob فقط. يتم التحويل لحساب المنصة ثم رفع صورة إثبات الدفع.',
                'Actuellement, le paiement se fait uniquement via BaridiMob. Transferez vers le compte de la plateforme puis envoyez la preuve.',
              ),
            ),
            _FAQItem(
              question: l10n.tr(
                'كيف أبلغ عن مشكلة؟',
                'Comment signaler un probleme ?',
              ),
              answer: l10n.tr(
                'يمكنك التواصل معنا عبر البريد الإلكتروني أو الاتصال بالرقم المذكور أعلاه.',
                'Contactez-nous par email ou appelez le numero ci-dessus.',
              ),
            ),

            const SizedBox(height: 24),

            // Quick Links
            Text(
              l10n.tr('روابط سريعة', 'Liens rapides'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _QuickLinkItem(
              icon: Icons.description,
              title: l10n.tr('شروط الاستخدام', 'Conditions d utilisation'),
              onTap: () {},
            ),
            _QuickLinkItem(
              icon: Icons.privacy_tip,
              title: l10n.tr('سياسة الخصوصية', 'Politique de confidentialite'),
              onTap: () {},
            ),
            _QuickLinkItem(
              icon: Icons.feedback,
              title: l10n.tr('إرسال اقتراح', 'Envoyer une suggestion'),
              onTap: () {},
            ),
            _QuickLinkItem(
              icon: Icons.bug_report,
              title: l10n.tr('الإبلاغ عن خطأ', 'Signaler un bug'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickLinkItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_left, color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
    );
  }
}
