import 'package:virtual_clinic_system/constants/departments.dart';

class UserId {
  final String uid;
  UserId({
    required this.uid,
  });
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String userType;
  final String fcmToken;
  final String nationalId;
  final String gender;
  final DateTime dateOfBirth;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.userType,
    required this.fcmToken,
    required this.nationalId,
    required this.gender,
    required this.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      userType: json['userType'] ?? 'patient',
      fcmToken: json['fcmToken'] ?? '',
      nationalId: json['nationalId'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : DateTime.now(),
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
      'fcmToken': fcmToken,
      'nationalId': nationalId,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }

  bool get isPatient => userType == 'patient';
  bool get isDoctor => userType == 'doctor';
  bool get isStaff => userType == 'staff';

  /// Returns the translation key for the user role.
  /// Use `AppLocalizations.of(context).translate(user.roleTranslationKey)`.
  String get roleTranslationKey {
    switch (userType.toLowerCase()) {
      case 'doctor':
        return 'doctor';
      case 'staff':
        return 'staff';
      case 'patient':
      default:
        return 'patient';
    }
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? userType,
    String? fcmToken,
    String? nationalId,
    String? gender,
    DateTime? dateOfBirth,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      fcmToken: fcmToken ?? this.fcmToken,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

class PatientModel extends UserModel {
  final List<Map<String, dynamic>>? medicalHistory;
  final List<String> eligibility;

  PatientModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.fcmToken,
    required super.nationalId,
    required super.gender,
    required super.dateOfBirth,
    this.medicalHistory,
    this.eligibility = const [DepartmentConstants.generalMedicine],
  }) : super(
          userType: 'patient',
        );

  factory PatientModel.fromUserModel(
    UserModel user, {
    List<Map<String, dynamic>>? medicalHistory,
    List<String>? eligibility,
  }) {
    return PatientModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      medicalHistory: medicalHistory,
      fcmToken: user.fcmToken,
      nationalId: user.nationalId,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
      eligibility: eligibility ?? [DepartmentConstants.generalMedicine],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['medicalHistory'] = medicalHistory;
    json['eligibility'] = eligibility;
    return json;
  }
}

class DoctorModel extends UserModel {
  final String specialty;

  DoctorModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.fcmToken,
    required super.nationalId,
    required super.gender,
    required super.dateOfBirth,
    required this.specialty,
  }) : super(
          userType: 'doctor',
        );

  factory DoctorModel.fromUserModel(UserModel user,
      {required String specialty}) {
    return DoctorModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      specialty: specialty,
      fcmToken: user.fcmToken,
      nationalId: user.nationalId,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
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
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.fcmToken,
    required super.nationalId,
    required super.gender,
    required super.dateOfBirth,
  }) : super(
          userType: 'staff',
        );

  factory StaffModel.fromUserModel(UserModel user) {
    return StaffModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      fcmToken: user.fcmToken,
      nationalId: user.nationalId,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
    );
  }
}