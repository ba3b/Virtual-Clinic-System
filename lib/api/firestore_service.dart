import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:virtual_clinic_system/constants/departments.dart';
import 'package:virtual_clinic_system/models/appointment_model.dart';
import 'package:virtual_clinic_system/models/message_model.dart';
import 'package:virtual_clinic_system/models/user_model.dart';
import 'package:virtual_clinic_system/models/notification_model.dart';

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
  final CollectionReference vaccinationRecordsCollection =
      FirebaseFirestore.instance.collection('VaccinationRecords');
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('Messages');
  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('Notifications');

  Future<String> createNotification({
    required String userId,
    required String message,
  }) async {
    try {
      DocumentReference docRef = notificationsCollection.doc();

      final notification = NotificationModel(
        notificationId: docRef.id,
        userId: userId,
        message: message,
        dateTime: DateTime.now(),
        isRead: false,
      );

      await docRef.set(notification.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating notification: $e');
      throw Exception('Failed to create notification: $e');
    }
  }

  Future<List<String>> _getAllStaffUserIds() async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .where('userType', isEqualTo: 'staff')
          .get();
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting staff user IDs: $e');
      return [];
    }
  }

  Future<String> _getUserName(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        return userData['name'] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown User';
    }
  }

  Future<void> createUserDocument(
      UserCredential? userCredential,
      String fullName,
      String phoneNumber,
      String address,
      String userType,
      String nationalId,
      String gender,
      DateTime dateOfBirth) async {
    if (userCredential != null && userCredential.user != null) {
      UserModel user = UserModel(
        userId: uid,
        name: fullName,
        email: userCredential.user!.email ?? '',
        phoneNumber: phoneNumber,
        address: address,
        userType: userType,
        fcmToken: '',
        nationalId: nationalId,
        gender: gender,
        dateOfBirth: dateOfBirth,
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

      if (userType != 'staff') {
        List<String> staffIds = await _getAllStaffUserIds();
        for (String staffId in staffIds) {
          await createNotification(
            userId: staffId,
            message: "New $userType registered: $fullName",
          );
        }
      }
    }
  }

  Future<void> createStaffManagedUserDocument(
      UserCredential? userCredential,
      String fullName,
      String phoneNumber,
      String address,
      String userType,
      String nationalId,
      String gender,
      DateTime dateOfBirth,
      String? specialty) async {
    if (userCredential != null && userCredential.user != null) {
      UserModel user = UserModel(
        userId: userCredential.user!.uid,
        name: fullName,
        email: userCredential.user!.email ?? '',
        phoneNumber: phoneNumber,
        address: address,
        userType: userType,
        fcmToken: '',
        nationalId: nationalId,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      Map<String, dynamic> userData;

      switch (userType) {
        case 'doctor':
          DoctorModel doctor = DoctorModel.fromUserModel(user,
              specialty: specialty ?? DepartmentConstants.generalMedicine);
          userData = doctor.toJson();
          break;
        case 'staff':
          StaffModel staff = StaffModel.fromUserModel(user);
          userData = staff.toJson();
          break;
        default:
          userData = user.toJson();
      }

      await usersCollection.doc(userCredential.user!.uid).set(userData);

      // Notify all staff about new staff-managed user creation
      List<String> staffIds = await _getAllStaffUserIds();
      for (String staffId in staffIds) {
        await createNotification(
          userId: staffId,
          message: "New $userType account created by staff: $fullName",
        );
      }

      // If it's a doctor, notify the doctor about their account creation
      if (userType == 'doctor') {
        await createNotification(
          userId: userCredential.user!.uid,
          message: "Welcome Dr. $fullName! Your account has been created successfully.",
        );
      }
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
            nationalId: userData['nationalId'] ?? '',
            gender: userData['gender'] ?? '',
            dateOfBirth: userData['dateOfBirth'] != null
                ? DateTime.parse(userData['dateOfBirth'])
                : DateTime.now(),
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
            nationalId: userData['nationalId'] ?? '',
            gender: userData['gender'] ?? '',
            dateOfBirth: userData['dateOfBirth'] != null
                ? DateTime.parse(userData['dateOfBirth'])
                : DateTime.now(),
          );
        case 'staff':
          return StaffModel(
            userId: userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            address: userData['address'] ?? '',
            fcmToken: userData['fcmToken'] ?? '',
            nationalId: userData['nationalId'] ?? '',
            gender: userData['gender'] ?? '',
            dateOfBirth: userData['dateOfBirth'] != null
                ? DateTime.parse(userData['dateOfBirth'])
                : DateTime.now(),
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
              medicalHistory: _parseMedicalHistory(
                  userData['medicalHistory']), // Use the parsing method
              fcmToken: userData['fcmToken'] ?? '',
              nationalId: userData['nationalId'] ?? '',
              gender: userData['gender'] ?? '',
              dateOfBirth: userData['dateOfBirth'] != null
                  ? DateTime.parse(userData['dateOfBirth'])
                  : DateTime.now(),
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
              nationalId: userData['nationalId'] ?? '',
              gender: userData['gender'] ?? '',
              dateOfBirth: userData['dateOfBirth'] != null
                  ? DateTime.parse(userData['dateOfBirth'])
                  : DateTime.now(),
            );
          case 'staff':
            return StaffModel(
              userId: userId,
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
              address: userData['address'] ?? '',
              fcmToken: userData['fcmToken'] ?? '',
              nationalId: userData['nationalId'] ?? '',
              gender: userData['gender'] ?? '',
              dateOfBirth: userData['dateOfBirth'] != null
                  ? DateTime.parse(userData['dateOfBirth'])
                  : DateTime.now(),
            );
          default:
            return UserModel.fromJson(userData);
        }
      } else {
        throw Exception('User document does not exist.');
      }
    });
  }

  Future<String> sendMessage(MessageModel message) async {
    try {
      DocumentReference docRef = messagesCollection.doc();

      final messageWithId = message.copyWith(messageId: docRef.id);

      await docRef.set(messageWithId.toJson());

      // Get appointment details to notify the other party
      DocumentSnapshot appointmentDoc = await appointmentsCollection.doc(message.appointmentId).get();
      if (appointmentDoc.exists) {
        Map<String, dynamic> appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        String patientId = appointmentData['patientId'];
        String? doctorId = appointmentData['doctorId'];
        
        String senderName = await _getUserName(message.senderId);
        
        // Notify the recipient
        String recipientId = message.senderId == patientId ? doctorId ?? '' : patientId;
        if (recipientId.isNotEmpty) {
          await createNotification(
            userId: recipientId,
            message: "New message from $senderName in your appointment chat",
          );
        }
      }

      return docRef.id;
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> getAppointmentMessages(String appointmentId) {
    return messagesCollection
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return MessageModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await messagesCollection.doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking message as read: $e');
      throw Exception('Failed to mark message as read: $e');
    }
  }

  Future<void> markAppointmentMessagesAsRead(
      String appointmentId, String currentUserId) async {
    try {
      QuerySnapshot unreadMessages = await messagesCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking appointment messages as read: $e');
      throw Exception('Failed to mark appointment messages as read: $e');
    }
  }

  Future<int> getUnreadMessageCount(
      String appointmentId, String currentUserId) async {
    try {
      QuerySnapshot unreadMessages = await messagesCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      return unreadMessages.docs.length;
    } catch (e) {
      print('Error getting unread message count: $e');
      return 0;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await messagesCollection.doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message: $e');
    }
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

      AppointmentModel appointment = AppointmentModel(
        appointmentId: docRef.id,
        patientId: patientId,
        doctorId: null,
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

      await docRef.set(appointment.toJson());

      // Notify all staff about new appointment request
      String patientName = await _getUserName(patientId);
      List<String> staffIds = await _getAllStaffUserIds();
      
      String appointmentDetails = appointmentType == AppointmentModel.typeVaccination 
          ? "vaccination appointment for $vaccinationType"
          : "$department appointment";
      
      String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
      
      for (String staffId in staffIds) {
        await createNotification(
          userId: staffId,
          message: "New $appointmentDetails requested by $patientName on $formattedDate at $appointmentTime",
        );
      }

      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      throw Exception('Failed to create appointment: $e');
    }
  }

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

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'status': status,
      });

      // Get appointment details for notification
      DocumentSnapshot appointmentDoc = await appointmentsCollection.doc(appointmentId).get();
      if (appointmentDoc.exists) {
        Map<String, dynamic> appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        String patientId = appointmentData['patientId'];
        DateTime appointmentDateTime = appointmentData['dateTime'].toDate();
        String appointmentType = appointmentData['type'];
        
        String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDateTime);
        String formattedTime = DateFormat('h:mm a').format(appointmentDateTime);
        
        String appointmentDetails = appointmentType == AppointmentModel.typeVaccination 
            ? "vaccination appointment"
            : "${appointmentData['department']} appointment";

        if (status == AppointmentModel.statusApproved) {
          await createNotification(
            userId: patientId,
            message: "Your $appointmentDetails on $formattedDate at $formattedTime has been approved",
          );
        } else if (status == AppointmentModel.statusRejected) {
          await createNotification(
            userId: patientId,
            message: "Your $appointmentDetails on $formattedDate at $formattedTime has been rejected",
          );
        } else if (status == AppointmentModel.statusCompleted) {
          await createNotification(
            userId: patientId,
            message: "Your $appointmentDetails on $formattedDate has been completed",
          );
        }
      }
    } catch (e) {
      print('Error updating appointment status: $e');
      throw Exception('Failed to update appointment status: $e');
    }
  }

  Future<void> assignDoctorToAppointment(
      String appointmentId, String doctorId) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'doctorId': doctorId,
        'status': AppointmentModel.statusApproved,
      });

      // Get appointment and doctor details for notifications
      DocumentSnapshot appointmentDoc = await appointmentsCollection.doc(appointmentId).get();
      if (appointmentDoc.exists) {
        Map<String, dynamic> appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        String patientId = appointmentData['patientId'];
        DateTime appointmentDateTime = appointmentData['dateTime'].toDate();
        String appointmentType = appointmentData['type'];
        
        String patientName = await _getUserName(patientId);
        String doctorName = await _getUserName(doctorId);
        
        String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDateTime);
        String formattedTime = DateFormat('h:mm a').format(appointmentDateTime);
        
        String appointmentDetails = appointmentType == AppointmentModel.typeVaccination 
            ? "vaccination appointment"
            : "${appointmentData['department']} appointment";

        // Notify patient about approval and doctor assignment
        await createNotification(
          userId: patientId,
          message: "Your $appointmentDetails on $formattedDate at $formattedTime has been approved",
        );

        if (appointmentType != AppointmentModel.typeVaccination) {
          await createNotification(
            userId: patientId,
            message: "Your appointment has been assigned to Dr. $doctorName",
          );
        }

        // Notify doctor about new appointment assignment
        await createNotification(
          userId: doctorId,
          message: "New $appointmentDetails assigned to you with $patientName on $formattedDate at $formattedTime",
        );
      }
    } catch (e) {
      print('Error assigning doctor to appointment: $e');
      throw Exception('Failed to assign doctor to appointment: $e');
    }
  }

  Future<bool> isTimeSlotAvailable(
    DateTime appointmentDate,
    String appointmentTime,
    String appointmentType,
    String? department,
  ) async {
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

  Future<List<String>> getAvailableTimeSlots(
    DateTime date,
    String appointmentType,
    String? department,
  ) async {
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

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'status': AppointmentModel.statusCancelled,
      });

      // Get appointment details for notification
      DocumentSnapshot appointmentDoc = await appointmentsCollection.doc(appointmentId).get();
      if (appointmentDoc.exists) {
        Map<String, dynamic> appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        String patientId = appointmentData['patientId'];
        String? doctorId = appointmentData['doctorId'];
        DateTime appointmentDateTime = appointmentData['dateTime'].toDate();
        String appointmentType = appointmentData['type'];
        
        String patientName = await _getUserName(patientId);
        String formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDateTime);
        String formattedTime = DateFormat('h:mm a').format(appointmentDateTime);
        
        String appointmentDetails = appointmentType == AppointmentModel.typeVaccination 
            ? "vaccination appointment"
            : "${appointmentData['department']} appointment";

        // Notify doctor if assigned
        if (doctorId != null) {
          await createNotification(
            userId: doctorId,
            message: "$appointmentDetails with $patientName on $formattedDate at $formattedTime has been cancelled",
          );
        }

        // Notify all staff about cancellation
        List<String> staffIds = await _getAllStaffUserIds();
        for (String staffId in staffIds) {
          await createNotification(
            userId: staffId,
            message: "$appointmentDetails by $patientName on $formattedDate at $formattedTime has been cancelled",
          );
        }
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      throw Exception('Failed to cancel appointment: $e');
    }
  }

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
          nationalId: data['nationalId'] ?? '',
          gender: data['gender'] ?? '',
          dateOfBirth: data['dateOfBirth'] != null
              ? DateTime.parse(data['dateOfBirth'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error getting doctors by specialty: $e');
      throw Exception('Failed to get doctors by specialty: $e');
    }
  }

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
          nationalId: data['nationalId'] ?? '',
          gender: data['gender'] ?? '',
          dateOfBirth: data['dateOfBirth'] != null
              ? DateTime.parse(data['dateOfBirth'])
              : DateTime.now(),
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
        'timestamp': DateTime.now().toIso8601String(),
        'description': diagnosis,
        'appointmentId': appointmentId,
        'type': 'diagnosis',
      };

      await usersCollection.doc(patientId).update({
        'medicalHistory': FieldValue.arrayUnion([medicalHistoryEntry])
      });

      // Notify patient about new diagnosis
      await createNotification(
        userId: patientId,
        message: "New diagnosis has been added to your medical history",
      );
    } catch (e) {
      print('Error adding diagnosis to medical history: $e');
      throw Exception('Failed to add diagnosis to medical history: $e');
    }
  }

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
        'status': 'active',
        'pharmacyRegistrationId': null,
        'pharmacyMedicationDetails': null,
        'priceInSAR': null,
      };

      await docRef.set(prescriptionData);

      // Notify patient about new prescription
      String doctorName = await _getUserName(doctorId);
      await createNotification(
        userId: patientId,
        message: "New prescription has been issued by Dr. $doctorName",
      );

      return docRef.id;
    } catch (e) {
      print('Error creating prescription: $e');
      throw Exception('Failed to create prescription: $e');
    }
  }

  Future<void> updatePrescriptionPharmacyDetails({
    required String prescriptionId,
    required String pharmacyRegistrationId,
    required String pharmacyMedicationDetails,
    required double priceInSAR,
  }) async {
    try {
      await prescriptionsCollection.doc(prescriptionId).update({
        'pharmacyRegistrationId': pharmacyRegistrationId,
        'pharmacyMedicationDetails': pharmacyMedicationDetails,
        'priceInSAR': priceInSAR,
        'status': 'expired',
      });

      // Get prescription details to notify patient
      DocumentSnapshot prescriptionDoc = await prescriptionsCollection.doc(prescriptionId).get();
      if (prescriptionDoc.exists) {
        Map<String, dynamic> prescriptionData = prescriptionDoc.data() as Map<String, dynamic>;
        String patientId = prescriptionData['patientId'];
        
        await createNotification(
          userId: patientId,
          message: "Your prescription has been processed by the pharmacy. Total cost: ${priceInSAR.toStringAsFixed(2)} SAR",
        );
      }
    } catch (e) {
      print('Error updating prescription pharmacy details: $e');
      throw Exception('Failed to update prescription pharmacy details: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getPatientPrescriptions(String patientId) {
    return prescriptionsCollection
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> prescriptionsWithDoctors = [];

      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      for (var doc in snapshot.docs) {
        Map<String, dynamic> prescriptionData =
            doc.data() as Map<String, dynamic>;

        DateTime createdAt;
        if (prescriptionData['createdAt'] != null) {
          if (prescriptionData['createdAt'] is Timestamp) {
            createdAt = (prescriptionData['createdAt'] as Timestamp).toDate();
          } else {
            createdAt =
                DateTime.parse(prescriptionData['createdAt'].toString());
          }
        } else {
          continue;
        }

        if (createdAt.isAfter(oneWeekAgo)) {
          try {
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

      // Notify patient about eligibility update
      String eligibilityList = eligibility.join(', ');
      await createNotification(
        userId: patientId,
        message: "Your department eligibility has been updated to: $eligibilityList",
      );
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
        return List<String>.from(
            userData['eligibility'] ?? [DepartmentConstants.generalMedicine]);
      }

      return [DepartmentConstants.generalMedicine];
    } catch (e) {
      print('Error getting patient eligibility: $e');
      throw Exception('Failed to get patient eligibility: $e');
    }
  }

  Future<String> createVaccinationRecord({
    required String appointmentId,
    required String patientId,
    required String vaccineType,
    required String actualVaccineType,
  }) async {
    try {
      DocumentReference docRef = vaccinationRecordsCollection.doc();

      final Map<String, dynamic> vaccinationData = {
        'vaccinationRecordId': docRef.id,
        'appointmentId': appointmentId,
        'patientId': patientId,
        'vaccineType': vaccineType,
        'actualVaccineType': actualVaccineType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(vaccinationData);

      // Notify patient about vaccination record
      await createNotification(
        userId: patientId,
        message: "Vaccination record created: $actualVaccineType vaccine has been administered",
      );

      return docRef.id;
    } catch (e) {
      print('Error creating vaccination record: $e');
      throw Exception('Failed to create vaccination record: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getPatientVaccinationRecords(
      String patientId) {
    return vaccinationRecordsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }

        return data;
      }).toList();
    });
  }

  Future<void> updateCallState({
    required String appointmentId,
    required String callState,
    required String callerType,
    required String callerName,
  }) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'callState': callState,
        'lastCallUpdate': FieldValue.serverTimestamp(),
        'callerType': callerType,
        'callerName': callerName,
      });

      // Get appointment details to notify the other party
      DocumentSnapshot appointmentDoc = await appointmentsCollection.doc(appointmentId).get();
      if (appointmentDoc.exists) {
        Map<String, dynamic> appointmentData = appointmentDoc.data() as Map<String, dynamic>;
        String patientId = appointmentData['patientId'];
        String? doctorId = appointmentData['doctorId'];
        
        // Determine who to notify based on caller type
        String notifyUserId = '';
        if (callerType == 'patient' && doctorId != null) {
          notifyUserId = doctorId;
        } else if (callerType == 'doctor') {
          notifyUserId = patientId;
        }

        if (notifyUserId.isNotEmpty) {
          if (callState == 'calling') {
            await createNotification(
              userId: notifyUserId,
              message: "Incoming call from $callerName for your appointment",
            );
          } else if (callState == 'ended') {
            await createNotification(
              userId: notifyUserId,
              message: "Call with $callerName has ended",
            );
          }
        }
      }
    } catch (e) {
      print('Error updating call state: $e');
      throw Exception('Failed to update call state: $e');
    }
  }

  Stream<Map<String, dynamic>?> getCallStateStream(String appointmentId) {
    return appointmentsCollection
        .doc(appointmentId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return {
          'callState': data['callState'] ?? 'idle',
          'callerType': data['callerType'],
          'callerName': data['callerName'],
          'lastCallUpdate': data['lastCallUpdate'],
        };
      }
      return null;
    });
  }

  Future<void> clearCallState(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'callState': 'idle',
        'lastCallUpdate': FieldValue.serverTimestamp(),
        'callerType': null,
        'callerName': null,
      });
    } catch (e) {
      print('Error clearing call state: $e');
      throw Exception('Failed to clear call state: $e');
    }
  }
}
