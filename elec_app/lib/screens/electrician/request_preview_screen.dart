import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class RequestPreviewScreen extends StatefulWidget {
  final ServiceRequest request;
  final bool canAccess;

  const RequestPreviewScreen({
    super.key,
    required this.request,
    this.canAccess = true,
  });

  @override
  State<RequestPreviewScreen> createState() => _RequestPreviewScreenState();
}

class _RequestPreviewScreenState extends State<RequestPreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _timeController = TextEditingController();
  final _messageController = TextEditingController();
  bool _showOfferForm = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _timeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final hasAlreadySentOffer = provider.hasElectricianSentOffer(
      widget.request.id,
    );
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('تفاصيل الطلب', 'Details de la demande')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Images
            if (widget.request.images.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: widget.request.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(widget.request.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 150,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: AppColors.inactive),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tr('لا توجد صور', 'Pas d images'),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

            // Request Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.request.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.tr(
                          'العميل: ${widget.request.clientName}',
                          'Client: ${widget.request.clientName}',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.location(
                          widget.request.wilaya,
                          widget.request.commune,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(widget.request.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr('وصف المشكلة', 'Description du probleme'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.request.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_offer,
                          label: l10n.tr('عدد العروض', 'Nombre d offres'),
                          value: '${widget.request.offersCount}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.hourglass_empty,
                          label: l10n.tr('حالة الطلب', 'Statut de la demande'),
                          value: _getStatusText(context, widget.request.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Already Sent Offer Message
                  if (hasAlreadySentOffer)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.tr(
                                    'تم إرسال عرضك',
                                    'Votre offre a ete envoyee',
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  l10n.tr(
                                    'في انتظار رد العميل على عرضك',
                                    'En attente de la reponse du client',
                                  ),
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
                    )
                  else if (widget.canAccess && !_showOfferForm)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showOfferForm = true;
                          });
                        },
                        icon: const Icon(Icons.send),
                        label: Text(l10n.tr('إرسال عرض', 'Envoyer une offre')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                  // Offer Form
                  if (_showOfferForm && !hasAlreadySentOffer)
                    _buildOfferForm(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferForm(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tr('إرسال عرض', 'Envoyer une offre'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showOfferForm = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.tr('السعر المقترح (د.ج)', 'Prix propose (DA)'),
                prefixIcon: const Icon(Icons.monetization_on),
                hintText: l10n.tr('مثال: 5000', 'Ex: 5000'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.tr(
                    'يرجى إدخال السعر المقترح',
                    'Veuillez saisir le prix propose',
                  );
                }
                if (double.tryParse(value) == null) {
                  return l10n.tr(
                    'يرجى إدخال رقم صحيح',
                    'Veuillez saisir un nombre valide',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.tr(
                  'مدة التنفيذ المقدرة (بالساعات)',
                  'Duree estimee (heures)',
                ),
                prefixIcon: const Icon(Icons.timer),
                hintText: l10n.tr('مثال: 2', 'Ex: 2'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.tr(
                    'يرجى إدخال مدة التنفيذ',
                    'Veuillez saisir la duree',
                  );
                }
                if (int.tryParse(value) == null) {
                  return l10n.tr(
                    'يرجى إدخال رقم صحيح',
                    'Veuillez saisir un nombre valide',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.tr(
                  'رسالة للعميل (اختياري)',
                  'Message au client (optionnel)',
                ),
                prefixIcon: const Icon(Icons.message),
                hintText: l10n.tr(
                  'أضف تفاصيل إضافية عن عرضك...',
                  'Ajoutez des details supplementaires...',
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOffer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          l10n.tr(
                            'تأكيد وإرسال العرض',
                            'Confirmer et envoyer l offre',
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<AppProvider>();
    final user = provider.currentUser;
    final language = provider.language;
    final l10n = AppLocalizer.fromLanguage(language);
    
    // Pre-fetch all localized strings before async operations
    final defaultMessage = l10n.tr(
      'أنا جاهز للعمل على هذا الطلب',
      'Je suis pret a intervenir sur cette demande',
    );
    final errorMessage = l10n.tr(
      'لا يمكن إرسال العرض حاليا. تحقق من تفعيل الحساب أو الاشتراك.',
      'Impossible d envoyer l offre maintenant. Verifiez l activation du compte ou de l abonnement.',
    );
    final successMessage = l10n.tr(
      'تم إرسال عرضك بنجاح',
      'Votre offre a ete envoyee avec succes',
    );

    if (user == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final success = await provider.sendOffer(
      requestId: widget.request.id,
      price: double.parse(_priceController.text),
      message: _messageController.text.isNotEmpty ? _messageController.text : defaultMessage,
      estimatedTime: _timeController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = false;
      _showOfferForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(successMessage),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return AppLocalizer.of(
      context,
    ).relativeTime(DateTime.now().difference(date));
  }

  String _getStatusText(BuildContext context, RequestStatus status) {
    final l10n = AppLocalizer.of(context);
    switch (status) {
      case RequestStatus.open:
        return l10n.tr('مفتوح', 'Ouverte');
      case RequestStatus.assigned:
        return l10n.tr('قيد التنفيذ', 'En cours');
      case RequestStatus.closed:
        return l10n.tr('مغلق', 'Fermee');
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
