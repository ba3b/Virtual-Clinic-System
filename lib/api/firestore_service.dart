import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:virtual_clinic_system/constants/departments.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';

class DatabaseService {
  final String uid;

  DatabaseService({
    required this.uid,
  });

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference appointmentsCollection =
      FirebaseFirestore.instance.collection('Appointments');
  final CollectionReference prescriptionsCollection =
      FirebaseFirestore.instance.collection('Prescriptions');

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
          DoctorModel doctor = DoctorModel.fromUserModel(user,
              specialty: DepartmentConstants.generalMedicine);
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
            medicalHistory: _parseMedicalHistory(userData['medicalHistory']),
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

  List<Map<String, dynamic>>? _parseMedicalHistory(dynamic medicalHistoryData) {
    if (medicalHistoryData == null) return null;

    if (medicalHistoryData is List) {
      return medicalHistoryData.map((entry) {
        if (entry is Map<String, dynamic>) {
          return Map<String, dynamic>.from(entry);
        }
        return <String, dynamic>{};
      }).toList();
    }

    return null;
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

  Future<String> createAppointment({
    required String patientId,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String appointmentType,
    String? department,
    String? vaccinationType,
  }) async {
    try {
      final DateFormat timeFormat = DateFormat('h:mm a');
      final DateTime parsedTime = timeFormat.parse(appointmentTime);

      final DateTime appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      DocumentReference docRef = appointmentsCollection.doc();

      // Create appointment model
      AppointmentModel appointment = AppointmentModel(
        appointmentId: docRef.id,
        patientId: patientId,
        doctorId: null, // Will be assigned by staff
        status: AppointmentModel.statusPending,
        dateTime: appointmentDateTime,
        type: appointmentType,
        department: appointmentType != AppointmentModel.typeVaccination
            ? department
            : null,
        vaccinationType: appointmentType == AppointmentModel.typeVaccination
            ? vaccinationType
            : null,
      );

      // Save to Firestore
      await docRef.set(appointment.toJson());

      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Get appointments for a specific patient
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return appointmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppointmentModel.fromJson(data);
      }).toList();
    });
  }

  // Get appointments for a specific doctor
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppointmentModel.fromJson(data);
      }).toList();
    });
  }

  // Get all pending appointments (for staff)
  Stream<List<AppointmentModel>> getPendingAppointments() {
    return appointmentsCollection
        .where('status', isEqualTo: AppointmentModel.statusPending)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppointmentModel.fromJson(data);
      }).toList();
    });
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating appointment status: $e');
      throw Exception('Failed to update appointment status: $e');
    }
  }

  // Assign doctor to appointment
  Future<void> assignDoctorToAppointment(
      String appointmentId, String doctorId) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'doctorId': doctorId,
        'status': AppointmentModel.statusApproved,
      });
    } catch (e) {
      print('Error assigning doctor to appointment: $e');
      throw Exception('Failed to assign doctor to appointment: $e');
    }
  }

  // Check if slot is available
  Future<bool> isTimeSlotAvailable(
    DateTime appointmentDate,
    String appointmentTime,
    String appointmentType,
    String? department,
  ) async {
    try {
      // Parse the appointmentTime string to DateTime
      final DateFormat timeFormat = DateFormat('h:mm a');
      final DateTime parsedTime = timeFormat.parse(appointmentTime);

      // Combine date and time
      final DateTime appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      // Calculate the start and end of the 30-minute window
      final DateTime slotStart =
          appointmentDateTime.subtract(const Duration(minutes: 10));
      final DateTime slotEnd =
          appointmentDateTime.add(const Duration(minutes: 30));

      final List<String> activeStatuses = [
        AppointmentModel.statusPending,
        AppointmentModel.statusApproved,
        AppointmentModel.statusCompleted,
      ];

      QuerySnapshot snapshot;

      if (appointmentType != AppointmentModel.typeVaccination &&
          department != null) {
        snapshot = await appointmentsCollection
            .where('dateTime', isGreaterThanOrEqualTo: slotStart)
            .where('dateTime', isLessThan: slotEnd)
            .where('department', isEqualTo: department)
            .where('status', whereIn: activeStatuses)
            .get();
      } else if (appointmentType == AppointmentModel.typeVaccination) {
        snapshot = await appointmentsCollection
            .where('dateTime', isGreaterThanOrEqualTo: slotStart)
            .where('dateTime', isLessThan: slotEnd)
            .where('type', isEqualTo: AppointmentModel.typeVaccination)
            .where('status', whereIn: activeStatuses)
            .get();
      } else {
        snapshot = await appointmentsCollection
            .where('dateTime', isGreaterThanOrEqualTo: slotStart)
            .where('dateTime', isLessThan: slotEnd)
            .where('status', whereIn: activeStatuses)
            .get();
      }

      return snapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking slot availability: $e');
      throw Exception('Failed to check slot availability: $e');
    }
  }

  // Generate time slots for a specific date
  Future<List<String>> getAvailableTimeSlots(
    DateTime date,
    String appointmentType,
    String? department,
  ) async {
    // Define all possible time slots (9 AM to 4 PM, every 30 minutes)
    final List<String> allTimeSlots = [
      '9:00 AM',
      '9:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
      '12:00 PM',
      '1:30 PM',
      '2:00 PM',
      '2:30 PM',
      '3:00 PM',
      '3:30 PM',
      '4:00 PM',
    ];

    List<String> availableSlots = [];

    // Check availability for each slot
    for (String timeSlot in allTimeSlots) {
      bool isAvailable = await isTimeSlotAvailable(
        date,
        timeSlot,
        appointmentType,
        department,
      );

      if (isAvailable) {
        availableSlots.add(timeSlot);
      }
    }

    return availableSlots;
  }

  // Cancel an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'status': AppointmentModel.statusCancelled,
      });
    } catch (e) {
      print('Error cancelling appointment: $e');
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Delete an appointment (for staff only)
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      print('Error deleting appointment: $e');
      throw Exception('Failed to delete appointment: $e');
    }
  }

  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .where('userType', isEqualTo: 'doctor')
          .where('specialty', isEqualTo: specialty)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DoctorModel(
          userId: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          address: data['address'] ?? '',
          specialty: data['specialty'] ?? '',
          fcmToken: data['fcmToken'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting doctors by specialty: $e');
      throw Exception('Failed to get doctors by specialty: $e');
    }
  }

