import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    // Mock notifications data
    final notifications = [
      _NotificationItem(
        id: '1',
        title: l10n.tr('عرض جديد', 'Nouvelle offre'),
        body: l10n.tr(
          'لديك عرض جديد على طلب "تركيب مكيف هواء"',
          'Vous avez une nouvelle offre sur la demande "Installation de climatiseur"',
        ),
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.offer,
        isRead: false,
      ),
      _NotificationItem(
        id: '2',
        title: l10n.tr('تم قبول عرضك', 'Votre offre est acceptee'),
        body: l10n.tr(
          'تم قبول عرضك على طلب "إصلاح أعطال كهربائية"',
          'Votre offre a ete acceptee pour la demande "Reparation de pannes electriques"',
        ),
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.accepted,
        isRead: false,
      ),
      _NotificationItem(
        id: '3',
        title: l10n.tr('رسالة جديدة', 'Nouveau message'),
        body: l10n.tr(
          'لديك رسالة جديدة من أحمد محمد',
          'Vous avez un nouveau message de Ahmed Mohamed',
        ),
        time: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.message,
        isRead: true,
      ),
      _NotificationItem(
        id: '4',
        title: l10n.tr('تذكير بالاشتراك', 'Rappel d abonnement'),
        body: l10n.tr(
          'اشتراكك سينتهي خلال 5 أيام، جدد الآن للاستمرار',
          'Votre abonnement expire dans 5 jours, renouvelez maintenant',
        ),
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.subscription,
        isRead: true,
      ),
      _NotificationItem(
        id: '5',
        title: l10n.tr(
          'طلب جديد في منطقتك',
          'Nouvelle demande dans votre zone',
        ),
        body: l10n.tr(
          'هناك طلب جديد في الجزائر العاصمة - باب الوادي',
          'Il y a une nouvelle demande a Alger - Bab El Oued',
        ),
        time: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.request,
        isRead: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('الإشعارات', 'Notifications')),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.tr('تم تحديد الكل كمقروء', 'Tout marquer comme lu'),
                  ),
                ),
              );
            },
            child: Text(l10n.tr('تحديد الكل كمقروء', 'Tout marquer comme lu')),
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 80,
                      color: AppColors.inactive,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.tr('لا توجد إشعارات', 'Aucune notification'),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(notification: notification);
                },
              ),
    );
  }
}

enum NotificationType { offer, accepted, message, subscription, request }

class _NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem notification;

  const _NotificationCard({required this.notification});

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.accepted:
        return Icons.check_circle;
      case NotificationType.message:
        return Icons.chat;
      case NotificationType.subscription:
        return Icons.subscriptions;
      case NotificationType.request:
        return Icons.assignment;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.offer:
        return AppColors.secondary;
      case NotificationType.accepted:
        return AppColors.success;
      case NotificationType.message:
        return AppColors.primary;
      case NotificationType.subscription:
        return AppColors.accent;
      case NotificationType.request:
        return Colors.purple;
    }
  }

  String _formatTime(BuildContext context, DateTime time) {
    final l10n = AppLocalizer.of(context);
    return l10n.relativeTime(DateTime.now().difference(time));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? Colors.white
                : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isRead
                  ? AppColors.border
                  : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(context, notification.time),
                  style: TextStyle(
                    fontSize: 11,
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
