import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_clinic_system/api/notification_service.dart';
import 'package:virtual_clinic_system/components/custom_app_bar.dart';
import 'package:virtual_clinic_system/components/notification_item.dart';
import 'package:virtual_clinic_system/models/notification_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

class StaffNotificationsScreen extends StatelessWidget {
  const StaffNotificationsScreen({Key? key}) : super(key: key);

  void _markAsRead(String notificationId) {
    NotificationService().markAsRead(notificationId);
  }

  void _markAllAsRead(String userId, BuildContext context) async {
    await NotificationService().markAllAsRead(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    NotificationService().deleteNotification(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId?>(context);

    if (user == null) {
      return const Scaffold(
        appBar: CustomAppBar(
            title: 'Notifications', backgroundColor: AppTheme.primaryColor),
        body: Center(child: Text('Please log in to view notifications')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          return _buildNotificationsList(notifications);
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppTheme.textSecondaryColor),
            SizedBox(height: 16),
            Text('No notifications',
                style: TextStyle(color: AppTheme.textSecondaryColor)),
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
