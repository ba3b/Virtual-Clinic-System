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

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Failed to send password reset email: ${e.message}");
      rethrow;
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