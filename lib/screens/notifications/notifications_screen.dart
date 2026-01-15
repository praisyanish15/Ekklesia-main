import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      return const Center(child: Text('Please log in to view notifications'));
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.streamNotifications(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onDismiss: () => _dismissNotification(notification),
            );
          },
        );
      },
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    _notificationService.markAsRead(notification.id);

    // Show popup dialog
    showDialog(
      context: context,
      builder: (context) => _NotificationDialog(notification: notification),
    );
  }

  void _dismissNotification(NotificationModel notification) {
    // Mark as read when dismissed
    _notificationService.markAsRead(notification.id);
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.prayerRequest:
        return Icons.favorite;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.campaign:
        return Icons.volunteer_activism;
      case NotificationType.announcement:
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.prayerRequest:
        return Colors.red;
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.campaign:
        return Colors.green;
      case NotificationType.announcement:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? null : Colors.blue[50],
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorForType(notification.type),
            child: Icon(
              _getIconForType(notification.type),
              color: Colors.white,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: onTap,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

class _NotificationDialog extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationDialog({required this.notification});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getIconForType(notification.type)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(notification.title),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Text(
              DateFormat('MMM d, y h:mm a').format(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (notification.relatedId != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to related content based on type
              // This would be implemented based on the notification type
            },
            child: const Text('View'),
          ),
      ],
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.prayerRequest:
        return Icons.favorite;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.campaign:
        return Icons.volunteer_activism;
      case NotificationType.announcement:
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }
}
