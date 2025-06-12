import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserId? _userFromFirebaseUser(User? user) {
    return user != null ? UserId(uid: user.uid) : null;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<User?> register(
    String fullName, 
    String email, 
    String password, 
    String phoneNumber, 
    String address, 
    String userType,
    String nationalId,
    String gender,
    DateTime dateOfBirth,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      
      if (user != null) {
        await DatabaseService(uid: user.uid).createUserDocument(
          result, 
          fullName, 
          phoneNumber, 
          address, 
          userType,
          nationalId,
          gender,
          dateOfBirth,
        );
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return;
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Invalid or expired code. Please try again.';
    }
  }

  Future<String?> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Failed to reset password. Please try again.';
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'expired-action-code':
        return 'The verification code has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'The verification code is invalid. Please check and try again.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  User? get currentUser => _auth.currentUser;

  UserId? get currentUserId => _userFromFirebaseUser(_auth.currentUser);
  
  Stream<UserId?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }
  
  Future<UserModel?> getCurrentUserModel() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        return await DatabaseService(uid: user.uid).getUserDetails(user.uid);
      } catch (e) {
        print("Error getting user model: $e");
        return null;
      }
    }
    return null;
  }
  
  Stream<UserModel?> getCurrentUserModelStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return DatabaseService(uid: user.uid).getUserStream(user.uid);
    }
    return Stream.value(null);
  }
}