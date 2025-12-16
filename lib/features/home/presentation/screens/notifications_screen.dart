import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Écran de gestion des notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Exemple de notifications (à remplacer par des données réelles)
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Rappel de rendez-vous',
      'message':
          'Votre rendez-vous avec Dr. Aminou Kouyaté est prévu pour demain à 10h00.',
      'time': 'Il y a 2 heures',
      'isRead': false,
      'type': 'appointment',
    },
    {
      'id': 2,
      'title': 'Paiement confirmé',
      'message': 'Votre paiement de 15 000 FCFA a été traité avec succès.',
      'time': 'Hier, 14:30',
      'isRead': true,
      'type': 'payment',
    },
    {
      'id': 3,
      'title': 'Nouveau message',
      'message':
          'Dr. Aïcha Dossou vous a envoyé un message concernant votre consultation.',
      'time': 'Hier, 09:15',
      'isRead': false,
      'type': 'message',
    },
    {
      'id': 4,
      'title': 'Promotion spéciale',
      'message':
          '50% de réduction sur les consultations pédiatriques cette semaine.',
      'time': '05 déc 2025',
      'isRead': true,
      'type': 'promo',
    },
    {
      'id': 5,
      'title': 'Mise à jour de l\'application',
      'message':
          'Une nouvelle version de AlloSanté est disponible. Mettez à jour pour profiter des dernières fonctionnalités.',
      'time': '01 déc 2025',
      'isRead': true,
      'type': 'update',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          _buildHeader(),

          const SizedBox(height: 16),

          // Liste des notifications
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$unreadCount non lues',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),

          // Bouton pour tout marquer comme lu
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout lire',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _NotificationCard(
          notification: notification,
          onTap: () => _onNotificationTap(notification),
          onDismiss: () => _onNotificationDismiss(index),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Aucune notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          const Text(
            'Vous serez notifié lorsque quelque chose d\'important se produira',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    // Marquer comme lu
    setState(() {
      notification['isRead'] = true;
    });

    // TODO: Gérer l'action spécifique selon le type de notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification "${notification['title']}" tapée'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onNotificationDismiss(int index) {
    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification supprimée'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications marquées comme lues'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Carte de notification individuelle
class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'];
    final type = notification['type'];

    // Déterminer l'icône et la couleur selon le type
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'appointment':
        icon = Icons.calendar_today;
        iconColor = AppColors.primary;
        break;
      case 'payment':
        icon = Icons.payment;
        iconColor = AppColors.success;
        break;
      case 'message':
        icon = Icons.message;
        iconColor = AppColors.info;
        break;
      case 'promo':
        icon = Icons.local_offer;
        iconColor = AppColors.secondary;
        break;
      case 'update':
        icon = Icons.system_update;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.textSecondary;
    }

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isRead
                  ? AppColors.surface
                  : AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: isRead
                    ? AppColors.border
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),

                const SizedBox(width: 12),

                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Titre
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: isRead
                                    ? AppColors.textPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          ),

                          // Indicateur non lu
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification['message'],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Temps
                      Text(
                        notification['time'],
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
