import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user from FirebaseAuth
  User? get currentUser => _auth.currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
    required String userType,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Create user model
      final UserModel userModel = UserModel(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        userType: userType,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toJson());

      // If user is a patient, create a patient record
      if (userType == 'patient') {
        await _firestore.collection('patients').doc(userCredential.user!.uid).set({
          'patientId': userCredential.user!.uid,
          'medicalHistory': ''
        });
      }
      
      // If user is a doctor, create a doctor record
      else if (userType == 'doctor') {
        await _firestore.collection('doctors').doc(userCredential.user!.uid).set({
          'doctorId': userCredential.user!.uid,
          'specialty': ''
        });
      }
      
      // If user is a staff, create a staff record
      else if (userType == 'staff') {
        await _firestore.collection('staff').doc(userCredential.user!.uid).set({
          'staffId': userCredential.user!.uid
        });
      }

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      // Get user data from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      if (currentUser == null) {
        return null;
      }

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;

      await _firestore.collection('users').doc(userId).update(updateData);

      // Get updated user data
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}