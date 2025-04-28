class NotificationModel {
  final String notificationId;
  final String userId;
  final String message;
  final String type; // 'appointment', 'reminder', 'system', etc.
  final DateTime dateTime;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.message,
    required this.type,
    required this.dateTime,
    this.isRead = false,
    this.additionalData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      dateTime: json['dateTime'] != null
          ? (json['dateTime'] is DateTime
              ? json['dateTime']
              : DateTime.parse(json['dateTime']))
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'message': message,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'isRead': isRead,
      if (additionalData != null) 'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? message,
    String? type,
    DateTime? dateTime,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}