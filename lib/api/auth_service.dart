import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_clinic_system/api/firestore_service.dart';
import 'package:virtual_clinic_system/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserId? _userFromFirebaseUser(User? user) {
    return user != null ? UserId(uid: user.uid) : null;
  }

  Future<({User? user, String? error})> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return (user: user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _getErrorMessage(e.code));
    }
  }

  Future<({User? user, String? error})> register(
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
      
      return (user: user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _getErrorMessage(e.code));
    }
  }

  Future<User?> registerUserByStaff(
    String fullName,
    String email,
    String password,
    String phoneNumber,
    String address,
    String userType,
    String nationalId,
    String gender,
    DateTime dateOfBirth,
    String? specialty, 
  ) async {
    try {
      User? currentUser = _auth.currentUser;
      String? currentUserEmail = currentUser?.email;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? newUser = result.user;
      
      if (newUser != null) {
        await DatabaseService(uid: newUser.uid).createStaffManagedUserDocument(
          result,
          fullName,
          phoneNumber,
          address,
          userType,
          nationalId,
          gender,
          dateOfBirth,
          specialty,
        );
        
        await _auth.signOut();
        
        print('New user created successfully. Previous staff user email: $currentUserEmail');
        print('Staff user will need to sign in again to continue.');
      }
      
      return newUser;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.message}');
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
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
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorKey(e.code);
    } catch (e) {
      return 'error_unknown';
    }
  }

  Future<String?> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorKey(e.code);
    } catch (e) {
      return 'error_unknown';
    }
  }

  Future<String?> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorKey(e.code);
    } catch (e) {
      return 'error_unknown';
    }
  }

  /// Returns a translation key that screens can translate with
  /// `AppLocalizations.of(context).translate(key)`.
  String _getErrorKey(String code) {
    switch (code) {
      case 'user-not-found':
        return 'error_user_not_found';
      case 'wrong-password':
        return 'error_wrong_password';
      case 'invalid-email':
        return 'error_invalid_email_auth';
      case 'user-disabled':
        return 'error_user_disabled';
      case 'too-many-requests':
        return 'error_too_many_requests';
      case 'expired-action-code':
        return 'error_expired_action_code';
      case 'invalid-action-code':
        return 'error_invalid_action_code';
      case 'weak-password':
        return 'error_weak_password';
      case 'email-already-in-use':
        return 'error_email_in_use';
      case 'invalid-credential':
        return 'error_invalid_credential';
      default:
        return 'error_unknown';
    }
  }

  /// Legacy helper kept for backwards compatibility — prefers translation keys
  /// but falls back to the raw key string if not possible.
  String _getErrorMessage(String code) => _getErrorKey(code);

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