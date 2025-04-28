import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Notification listeners
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<NotificationModel>> notificationsNotifier = 
      ValueNotifier<List<NotificationModel>>([]);

  // Sample notifications for demonstration
  final List<NotificationModel> _notifications = [
    NotificationModel(
      notificationId: '1',
      userId: 'currentUser',
      message: 'Your appointment with Dr. Mohammed has been confirmed.',
      type: 'appointment',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      additionalData: {
        'appointmentId': '104',
        'doctorName': 'Dr. Mohammed Hussein',
        'appointmentType': 'virtual',
        'dateTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      },
    ),
    NotificationModel(
      notificationId: '2',
      userId: 'currentUser',
      message: 'Reminder: You have an appointment tomorrow at 10:00 AM.',
      type: 'reminder',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      notificationId: '3',
      userId: 'currentUser',
      message: 'Dr. Fatima has been assigned to your appointment.',
      type: 'system',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      additionalData: {
        'appointmentId': '105',
        'doctorName': 'Dr. Fatima Abdullah',
      },
    ),
    NotificationModel(
      notificationId: '4',
      userId: 'currentUser',
      message: 'Your vaccination appointment has been verified.',
      type: 'appointment',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      additionalData: {
        'appointmentId': 'V001',
        'appointmentType': 'vaccination',
        'dateTime': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      },
    ),
  ];

  // Initialize the service
  void init() {
    _updateUnreadCount();
    notificationsNotifier.value = List.from(_notifications);
  }

  // Get all notifications
  List<NotificationModel> getNotifications() {
    return List.from(_notifications);
  }

  // Get unread notifications count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Add a new notification
  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    _updateNotifiers();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateNotifiers();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateNotifiers();
  }

  // Delete a notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.notificationId == notificationId);
    _updateNotifiers();
  }

  // Update notification count
  void _updateUnreadCount() {
    unreadCountNotifier.value = getUnreadCount();
  }

  // Update all notifiers
  void _updateNotifiers() {
    _updateUnreadCount();
    notificationsNotifier.value = List.from(_notifications);
  }

  // Create an appointment notification
  void createAppointmentNotification({
    required String userId,
    required String message,
    required String appointmentId,
    required String appointmentType,
    required DateTime appointmentDateTime,
    String? doctorName,
  }) {
    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: message,
      type: 'appointment',
      dateTime: DateTime.now(),
      isRead: false,
      additionalData: {
        'appointmentId': appointmentId,
        'appointmentType': appointmentType,
        'dateTime': appointmentDateTime.toIso8601String(),
        if (doctorName != null) 'doctorName': doctorName,
      },
    );
    
    addNotification(notification);
  }

  // Create a reminder notification
  void createReminderNotification({
    required String userId,
    required String message,
  }) {
    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: message,
      type: 'reminder',
      dateTime: DateTime.now(),
      isRead: false,
    );
    
    addNotification(notification);
  }

  void createSystemNotification({
    required String userId,
    required String message,
    Map<String, dynamic>? additionalData,
  }) {
    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: message,
      type: 'system',
      dateTime: DateTime.now(),
      isRead: false,
      additionalData: additionalData,
    );
    
    addNotification(notification);
  }
}