// Get all doctors
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      QuerySnapshot snapshot =
          await usersCollection.where('userType', isEqualTo: 'doctor').get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DoctorModel(
          userId: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          address: data['address'] ?? '',
          specialty: data['specialty'] ?? '',
          fcmToken: data['fcmToken'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting all doctors: $e');
      throw Exception('Failed to get all doctors: $e');
    }
  }

  Stream<List<AppointmentModel>> getVaccinationAppointments() {
    return appointmentsCollection
        .where('type', isEqualTo: AppointmentModel.typeVaccination)
        .where('status', whereIn: [
          AppointmentModel.statusApproved,
          AppointmentModel.statusCompleted
        ])
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return AppointmentModel.fromJson(data);
          }).toList();
        });
  }

  Future<void> addDiagnosisToMedicalHistory({
    required String patientId,
    required String diagnosis,
    required String appointmentId,
  }) async {
    try {
      final Map<String, dynamic> medicalHistoryEntry = {
        'timestamp': DateTime.now().toIso8601String(), // Use ISO string format
        'description': diagnosis,
        'appointmentId': appointmentId,
        'type': 'diagnosis',
      };

      await usersCollection.doc(patientId).update({
        'medicalHistory': FieldValue.arrayUnion([medicalHistoryEntry])
      });
    } catch (e) {
      print('Error adding diagnosis to medical history: $e');
      throw Exception('Failed to add diagnosis to medical history: $e');
    }
  }

// Method to get patient's medical history
  Future<List<Map<String, dynamic>>> getPatientMedicalHistory(
      String patientId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(patientId).get();

      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        dynamic medicalHistoryData = userData['medicalHistory'];

        if (medicalHistoryData != null && medicalHistoryData is List) {
          List<Map<String, dynamic>> medicalHistory = [];

          for (var entry in medicalHistoryData) {
            if (entry is Map<String, dynamic>) {
              Map<String, dynamic> processedEntry =
                  Map<String, dynamic>.from(entry);
              medicalHistory.add(processedEntry);
            }
          }

          // Sort by timestamp (most recent first)
          medicalHistory.sort((a, b) {
            String timestampA = a['timestamp'] as String? ?? '';
            String timestampB = b['timestamp'] as String? ?? '';

            try {
              DateTime dateA = DateTime.parse(timestampA);
              DateTime dateB = DateTime.parse(timestampB);
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });

          return medicalHistory;
        }
      }

      return [];
    } catch (e) {
      print('Error getting patient medical history: $e');
      throw Exception('Failed to get patient medical history: $e');
    }
  }

