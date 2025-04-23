class PrescriptionModel {
  final String prescriptionId;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String medicationDetails;
  final String dosageInstructions;
  final DateTime createdAt;
  
  PrescriptionModel({
    required this.prescriptionId,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.medicationDetails,
    required this.dosageInstructions,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      prescriptionId: json['prescriptionId'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      medicationDetails: json['medicationDetails'] ?? '',
      dosageInstructions: json['dosageInstructions'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt']))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionId': prescriptionId,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'medicationDetails': medicationDetails,
      'dosageInstructions': dosageInstructions,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}