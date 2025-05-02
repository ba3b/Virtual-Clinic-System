import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String uid;

  DatabaseService({
    required this.uid,
  });

  final CollectionReference myCollection =
      FirebaseFirestore.instance.collection('Users');


  Future<void> createUserDocument(
      UserCredential? userCredential, String username, String phoneNumber, String address, String userType) async {
    if (userCredential != null && userCredential.user != null) {
      await myCollection.doc(uid).set({
        'email': userCredential.user!.uid,
        'username': username,
        'phoneNumber': phoneNumber,
        'address': address,
        'userType': userType,
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String userId) async {
    DocumentSnapshot<Object?> userSnapshot = await myCollection.doc(userId).get();
    if (userSnapshot.exists) {
      return userSnapshot as DocumentSnapshot<Map<String, dynamic>>;
    } else {
      throw Exception('Document does not exist or has unexpected data type.');
    }
  }

  Stream<QuerySnapshot<Object?>> get users {
    return myCollection.snapshots();
  }
}
