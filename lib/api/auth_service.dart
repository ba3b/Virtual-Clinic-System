import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
    required String userType,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      final UserModel userModel = UserModel(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        userType: userType,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toJson());

      if (userType == 'patient') {
        await _firestore.collection('patients').doc(userCredential.user!.uid).set({
          'patientId': userCredential.user!.uid,
          'medicalHistory': ''
        });
      } else if (userType == 'doctor') {
        await _firestore.collection('doctors').doc(userCredential.user!.uid).set({
          'doctorId': userCredential.user!.uid,
          'specialty': ''
        });
      } else if (userType == 'staff') {
        await _firestore.collection('staff').doc(userCredential.user!.uid).set({
          'staffId': userCredential.user!.uid
        });
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

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

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

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