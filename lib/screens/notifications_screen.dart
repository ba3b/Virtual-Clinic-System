import 'package:flutter/material.dart';
import '../api/notification_service.dart';
import '../components/custom_app_bar.dart';
import '../components/notification_item.dart';
import '../models/notification_model.dart';
import '../theme/theme.dart';
import 'patient/appointment_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationService.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationModel> _getFilteredNotifications(String type) {
    final notifications = _notificationService.getNotifications();
    if (type == 'all') {
      return notifications;
    } else {
      return notifications.where((n) => n.type == type).toList();
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read when tapped
    _notificationService.markAsRead(notification.notificationId);
    
    // Handle navigation based on notification type
    if (notification.type == 'appointment' && notification.additionalData != null) {
      final appointmentId = notification.additionalData!['appointmentId'];
      final appointmentType = notification.additionalData!['appointmentType'];
      final dateTime = DateTime.parse(notification.additionalData!['dateTime']);
      final doctorName = notification.additionalData!['doctorName'];
      
      // Navigate to appointment details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetailsScreen(
            appointmentData: {
              'appointmentId': appointmentId,
              'patientId': 'currentUser',
              'doctorId': doctorName != null ? 'D001' : null,
              'appointmentType': appointmentType,
              'dateTime': dateTime,
              'status': 'upcoming',
            },
          ),
        ),
      );
    }
    
    // For other notification types, just refresh the UI
    setState(() {});
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Appointments'),
                Tab(text: 'Reminders'),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<NotificationModel>>(
              valueListenable: _notificationService.notificationsNotifier,
              builder: (context, notifications, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(_getFilteredNotifications('all')),
                    _buildNotificationsList(_getFilteredNotifications('appointment')),
                    _buildNotificationsList(_getFilteredNotifications('reminder')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
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
          onTap: () => _handleNotificationTap(notification),
          onMarkAsRead: notification.isRead 
              ? null 
              : () {
                  _notificationService.markAsRead(notification.notificationId);
                  setState(() {});
                },
          onDelete: () {
            _notificationService.deleteNotification(notification.notificationId);
            setState(() {});
          },
        );
      },
    );
  }
}