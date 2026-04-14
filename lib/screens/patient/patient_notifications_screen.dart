import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/notification_service.dart';
import '../../components/custom_app_bar.dart';
import '../../components/notification_item.dart';
import '../../models/notification_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import '../../localization/app_localizations.dart';

class PatientNotificationsScreen extends StatelessWidget {
  const PatientNotificationsScreen({Key? key}) : super(key: key);

  void _markAsRead(String notificationId) {
    NotificationService().markAsRead(notificationId);
  }

  void _markAllAsRead(String userId, BuildContext context) async {
    await NotificationService().markAllAsRead(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.green,
          content: Text(AppLocalizations.of(context).translate('mark_all_read'))),
    );
  }

  void _deleteNotification(String notificationId) {
    NotificationService().deleteNotification(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId?>(context);

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
            title: AppLocalizations.of(context).translate('notifications'), backgroundColor: AppTheme.primaryColor),
        body: Center(child: Text(AppLocalizations.of(context).translate('login_view_notifications'))),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('notifications'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(user.uid, context),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService().getUserNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${AppLocalizations.of(context).translate('error_colon')} ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          return _buildNotificationsList(notifications, context);
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications, BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off_outlined,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).translate('no_notifications'),
                style: const TextStyle(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return NotificationItem(
          notification: notification,
          onTap: () => _markAsRead(notification.notificationId),
          onMarkAsRead: notification.isRead
              ? null
              : () => _markAsRead(notification.notificationId),
          onDelete: () => _deleteNotification(notification.notificationId),
        );
      },
    );
  }
}
