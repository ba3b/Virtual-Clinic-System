import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String appointmentId;
  final String senderId;
  final String senderName;
  final String senderType; 
  final String content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.messageId,
    required this.appointmentId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderType: json['senderType'] ?? '',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'appointmentId': appointmentId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? appointmentId,
    String? senderId,
    String? senderName,
    String? senderType,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      appointmentId: appointmentId ?? this.appointmentId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}