class AppointmentModel {
  final String appointmentId;
  final String patientId;
  final String? doctorId;
  final DateTime dateTime;
  final String type; // "virtual", "physical", or "vaccination"
  final String status; // "upcoming", "completed", "cancelled", "pending"
  final String? feedbackId;
  final String? prescriptionId;

  AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    this.doctorId,
    required this.dateTime,
    required this.type,
    required this.status,
    this.feedbackId,
    this.prescriptionId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['appointmentId'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'],
      dateTime: json['dateTime'] != null
          ? (json['dateTime'] is DateTime
              ? json['dateTime']
              : DateTime.parse(json['dateTime']))
          : DateTime.now(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      feedbackId: json['feedbackId'],
      prescriptionId: json['prescriptionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'status': status,
      if (feedbackId != null) 'feedbackId': feedbackId,
      if (prescriptionId != null) 'prescriptionId': prescriptionId,
    };
  }

  // Method to create a copy with updated fields
  AppointmentModel copyWith({
    String? appointmentId,
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    String? type,
    String? status,
    String? feedbackId,
    String? prescriptionId,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      status: status ?? this.status,
      feedbackId: feedbackId ?? this.feedbackId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
    );
  }
}