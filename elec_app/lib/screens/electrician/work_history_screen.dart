import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class WorkHistoryScreen extends StatelessWidget {
  const WorkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;
    final l10n = AppLocalizer.of(context);

    // Get completed requests for this electrician
    final completedRequests =
        appProvider.requests
            .where(
              (r) =>
                  r.status == RequestStatus.closed &&
                  r.assignedElectricianId == user?.id,
            )
            .toList();

    return Directionality(
      textDirection: l10n.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.tr('سجل الأعمال', 'Historique des travaux')),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body:
            completedRequests.isEmpty
                ? _EmptyState(l10n: l10n)
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedRequests.length,
                  itemBuilder: (context, index) {
                    return _WorkHistoryCard(
                      request: completedRequests[index],
                      l10n: l10n,
                    );
                  },
                ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizer l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 60,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.tr('لا يوجد أعمال سابقة', 'Aucun travail precedent'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tr(
              'ستظهر هنا الأعمال المكتملة',
              'Les travaux termines apparaitront ici',
            ),
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WorkHistoryCard extends StatelessWidget {
  final ServiceRequest request;
  final AppLocalizer l10n;

  const _WorkHistoryCard({required this.request, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tr('عمل مكتمل', 'Travail termine'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        _formatDate(request.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'مكتمل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Type
                Row(
                  children: [
                    Icon(
                      _getServiceIcon(request.title),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getServiceName(request.title),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  request.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.location(request.wilaya, request.commune),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.calendar_today,
                        label: l10n.tr('تاريخ الطلب', 'Date de la demande'),
                        value: _formatShortDate(request.createdAt),
                      ),
                      Container(width: 1, height: 30, color: AppColors.border),
                      _StatItem(
                        icon: Icons.person_outline,
                        label: l10n.tr('رقم الطلب', 'Numero de demande'),
                        value: '#${request.id.substring(0, 6)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (l10n.isFrench) {
      return '${date.day}/${date.month}/${date.year}';
    }
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getServiceIcon(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('تركيب') || lower.contains('install')) {
      return Icons.build;
    }
    if (lower.contains('إصلاح') || lower.contains('repair')) {
      return Icons.handyman;
    }
    if (lower.contains('صيانة') || lower.contains('maint')) {
      return Icons.settings;
    }
    if (lower.contains('استشارة') || lower.contains('consult')) {
      return Icons.chat;
    }

    return Icons.electrical_services;
  }

  String _getServiceName(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('تركيب') || lower.contains('install')) {
      return l10n.tr('تركيب', 'Installation');
    }
    if (lower.contains('إصلاح') || lower.contains('repair')) {
      return l10n.tr('إصلاح', 'Reparation');
    }
    if (lower.contains('صيانة') || lower.contains('maint')) {
      return l10n.tr('صيانة', 'Maintenance');
    }
    if (lower.contains('استشارة') || lower.contains('consult')) {
      return l10n.tr('استشارة', 'Consultation');
    }

    return l10n.tr('خدمة كهربائية', 'Service electrique');
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
