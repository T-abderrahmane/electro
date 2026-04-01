import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';
import '../common/account_info_screen.dart';
import '../common/help_support_screen.dart';
import '../common/notifications_screen.dart';
import 'request_preview_screen.dart';
import 'subscription_screen.dart';
import '../chat/chat_screen.dart';
import 'my_ratings_screen.dart';
import 'work_history_screen.dart';

class ElectricianHomeScreen extends StatefulWidget {
  const ElectricianHomeScreen({super.key});

  @override
  State<ElectricianHomeScreen> createState() => _ElectricianHomeScreenState();
}

class _ElectricianHomeScreenState extends State<ElectricianHomeScreen> {
  int _currentIndex = 0;

  Widget _currentTab() {
    switch (_currentIndex) {
      case 1:
        return const _MyJobsTab();
      case 2:
        return const _ProfileTab();
      case 0:
      default:
        return const _RequestsTab();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      body: _currentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.tr('الطلبات', 'Demandes'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work),
            label: l10n.tr('أعمالي', 'Mes travaux'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.tr('حسابي', 'Mon compte'),
          ),
        ],
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final canUseElectricianFeatures = provider.canUseElectricianFeatures;
    final requests = provider.filteredRequests;
    final selectedWilaya = provider.selectedWilaya;
    final selectedCommune = provider.selectedCommune;
    final l10n = AppLocalizer.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.tr('مرحباً،', 'Bonjour,')} ${user?.name ?? l10n.tr('كهربائي', 'Electricien')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _SubscriptionBadge(
                            status:
                                user?.subscriptionStatus ??
                                SubscriptionStatus.inactive,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed: () {
                        context.read<AppProvider>().toggleLanguage();
                      },
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountInfoScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label:
                            selectedWilaya != null
                                ? l10n.place(selectedWilaya)
                                : l10n.tr('الولاية', 'Wilaya'),
                        isSelected: selectedWilaya != null,
                        onTap: () => _showWilayaFilter(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label:
                            selectedCommune != null
                                ? l10n.place(selectedCommune)
                                : l10n.tr('البلدية', 'Commune'),
                        isSelected: selectedCommune != null,
                        onTap:
                            selectedWilaya != null
                                ? () =>
                                    _showCommuneFilter(context, selectedWilaya)
                                : null,
                      ),
                    ),
                    if (selectedWilaya != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          context.read<AppProvider>().clearFilters();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Subscription Warning
          if (!canUseElectricianFeatures)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr('الاشتراك غير مفعل', 'Abonnement inactif'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.tr(
                            'فعّل اشتراكك للوصول إلى تفاصيل الطلبات وإرسال العروض',
                            'Activez votre abonnement pour consulter les details et envoyer des offres',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                    },
                    child: Text(l10n.tr('تفعيل', 'Activer')),
                  ),
                ],
              ),
            ),
          // Requests List
          Expanded(
            child:
                requests.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 80,
                            color: AppColors.inactive,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.tr(
                              'لا توجد طلبات متاحة',
                              'Aucune demande disponible',
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (selectedWilaya != null)
                            TextButton(
                              onPressed: () {
                                context.read<AppProvider>().clearFilters();
                              },
                              child: Text(
                                l10n.tr('إزالة الفلتر', 'Supprimer le filtre'),
                              ),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _RequestCard(
                          request: request,
                          hasActiveSubscription: canUseElectricianFeatures,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showWilayaFilter(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder:
                (context, scrollController) => Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.tr('اختر الولاية', 'Choisir la wilaya'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: algerianWilayas.length,
                        itemBuilder: (context, index) {
                          final wilaya = algerianWilayas[index];
                          return ListTile(
                            title: Text(l10n.place(wilaya)),
                            onTap: () {
                              context.read<AppProvider>().setWilayaFilter(
                                wilaya,
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showCommuneFilter(BuildContext context, String wilaya) {
    final l10n = AppLocalizer.of(context);
    final communes = communesByWilaya[wilaya] ?? [];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.tr('اختر البلدية', 'Choisir la commune'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: communes.length,
                  itemBuilder: (context, index) {
                    final commune = communes[index];
                    return ListTile(
                      title: Text(l10n.place(commune)),
                      onTap: () {
                        context.read<AppProvider>().setCommuneFilter(commune);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  final SubscriptionStatus status;

  const _SubscriptionBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case SubscriptionStatus.active:
        color = AppColors.success;
        text = l10n.tr('اشتراك مفعل', 'Abonnement actif');
        icon = Icons.check_circle;
        break;
      case SubscriptionStatus.pending:
        color = AppColors.accent;
        text = l10n.tr('في انتظار التفعيل', 'En attente d activation');
        icon = Icons.hourglass_empty;
        break;
      case SubscriptionStatus.expired:
        color = AppColors.error;
        text = l10n.tr('اشتراك منتهي', 'Abonnement expire');
        icon = Icons.error;
        break;
      case SubscriptionStatus.inactive:
        color = AppColors.inactive;
        text = l10n.tr('غير مشترك', 'Non abonne');
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final bool hasActiveSubscription;

  const _RequestCard({
    required this.request,
    required this.hasActiveSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => RequestPreviewScreen(
                    request: request,
                    canAccess: hasActiveSubscription,
                  ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  Expanded(
                    child: Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (!hasActiveSubscription)
                    Icon(Icons.lock, size: 20, color: AppColors.inactive),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.location(request.wilaya, request.commune),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request.offersCount} ${l10n.tr('عروض', 'offres')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(request.createdAt, l10n),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizer l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return l10n.relativeTime(difference);
  }
}

class _MyJobsTab extends StatelessWidget {
  const _MyJobsTab();

  @override
  Widget build(BuildContext context) {
    final assignedRequests =
        context.watch<AppProvider>().electricianAssignedRequests;
    final l10n = AppLocalizer.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              l10n.tr('أعمالي', 'Mes travaux'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child:
                assignedRequests.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off,
                            size: 80,
                            color: AppColors.inactive,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.tr(
                              'لا توجد أعمال بعد',
                              'Aucun travail pour le moment',
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            l10n.tr(
                              'سيتم عرض الأعمال المقبولة هنا',
                              'Les travaux acceptes apparaitront ici',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: assignedRequests.length,
                      itemBuilder: (context, index) {
                        final request = assignedRequests[index];
                        return _JobCard(request: request);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final ServiceRequest request;

  const _JobCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
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
              Expanded(
                child: Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.tr('قيد التنفيذ', 'En cours'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.tr('العميل:', 'Client:')} ${request.clientName}',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                l10n.location(request.wilaya, request.commune),
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(requestId: request.id),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: Text(l10n.tr('التواصل مع العميل', 'Contacter le client')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final l10n = AppLocalizer.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('حسابي', 'Mon compte')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              context.read<AppProvider>().toggleLanguage();
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? l10n.tr('كهربائي', 'Electricien'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              user?.phone ?? '',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (user?.wilaya != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.location(user?.wilaya ?? '', user?.commune ?? ''),
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 8),
            _SubscriptionBadge(
              status: user?.subscriptionStatus ?? SubscriptionStatus.inactive,
            ),
            const SizedBox(height: 24),
            // Subscription Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.tr('الاشتراك الشهري', 'Abonnement mensuel'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.tr('3000 د.ج / شهر', '3000 DZD / mois'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            user?.isSubscriptionActive == true
                                ? l10n.tr('التجديد', 'Renouveler')
                                : l10n.tr('تفعيل', 'Activer'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Menu Items
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: l10n.tr('معلومات الحساب', 'Informations du compte'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.history,
              title: l10n.tr('سجل الأعمال', 'Historique des travaux'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkHistoryScreen()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.star_outline,
              title: l10n.tr('تقييماتي', 'Mes avis'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyRatingsScreen()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: l10n.tr('الإشعارات', 'Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: l10n.tr('المساعدة والدعم', 'Aide et support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: l10n.tr('تسجيل الخروج', 'Se deconnecter'),
              isDestructive: true,
              onTap: () {
                context.read<AppProvider>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_left,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
    );
  }
}
