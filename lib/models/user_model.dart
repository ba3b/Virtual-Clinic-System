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

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      userType: json['userType'] ?? 'patient',
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
    };
  }

  bool get isPatient => userType == 'patient';
  bool get isDoctor => userType == 'doctor';
  bool get isStaff => userType == 'staff';

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
    );
  }
}

class PatientModel extends UserModel {
  final Object? medicalHistory;

  PatientModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
    this.medicalHistory,
  }) : super(
          userType: 'patient',
        );

  factory PatientModel.fromUserModel(UserModel user, {Object? medicalHistory}) {
    return PatientModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      medicalHistory: medicalHistory,
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
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required this.specialty,
  }) : super(
          userType: 'doctor',
        );

  factory DoctorModel.fromUserModel(UserModel user, {required String specialty}) {
    return DoctorModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      specialty: specialty,
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
    );
  }
}