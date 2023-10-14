import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class CustomUser {
  final String uid;
  final String displayName;
  final String email;
  final String? bloodGroup;
  final String phoneNumber;

  CustomUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.bloodGroup,
    required this.phoneNumber,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String bloodGroup,
    String phoneNumber,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's profile with additional information
      await userCredential.user!.updateDisplayName(name);

      // Store additional user information in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'bloodGroup': bloodGroup,
        'phoneNumber': phoneNumber,
      });

      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<CustomUser?> getCurrentUser() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        final phoneNumber = userData['phoneNumber'];
        final bloodGroup = userData['bloodGroup'];

        final customUser = CustomUser(
          uid: user.uid,
          displayName: user.displayName ?? '',
          email: user.email ?? '',
          bloodGroup: bloodGroup,
          phoneNumber: phoneNumber,
        );

        return customUser;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // Check if the user is logged in
  Future<User?> isUserLoggedIn() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Add other authentication methods like sign out, password reset, etc. as needed
}
