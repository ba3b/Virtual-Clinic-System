import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String patientId;
  final String? doctorId;
  final String status; 
  final DateTime dateTime;
  final String type; 
  final String? department; 
  final String? vaccinationType; 
  
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  static const String typeVirtual = 'virtual';
  static const String typePhysical = 'physical';
  static const String typeVaccination = 'vaccination';

  /// Returns the translation key for the appointment status.
  /// Use `AppLocalizations.of(context).translate(appointment.statusTranslationKey)`.
  String get statusTranslationKey {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      case 'in_progress':
        return 'in_progress';
      case 'pending':
      default:
        return 'pending';
    }
  }

  /// Returns the translation key for the appointment type.
  /// Use `AppLocalizations.of(context).translate(appointment.typeTranslationKey)`.
  String get typeTranslationKey {
    switch (type.toLowerCase()) {
      case 'virtual':
        return 'virtual_appointment';
      case 'physical':
        return 'physical_appointment';
      case 'vaccination':
        return 'vaccination_appointment';
      default:
        return type;
    }
  }

  AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    this.doctorId,
    required this.status,
    required this.dateTime,
    required this.type,
    this.department,
    this.vaccinationType,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'status': status,
      'dateTime': dateTime,
      'type': type,
      'department': department,
      'vaccinationType': vaccinationType,
    };
  }
  
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['appointmentId'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'],
      status: json['status'] ?? AppointmentModel.statusPending,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      type: json['type'] ?? '',
      department: json['department'],
      vaccinationType: json['vaccinationType'],
    );
  }
  
  AppointmentModel copyWith({
    String? appointmentId,
    String? patientId,
    String? doctorId,
    String? status,
    DateTime? dateTime,
    String? type,
    String? department,
    String? vaccinationType,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      department: department ?? this.department,
      vaccinationType: vaccinationType ?? this.vaccinationType,
    );
  }
}