import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String message;
  final DateTime dateTime;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.message,
    required this.dateTime,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      message: json['message'] ?? '',
      dateTime: json['dateTime'] != null
          ? (json['dateTime'] is Timestamp
              ? (json['dateTime'] as Timestamp).toDate()
              : json['dateTime'] is DateTime
                  ? json['dateTime']
                  : DateTime.parse(json['dateTime']))
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'message': message,
      'dateTime': dateTime.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? message,
    DateTime? dateTime,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.notificationId == notificationId &&
        other.userId == userId &&
        other.message == message &&
        other.dateTime == dateTime &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
        userId.hashCode ^
        message.hashCode ^
        dateTime.hashCode ^
        isRead.hashCode;
  }

  @override
  String toString() {
    return 'NotificationModel(notificationId: $notificationId, userId: $userId, message: $message, dateTime: $dateTime, isRead: $isRead)';
  }
}