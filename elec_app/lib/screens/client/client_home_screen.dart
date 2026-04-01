import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';
import '../client/create_request_screen.dart';
import '../client/request_details_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

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
      body: IndexedStack(
        index: _currentIndex,
        children: const [_HomeTab(), _MyRequestsTab(), _ProfileTab()],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateRequestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.tr('طلب جديد', 'Nouvelle demande')),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.tr('الرئيسية', 'Accueil'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: l10n.tr('طلباتي', 'Mes demandes'),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final l10n = AppLocalizer.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.tr('مرحباً،', 'Bonjour,')} ${user?.name ?? l10n.tr('عميل', 'Client')}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              l10n.tr(
                                'كيف يمكننا مساعدتك اليوم؟',
                                'Comment pouvons-nous vous aider aujourd hui ?',
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
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
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions
                  Text(
                    l10n.tr('خدماتنا', 'Nos services'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ServiceCard(
                          icon: Icons.electrical_services,
                          title: l10n.tr(
                            'تركيب كهرباء',
                            'Installation electrique',
                          ),
                          color: AppColors.primary,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateRequestScreen(),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ServiceCard(
                          icon: Icons.build,
                          title: l10n.tr('إصلاح أعطال', 'Reparation pannes'),
                          color: AppColors.secondary,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateRequestScreen(),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ServiceCard(
                          icon: Icons.lightbulb,
                          title: l10n.tr('إضاءة', 'Eclairage'),
                          color: AppColors.accent,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateRequestScreen(),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ServiceCard(
                          icon: Icons.ac_unit,
                          title: l10n.tr(
                            'تركيب مكيفات',
                            'Installation climatiseurs',
                          ),
                          color: Colors.cyan,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateRequestScreen(),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // How it works
                  Text(
                    l10n.tr(
                      'كيف تعمل المنصة؟',
                      'Comment fonctionne la plateforme ?',
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StepCard(
                    number: '1',
                    title: l10n.tr('أنشئ طلبك', 'Creez votre demande'),
                    subtitle: l10n.tr(
                      'حدد نوع الخدمة التي تحتاجها وموقعك',
                      'Precisez le type de service et votre localisation',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StepCard(
                    number: '2',
                    title: l10n.tr('استلم العروض', 'Recevez les offres'),
                    subtitle: l10n.tr(
                      'سيقدم الكهربائيون عروضهم بالأسعار والمواعيد',
                      'Les electriciens enverront leurs prix et disponibilites',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StepCard(
                    number: '3',
                    title: l10n.tr('اختر وتواصل', 'Choisissez et contactez'),
                    subtitle: l10n.tr(
                      'اختر العرض المناسب وتواصل مع الكهربائي',
                      'Choisissez la meilleure offre et contactez l electricien',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _StepCard({
    required this.number,
    required this.title,
    required this.subtitle,
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
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

class _MyRequestsTab extends StatelessWidget {
  const _MyRequestsTab();

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppProvider>().clientRequests;
    final l10n = AppLocalizer.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              l10n.tr('طلباتي', 'Mes demandes'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
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
                              'لا توجد طلبات بعد',
                              'Aucune demande pour le moment',
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateRequestScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: Text(
                              l10n.tr(
                                'إنشاء طلب جديد',
                                'Creer une nouvelle demande',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _RequestCard(request: request);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;

  const _RequestCard({required this.request});

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.open:
        return AppColors.primary;
      case RequestStatus.assigned:
        return AppColors.accent;
      case RequestStatus.closed:
        return AppColors.success;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case RequestStatus.open:
        return 'مفتوح';
      case RequestStatus.assigned:
        return 'قيد التنفيذ';
      case RequestStatus.closed:
        return 'مغلق';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailsScreen(request: request),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.tr(
                      _getStatusText(),
                      _getStatusText() == 'مفتوح'
                          ? 'Ouvert'
                          : _getStatusText() == 'قيد التنفيذ'
                          ? 'En cours'
                          : 'Ferme',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
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
                      style: TextStyle(
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
    );
  }

  String _formatDate(DateTime date, AppLocalizer l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return l10n.relativeTime(difference);
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final l10n = AppLocalizer.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? l10n.tr('عميل', 'Client'),
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
            const SizedBox(height: 32),
            // Menu Items
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: l10n.tr('معلومات الحساب', 'Informations du compte'),
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.history,
              title: l10n.tr('سجل الطلبات', 'Historique des demandes'),
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: l10n.tr('الإشعارات', 'Notifications'),
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: l10n.tr('المساعدة والدعم', 'Aide et support'),
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              title: l10n.tr('عن التطبيق', 'A propos'),
              onTap: () {},
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
