import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';
import '../services/community_service.dart';
import '../widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final communityService = context.watch<CommunityService>();
    final notifications = communityService.notifications;

    // Group notifications by date
    final today = DateTime.now();
    final todayNotifs = <NotificationModel>[];
    final earlierNotifs = <NotificationModel>[];

    for (final n in notifications) {
      if (n.createdAt.day == today.day &&
          n.createdAt.month == today.month &&
          n.createdAt.year == today.year) {
        todayNotifs.add(n);
      } else {
        earlierNotifs.add(n);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const GradientText(text: 'Notifications', fontSize: 20, fontWeight: FontWeight.w700),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              onPressed: () => communityService.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 20),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: notifications.isEmpty
          ? EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications Yet',
              subtitle: 'You\'ll see updates about your works, likes, and more here.',
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (todayNotifs.isNotEmpty) ...[
                  _buildSectionHeader('Today'),
                  ...todayNotifs.map((n) => _NotificationTile(notification: n)),
                ],
                if (earlierNotifs.isNotEmpty) ...[
                  if (todayNotifs.isNotEmpty) const SizedBox(height: 8),
                  _buildSectionHeader('Earlier'),
                  ...earlierNotifs.map((n) => _NotificationTile(notification: n)),
                ],
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    final iconColor = _getColor();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.error.withAlpha(51),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      onDismissed: (_) {
        context.read<CommunityService>().markNotificationAsRead(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppTheme.cardBg
              : AppTheme.primary.withAlpha(13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? Colors.white.withAlpha(13)
                : AppTheme.primary.withAlpha(38),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(color: Colors.white.withAlpha(77), fontSize: 11),
              ),
            ],
          ),
          // Unread dot
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(102),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
              : null,
          onTap: () {
            if (!notification.isRead) {
              context.read<CommunityService>().markNotificationAsRead(notification.id);
            }
          },
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.newLike:
        return Icons.favorite;
      case NotificationType.newComment:
        return Icons.chat_bubble;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.proofCreated:
        return Icons.shield;
      case NotificationType.proofVerified:
        return Icons.verified;
      case NotificationType.systemAlert:
        return Icons.info;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.newLike:
        return AppTheme.accent;
      case NotificationType.newComment:
        return AppTheme.primary;
      case NotificationType.newFollower:
        return AppTheme.secondary;
      case NotificationType.proofCreated:
        return AppTheme.success;
      case NotificationType.proofVerified:
        return AppTheme.primary;
      case NotificationType.systemAlert:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
