import 'package:flutter/material.dart';
import 'package:virtual_clinic_system/api/notification_service.dart';
import 'package:virtual_clinic_system/components/custom_app_bar.dart';
import 'package:virtual_clinic_system/components/notification_item.dart';
import 'package:virtual_clinic_system/models/notification_model.dart';
import 'package:virtual_clinic_system/theme/theme.dart';

import 'appointment_details_screen.dart';

class StaffNotificationsScreen extends StatefulWidget {
  const StaffNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<StaffNotificationsScreen> createState() => _StaffNotificationsScreenState();
}

class _StaffNotificationsScreenState extends State<StaffNotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    _notificationService.markAsRead(notification.notificationId);
    
    if (notification.type == 'appointment' && notification.additionalData != null) {
      final appointmentId = notification.additionalData!['appointmentId'];
      final patientId = notification.additionalData!['patientId'];
      final patientName = notification.additionalData!['patientName'];
      final appointmentType = notification.additionalData!['appointmentType'];
      final dateTime = DateTime.parse(notification.additionalData!['dateTime']);
      final doctorId = notification.additionalData!['doctorId'];
      final doctorName = notification.additionalData!['doctorName'];
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffAppointmentDetailsScreen(
            appointment: _createAppointmentFromNotification(
              appointmentId, 
              patientId, 
              doctorId,
              appointmentType, 
              dateTime
            ),
            patientName: patientName ?? 'Unknown Patient',
            doctorName: doctorName,
            availableDoctors: [],
          ),
        ),
      );
    } else if (notification.type == 'verification_request' && notification.additionalData != null) {
      final appointmentId = notification.additionalData!['appointmentId'];
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verification Request'),
            content: const Text('Do you want to verify this appointment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment verified successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: const Text('Verify'),
              ),
            ],
          );
        },
      );
    }
    
    setState(() {});
  }

  dynamic _createAppointmentFromNotification(
    String appointmentId, 
    String patientId,
    String? doctorId,
    String appointmentType,
    DateTime dateTime
  ) {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'type': appointmentType,
      'status': doctorId != null ? 'upcoming' : 'pending',
      'dateTime': dateTime,
    };
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
              isScrollable: true,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Verification Requests'),
                Tab(text: 'Appointments'),
                Tab(text: 'Vaccination'),
                Tab(text: 'System'),
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
                    _buildNotificationsList(_getFilteredNotifications('verification_request')),
                    _buildNotificationsList(_getFilteredNotifications('appointment')),
                    _buildNotificationsList(_getFilteredNotifications('vaccination')),
                    _buildNotificationsList(_getFilteredNotifications('system')),
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