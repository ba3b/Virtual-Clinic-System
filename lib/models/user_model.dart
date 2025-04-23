class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String userType; 
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.userType,
    this.additionalData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      userType: json['userType'] ?? 'patient',
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'userType': userType,
      if (additionalData != null) 'additionalData': additionalData,
    };
  }

  // Create specific user types from the base model
  bool get isPatient => userType == 'patient';
  bool get isDoctor => userType == 'doctor';
  bool get isStaff => userType == 'staff';

  // Copy with method for updating user information
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? userType,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

// Extension models for specific user types
class PatientModel extends UserModel {
  final String? medicalHistory;

  PatientModel({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    this.medicalHistory,
    Map<String, dynamic>? additionalData,
  }) : super(
          userId: userId,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          userType: 'patient',
          additionalData: additionalData,
        );

  factory PatientModel.fromUserModel(UserModel user, {String? medicalHistory}) {
    return PatientModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      medicalHistory: medicalHistory,
      additionalData: user.additionalData,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['medicalHistory'] = medicalHistory;
    return json;
  }
}

class DoctorModel extends UserModel {
  final String specialty;

  DoctorModel({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required this.specialty,
    Map<String, dynamic>? additionalData,
  }) : super(
          userId: userId,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          userType: 'doctor',
          additionalData: additionalData,
        );

  factory DoctorModel.fromUserModel(UserModel user, {required String specialty}) {
    return DoctorModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      specialty: specialty,
      additionalData: user.additionalData,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['specialty'] = specialty;
    return json;
  }
}

class StaffModel extends UserModel {
  StaffModel({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    Map<String, dynamic>? additionalData,
  }) : super(
          userId: userId,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          userType: 'staff',
          additionalData: additionalData,
        );

  factory StaffModel.fromUserModel(UserModel user) {
    return StaffModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      additionalData: user.additionalData,
    );
  }
}