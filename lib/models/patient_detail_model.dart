class PatientDetailModel {
  final String patientId;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String? medicalHistory;
  final DateTime dateOfBirth;
  final String gender;
  final List<String>? allergies;
  final Map<String, dynamic>? medicalConditions;
  final List<Map<String, dynamic>>? pastAppointments;
  final List<Map<String, dynamic>>? prescriptions;

  PatientDetailModel({
    required this.patientId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.medicalHistory,
    required this.dateOfBirth,
    required this.gender,
    this.allergies,
    this.medicalConditions,
    this.pastAppointments,
    this.prescriptions,
  });

  factory PatientDetailModel.fromJson(Map<String, dynamic> json) {
    return PatientDetailModel(
      patientId: json['patientId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      medicalHistory: json['medicalHistory'],
      dateOfBirth: json['dateOfBirth'] != null
          ? (json['dateOfBirth'] is DateTime
              ? json['dateOfBirth']
              : DateTime.parse(json['dateOfBirth']))
          : DateTime.now(),
      gender: json['gender'] ?? '',
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      medicalConditions: json['medicalConditions'],
      pastAppointments: json['pastAppointments'] != null
          ? List<Map<String, dynamic>>.from(json['pastAppointments'])
          : null,
      prescriptions: json['prescriptions'] != null
          ? List<Map<String, dynamic>>.from(json['prescriptions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      if (allergies != null) 'allergies': allergies,
      if (medicalConditions != null) 'medicalConditions': medicalConditions,
      if (pastAppointments != null) 'pastAppointments': pastAppointments,
      if (prescriptions != null) 'prescriptions': prescriptions,
    };
  }
}