import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<NotificationModel>> notificationsNotifier = 
      ValueNotifier<List<NotificationModel>>([]);

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
    NotificationModel(
      notificationId: 'd1',
      userId: 'currentUser',
      message: 'New appointment with Ahmed Ali has been scheduled.',
      type: 'appointment',
      dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      additionalData: {
        'appointmentId': 'A001',
        'patientId': 'P001',
        'patientName': 'Ahmed Ali',
        'appointmentType': 'virtual',
        'dateTime': DateTime.now().add(const Duration(days: 1, hours: 2)).toIso8601String(),
      },
    ),
    NotificationModel(
      notificationId: 'd2',
      userId: 'currentUser',
      message: 'Patient Fatima Mohammed has a medical query.',
      type: 'patient_request',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      additionalData: {
        'patientId': 'P002',
        'patientName': 'Fatima Mohammed',
        'requestType': 'medical_query',
        'requestId': 'Q001',
      },
    ),
    NotificationModel(
      notificationId: 's1',
      userId: 'currentUser',
      message: 'New appointment request from Abdullah Ahmed needs verification.',
      type: 'verification_request',
      dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      additionalData: {
        'appointmentId': 'A101',
        'patientId': 'P101',
        'patientName': 'Abdullah Ahmed',
        'appointmentType': 'virtual',
        'dateTime': DateTime.now().add(const Duration(days: 1, hours: 2)).toIso8601String(),
      },
    ),
    NotificationModel(
      notificationId: 's3',
      userId: 'currentUser',
      message: 'Vaccination appointment for Sarah Mohammed has been successfully completed.',
      type: 'vaccination',
      dateTime: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
      additionalData: {
        'appointmentId': 'V001',
        'patientId': 'P102',
        'patientName': 'Sarah Mohammed',
        'vaccineType': 'Influenza',
      },
    ),
  ];

  void init() {
    _updateUnreadCount();
    notificationsNotifier.value = List.from(_notifications);
  }

  List<NotificationModel> getNotifications() {
    return List.from(_notifications);
  }

  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    _updateNotifiers();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateNotifiers();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateNotifiers();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.notificationId == notificationId);
    _updateNotifiers();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value = getUnreadCount();
  }

  void _updateNotifiers() {
    _updateUnreadCount();
    notificationsNotifier.value = List.from(_notifications);
  }

  void createAppointmentNotification({
    required String userId,
    required String message,
    required String appointmentId,
    required String appointmentType,
    required DateTime appointmentDateTime,
    String? doctorName,
    String? doctorId,
    String? patientName,
    String? patientId,
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
        if (doctorId != null) 'doctorId': doctorId,
        if (patientName != null) 'patientName': patientName,
        if (patientId != null) 'patientId': patientId,
      },
    );
    
    addNotification(notification);
  }

  void createReminderNotification({
    required String userId,
    required String message,
    Map<String, dynamic>? additionalData,
  }) {
    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: message,
      type: 'reminder',
      dateTime: DateTime.now(),
      isRead: false,
      additionalData: additionalData,
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

  void createPatientRequestNotification({
    required String patientId,
    required String patientName,
    required String message,
    required String requestType,
    String? requestId,
  }) {
    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'currentUser',
      message: message,
      type: 'patient_request',
      dateTime: DateTime.now(),
      isRead: false,
      additionalData: {
        'patientId': patientId,
        'patientName': patientName,
        'requestType': requestType,
        if (requestId != null) 'requestId': requestId,
      },
    );
    
    addNotification(notification);
  }

  void createVerificationRequestNotification({
    required String appointmentId,
    required String patientId,
    required String patientName,
    required String appointmentType,
    required DateTime appointmentDateTime,
  }) {
    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'currentUser',
      message: 'New $appointmentType appointment request from $patientName needs verification.',
      type: 'verification_request',
      dateTime: DateTime.now(),
      isRead: false,
      additionalData: {
        'appointmentId': appointmentId,
        'patientId': patientId,
        'patientName': patientName,
        'appointmentType': appointmentType,
        'dateTime': appointmentDateTime.toIso8601String(),
      },
    );
    
    addNotification(notification);
  }

  void createVaccinationNotification({
    required String patientId,
    required String patientName,
    required String vaccineType,
    String? appointmentId,
    String? status,
  }) {
    String message = status == 'completed'
        ? 'Vaccination for $patientName ($vaccineType) has been completed.'
        : 'New vaccination appointment for $patientName ($vaccineType) has been scheduled.';

    final notification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'currentUser',
      message: message,
      type: 'vaccination',
      dateTime: DateTime.now(),
      isRead: false,
      additionalData: {
        'patientId': patientId,
        'patientName': patientName,
        'vaccineType': vaccineType,
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (status != null) 'status': status,
      },
    );
    
    addNotification(notification);
  }
}