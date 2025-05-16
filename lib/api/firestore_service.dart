import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_clinic_system/constants/departments.dart';
import 'package:virtual_clinic_system/models/user_model.dart';

class DatabaseService {
  final String uid;

  DatabaseService({
    required this.uid,
  });

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<void> createUserDocument(
      UserCredential? userCredential,
      String fullName,
      String phoneNumber,
      String address,
      String userType) async {
    if (userCredential != null && userCredential.user != null) {
      UserModel user = UserModel(
        userId: uid,
        name: fullName,
        email: userCredential.user!.email ?? '',
        phoneNumber: phoneNumber,
        address: address,
        userType: userType,
        fcmToken: '',
        //TODO: Add fcmToken retrieval logic
      );

      Map<String, dynamic> userData;

      switch (userType) {
        case 'patient':
          PatientModel patient = PatientModel.fromUserModel(
            user,
            eligibility: [DepartmentConstants.generalMedicine],
          );
          userData = patient.toJson();
          break;
        case 'doctor':
          DoctorModel doctor =
              DoctorModel.fromUserModel(user, specialty: DepartmentConstants.generalMedicine);
          userData = doctor.toJson();
          break;
        case 'staff':
          StaffModel staff = StaffModel.fromUserModel(user);
          userData = staff.toJson();
          break;
        default:
          userData = user.toJson();
      }

      await usersCollection.doc(uid).set(userData);
    }
  }

  Future<UserModel> getUserDetails(String userId) async {
    DocumentSnapshot<Object?> userSnapshot =
        await usersCollection.doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      userData['userId'] = userId;

      String userType = userData['userType'] ?? 'patient';

      switch (userType) {
        case 'patient':
          return PatientModel(
            userId: userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            address: userData['address'] ?? '',
            medicalHistory: userData['medicalHistory'],
            fcmToken: userData['fcmToken'] ?? '',
            eligibility: List<String>.from(userData['eligibility'] ??
                [DepartmentConstants.generalMedicine]),
          );
        case 'doctor':
          return DoctorModel(
            userId: userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            address: userData['address'] ?? '',
            specialty: userData['specialty'] ?? 'General',
            fcmToken: userData['fcmToken'] ?? '',
          );
        case 'staff':
          return StaffModel(
            userId: userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            address: userData['address'] ?? '',
            fcmToken: userData['fcmToken'] ?? '',
          );
        default:
          return UserModel.fromJson(userData);
      }
    } else {
      throw Exception('User document does not exist.');
    }
  }

  Stream<QuerySnapshot<Object?>> get users {
    return usersCollection.snapshots();
  }

  // Get user as stream
  Stream<UserModel> getUserStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        userData['userId'] = userId;

        String userType = userData['userType'] ?? 'patient';

        switch (userType) {
          case 'patient':
            return PatientModel(
              userId: userId,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
              address: userData['address'] ?? '',
              medicalHistory: userData['medicalHistory'],
              fcmToken: userData['fcmToken'] ?? '',
              eligibility: List<String>.from(userData['eligibility'] ??
                  [DepartmentConstants.generalMedicine]),
            );
          case 'doctor':
            return DoctorModel(
              userId: userId,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
              address: userData['address'] ?? '',
              specialty: userData['specialty'] ?? 'General',
              fcmToken: userData['fcmToken'] ?? '',
            );
          case 'staff':
            return StaffModel(
              userId: userId,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
              address: userData['address'] ?? '',
              fcmToken: userData['fcmToken'] ?? '',
            );
          default:
            return UserModel.fromJson(userData);
        }
      } else {
        throw Exception('User document does not exist.');
      }
    });
  }
}