// Method to create prescription
  Future<String> createPrescription({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required String medicationDetails,
    required String dosageInstructions,
  }) async {
    try {
      DocumentReference docRef = prescriptionsCollection.doc();

      final Map<String, dynamic> prescriptionData = {
        'prescriptionId': docRef.id,
        'appointmentId': appointmentId,
        'patientId': patientId,
        'doctorId': doctorId,
        'medicationDetails': medicationDetails,
        'dosageInstructions': dosageInstructions,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(prescriptionData);

      return docRef.id;
    } catch (e) {
      print('Error creating prescription: $e');
      throw Exception('Failed to create prescription: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getPatientPrescriptions(String patientId) {
    return prescriptionsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> prescriptionsWithDoctors = [];

      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      for (var doc in snapshot.docs) {
        Map<String, dynamic> prescriptionData =
            doc.data() as Map<String, dynamic>;

        // Parse createdAt timestamp
        DateTime createdAt;
        if (prescriptionData['createdAt'] != null) {
          if (prescriptionData['createdAt'] is Timestamp) {
            createdAt = (prescriptionData['createdAt'] as Timestamp).toDate();
          } else {
            createdAt =
                DateTime.parse(prescriptionData['createdAt'].toString());
          }
        } else {
          continue; // Skip if no creation date
        }

        // Only include prescriptions from the last week
        if (createdAt.isAfter(oneWeekAgo)) {
          try {
            // Get doctor details
            DocumentSnapshot doctorDoc =
                await usersCollection.doc(prescriptionData['doctorId']).get();
            String doctorName = 'Unknown Doctor';
            String doctorSpecialty = 'General Medicine';

            if (doctorDoc.exists) {
              Map<String, dynamic> doctorData =
                  doctorDoc.data() as Map<String, dynamic>;
              doctorName = doctorData['name'] ?? 'Unknown Doctor';
              doctorSpecialty = doctorData['specialty'] ?? 'General Medicine';
            }

            prescriptionData['doctorName'] = doctorName;
            prescriptionData['doctorSpecialty'] = doctorSpecialty;
            prescriptionData['createdAt'] = createdAt;

            prescriptionsWithDoctors.add(prescriptionData);
          } catch (e) {
            print('Error getting doctor details: $e');
            // Add prescription without doctor details
            prescriptionData['doctorName'] = 'Unknown Doctor';
            prescriptionData['doctorSpecialty'] = 'General Medicine';
            prescriptionData['createdAt'] = createdAt;
            prescriptionsWithDoctors.add(prescriptionData);
          }
        }
      }

      return prescriptionsWithDoctors;
    });
  }

  Future<Map<String, dynamic>?> getPrescriptionById(
      String prescriptionId) async {
    try {
      DocumentSnapshot doc =
          await prescriptionsCollection.doc(prescriptionId).get();

      if (doc.exists) {
        Map<String, dynamic> prescriptionData =
            doc.data() as Map<String, dynamic>;

        // Get doctor details
        DocumentSnapshot doctorDoc =
            await usersCollection.doc(prescriptionData['doctorId']).get();
        String doctorName = 'Unknown Doctor';
        String doctorSpecialty = 'General Medicine';

        if (doctorDoc.exists) {
          Map<String, dynamic> doctorData =
              doctorDoc.data() as Map<String, dynamic>;
          doctorName = doctorData['name'] ?? 'Unknown Doctor';
          doctorSpecialty = doctorData['specialty'] ?? 'General Medicine';
        }

        prescriptionData['doctorName'] = doctorName;
        prescriptionData['doctorSpecialty'] = doctorSpecialty;

        // Parse createdAt timestamp
        if (prescriptionData['createdAt'] != null) {
          if (prescriptionData['createdAt'] is Timestamp) {
            prescriptionData['createdAt'] =
                (prescriptionData['createdAt'] as Timestamp).toDate();
          } else {
            prescriptionData['createdAt'] =
                DateTime.parse(prescriptionData['createdAt'].toString());
          }
        }

        return prescriptionData;
      }

      return null;
    } catch (e) {
      print('Error getting prescription by ID: $e');
      throw Exception('Failed to get prescription: $e');
    }
  }

  Future<void> updatePatientEligibility({
    required String patientId,
    required List<String> eligibility,
  }) async {
    try {
      await usersCollection.doc(patientId).update({
        'eligibility': eligibility,
      });
    } catch (e) {
      print('Error updating patient eligibility: $e');
      throw Exception('Failed to update patient eligibility: $e');
    }
  }

  Future<List<String>> getPatientEligibility(String patientId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(patientId).get();

      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        return List<String>.from(userData['eligibility'] ?? [DepartmentConstants.generalMedicine]);
      }

      return [DepartmentConstants.generalMedicine];
    } catch (e) {
      print('Error getting patient eligibility: $e');
      throw Exception('Failed to get patient eligibility: $e');
    }
  }
}