import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';
import 'edit_profile_screen.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final isElectrician = user?.role == UserRole.electrician;
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('معلومات الحساب', 'Informations du compte')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child:
                          user?.profileImage != null
                              ? Image.asset(
                                user!.profileImage!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                              )
                              : Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? l10n.tr('مستخدم', 'Utilisateur'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isElectrician
                          ? l10n.tr('كهربائي', 'Electricien')
                          : l10n.tr('عميل', 'Client'),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Details
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
                    l10n.tr('المعلومات الشخصية', 'Informations personnelles'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    icon: Icons.person,
                    label: l10n.tr('الاسم', 'Nom'),
                    value: user?.name ?? '-',
                  ),
                  _InfoRow(
                    icon: Icons.phone,
                    label: l10n.tr('رقم الهاتف', 'Numero de telephone'),
                    value: user?.phone ?? '-',
                  ),
                  if (isElectrician) ...[
                    _InfoRow(
                      icon: Icons.location_on,
                      label: l10n.tr('الولاية', 'Wilaya'),
                      value:
                          user?.wilaya != null
                              ? l10n.place(user!.wilaya!)
                              : '-',
                    ),
                    _InfoRow(
                      icon: Icons.location_city,
                      label: l10n.tr('البلدية', 'Commune'),
                      value:
                          user?.commune != null
                              ? l10n.place(user!.commune!)
                              : '-',
                    ),
                    _InfoRow(
                      icon: Icons.work,
                      label: l10n.tr('سنوات الخبرة', 'Annees d experience'),
                      value: l10n.tr(
                        '${user?.yearsExperience ?? 0} سنة',
                        '${user?.yearsExperience ?? 0} ans',
                      ),
                    ),
                  ],
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: l10n.tr('تاريخ التسجيل', 'Date d inscription'),
                    value: _formatDate(context, user?.createdAt),
                  ),
                ],
              ),
            ),

            // Subscription Info (for electricians)
            if (isElectrician) ...[
              const SizedBox(height: 16),
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
                      l10n.tr('معلومات الاشتراك', 'Informations d abonnement'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      icon: Icons.subscriptions,
                      label: l10n.tr('حالة الاشتراك', 'Statut de l abonnement'),
                      value: _getSubscriptionStatusText(
                        context,
                        user?.subscriptionStatus,
                      ),
                      valueColor: _getSubscriptionStatusColor(
                        user?.subscriptionStatus,
                      ),
                    ),
                    if (user?.subscriptionStartDate != null)
                      _InfoRow(
                        icon: Icons.play_arrow,
                        label: l10n.tr('تاريخ البدء', 'Date de debut'),
                        value: _formatDate(
                          context,
                          user?.subscriptionStartDate,
                        ),
                      ),
                    if (user?.subscriptionEndDate != null)
                      _InfoRow(
                        icon: Icons.stop,
                        label: l10n.tr('تاريخ الانتهاء', 'Date de fin'),
                        value: _formatDate(context, user?.subscriptionEndDate),
                      ),
                  ],
                ),
              ),
            ],

            // Account Status
            const SizedBox(height: 16),
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
                    l10n.tr('حالة الحساب', 'Statut du compte'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    icon: Icons.verified_user,
                    label: l10n.tr('الحالة', 'Etat'),
                    value:
                        user?.isAccountActive == true
                            ? l10n.tr('نشط', 'Actif')
                            : l10n.tr('موقوف', 'Suspendu'),
                    valueColor:
                        user?.isAccountActive == true
                            ? AppColors.success
                            : AppColors.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return '-';
    final l10n = AppLocalizer.of(context);
    if (l10n.isFrench) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getSubscriptionStatusText(
    BuildContext context,
    SubscriptionStatus? status,
  ) {
    final l10n = AppLocalizer.of(context);
    switch (status) {
      case SubscriptionStatus.active:
        return l10n.tr('مفعل', 'Actif');
      case SubscriptionStatus.inactive:
        return l10n.tr('غير مفعل', 'Inactif');
      case SubscriptionStatus.expired:
        return l10n.tr('منتهي', 'Expire');
      case SubscriptionStatus.pending:
        return l10n.tr('قيد المراجعة', 'En verification');
      default:
        return l10n.tr('غير مفعل', 'Inactif');
    }
  }

  Color _getSubscriptionStatusColor(SubscriptionStatus? status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.pending:
        return AppColors.accent;
      case SubscriptionStatus.expired:
        return AppColors.error;
      default:
        return AppColors.inactive;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
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
