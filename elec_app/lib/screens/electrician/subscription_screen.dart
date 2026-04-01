import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  File? _paymentProofImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentProofImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _paymentProofImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizer.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.tr('اختر مصدر الصورة', 'Choisir la source de l image'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ImageSourceButton(
                        icon: Icons.photo_library,
                        label: l10n.tr('المعرض', 'Galerie'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                      _ImageSourceButton(
                        icon: Icons.camera_alt,
                        label: l10n.tr('الكاميرا', 'Camera'),
                        onTap: () {
                          Navigator.pop(context);
                          _takePhoto();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _submitPayment() async {
    final l10n = AppLocalizer.of(context);
    if (_paymentProofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tr(
              'الرجاء إضافة صورة إثبات الدفع',
              'Veuillez ajouter la preuve de paiement',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    context.read<AppProvider>().submitSubscriptionPayment(
      _paymentProofImage!.path,
    );

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.tr(
            'تم إرسال إثبات الدفع بنجاح',
            'Preuve de paiement envoyee avec succes',
          ),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final subscriptionStatus =
        user?.subscriptionStatus ?? SubscriptionStatus.inactive;
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('الاشتراك', 'Abonnement'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Status Card
            _SubscriptionStatusCard(
              status: subscriptionStatus,
              expiryDate: user?.subscriptionEndDate,
            ),
            const SizedBox(height: 24),
            // Pricing Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tr('الاشتراك الشهري', 'Abonnement mensuel'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3000 د.ج',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.tr('شهرياً', 'par mois'),
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  // Features
                  _FeatureItem(
                    text: l10n.tr(
                      'الوصول لجميع الطلبات',
                      'Acces a toutes les demandes',
                    ),
                  ),
                  _FeatureItem(
                    text: l10n.tr(
                      'إرسال عروض غير محدودة',
                      'Envoi d offres illimite',
                    ),
                  ),
                  _FeatureItem(
                    text: l10n.tr(
                      'التواصل المباشر مع العملاء',
                      'Communication directe avec les clients',
                    ),
                  ),
                  _FeatureItem(
                    text: l10n.tr(
                      'الدعم الفني على مدار الساعة',
                      'Support technique 24h/24',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Payment Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Row(
                    children: [
                      Icon(Icons.info, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.tr('طريقة الدفع', 'Mode de paiement'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PaymentStep(
                    number: '1',
                    text: l10n.tr(
                      'قم بتحويل المبلغ عبر BaridiMob',
                      'Transferez le montant via BaridiMob',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PaymentStep(
                    number: '2',
                    text: 'رقم الحساب: 00799999001234567890',
                  ),
                  const SizedBox(height: 8),
                  _PaymentStep(
                    number: '3',
                    text: l10n.tr(
                      'خذ لقطة شاشة لإثبات الدفع',
                      'Prenez une capture de la preuve de paiement',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PaymentStep(
                    number: '4',
                    text: l10n.tr(
                      'ارفع الصورة أدناه',
                      'Televersez l image ci-dessous',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upload Payment Proof
            Text(
              l10n.tr('إثبات الدفع', 'Preuve de paiement'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child:
                    _paymentProofImage != null
                        ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _paymentProofImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _paymentProofImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 60,
                              color: AppColors.inactive,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.tr(
                                'اضغط لرفع صورة إثبات الدفع',
                                'Appuyez pour televerser la preuve',
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.tr('PNG, JPG أو JPEG', 'PNG, JPG ou JPEG'),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inactive,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPayment,
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          l10n.tr('تأكيد الدفع', 'Confirmer le paiement'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),
            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.tr(
                        'سيتم تفعيل اشتراكك خلال 24 ساعة بعد التحقق من الدفع',
                        'Votre abonnement sera active sous 24h apres verification',
                      ),
                      style: TextStyle(fontSize: 12, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  final SubscriptionStatus status;
  final DateTime? expiryDate;

  const _SubscriptionStatusCard({required this.status, this.expiryDate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    Color color;
    String title;
    String subtitle;
    IconData icon;

    switch (status) {
      case SubscriptionStatus.active:
        color = AppColors.success;
        title = l10n.tr('اشتراكك مفعل', 'Votre abonnement est actif');
        subtitle =
            expiryDate != null
                ? l10n.tr(
                  'ينتهي في ${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}',
                  'Expire le ${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}',
                )
                : l10n.tr(
                  'اشتراكك نشط حالياً',
                  'Votre abonnement est actuellement actif',
                );
        icon = Icons.check_circle;
        break;
      case SubscriptionStatus.pending:
        color = AppColors.accent;
        title = l10n.tr('في انتظار التفعيل', 'Activation en attente');
        subtitle = l10n.tr(
          'سيتم مراجعة دفعتك قريباً',
          'Votre paiement sera verifie bientot',
        );
        icon = Icons.hourglass_empty;
        break;
      case SubscriptionStatus.expired:
        color = AppColors.error;
        title = l10n.tr('اشتراكك منتهي', 'Votre abonnement a expire');
        subtitle = l10n.tr(
          'قم بتجديد اشتراكك للاستمرار',
          'Renouvelez votre abonnement pour continuer',
        );
        icon = Icons.error;
        break;
      case SubscriptionStatus.inactive:
        color = AppColors.inactive;
        title = l10n.tr('غير مشترك', 'Non abonne');
        subtitle = l10n.tr(
          'اشترك الآن للوصول لكل الميزات',
          'Abonnez-vous maintenant pour acceder a toutes les fonctionnalites',
        );
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
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

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  final String number;
  final String text;

  const _PaymentStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
