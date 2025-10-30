// ──────────────────────────────────────────────────────────────
// auth_service.dart - Complete Firebase Authentication
// ──────────────────────────────────────────────────────────────
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/users_model.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  auth.User? get currentUser => _firebaseAuth.currentUser;
  
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>> signUpPatient({
    required String email,
    required String phone,
    required String password,
    String? fullName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String userId = credential.user!.uid;

      // 2. Store additional data in Firestore
      await _firestore.collection('users').doc(userId).set({
        'role': 'patient',
        'email': email.trim(),
        'phone': phone.trim(),
        'emailLower': email.trim().toLowerCase(),
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // 3. Update display name
      if (fullName != null && fullName.isNotEmpty) {
        await credential.user!.updateDisplayName(fullName);
      }

      return {
        'success': true,
        'userId': userId,
        'message': 'Patient account created successfully',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // PATIENT SIGN IN
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signInPatient({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String userId = credential.user!.uid;

      // 2. Verify user is a patient
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        await _firebaseAuth.signOut();
        return {
          'success': false,
          'error': 'User data not found',
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userData['role'] != 'patient') {
        await _firebaseAuth.signOut();
        return {
          'success': false,
          'error': 'Invalid credentials for patient login',
        };
      }

      if (userData['isActive'] == false) {
        await _firebaseAuth.signOut();
        return {
          'success': false,
          'error': 'Account is deactivated',
        };
      }

      // 3. Update last login
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'userId': userId,
        'userData': userData,
        'message': 'Login successful',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // DOCTOR SIGN UP
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signUpDoctor({
    required String doctorId,
    required String username,
    required String password,
    String? fullName,
  }) async {
    try {
      // 1. Check if doctor ID already exists
      QuerySnapshot existingDoctorId = await _firestore
          .collection('users')
          .where('doctorIdLower', isEqualTo: doctorId.trim().toLowerCase())
          .limit(1)
          .get();

      if (existingDoctorId.docs.isNotEmpty) {
        return {
          'success': false,
          'error': 'Doctor ID already exists',
        };
      }

      // 2. Check if username already exists for doctors
      QuerySnapshot existingUsername = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('usernameLower', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (existingUsername.docs.isNotEmpty) {
        return {
          'success': false,
          'error': 'Username already taken',
        };
      }

      // 3. Create email from doctor ID (since Firebase Auth requires email)
      String tempEmail = '${doctorId.trim().toLowerCase()}@carelink.temp';

      // 4. Create user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: tempEmail,
        password: password,
      );

      String userId = credential.user!.uid;

      // 5. Store in Firestore
      await _firestore.collection('users').doc(userId).set({
        'role': 'doctor',
        'doctorId': doctorId.trim(),
        'doctorIdLower': doctorId.trim().toLowerCase(),
        'username': username.trim(),
        'usernameLower': username.trim().toLowerCase(),
        'tempEmail': tempEmail,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // 6. Update display name
      if (fullName != null && fullName.isNotEmpty) {
        await credential.user!.updateDisplayName(fullName);
      }

      return {
        'success': true,
        'userId': userId,
        'message': 'Doctor account created successfully',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // DOCTOR SIGN IN
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signInDoctor({
    required String identifier, // Can be doctorId or username
    required String password,
  }) async {
    try {
      // 1. Find doctor by ID or username
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('doctorIdLower', isEqualTo: identifier.trim().toLowerCase())
          .limit(1)
          .get();

      // If not found by doctor ID, try username
      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .where('usernameLower', isEqualTo: identifier.trim().toLowerCase())
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        return {
          'success': false,
          'error': 'Invalid doctor ID or username',
        };
      }

      // 2. Get user data
      Map<String, dynamic> userData = query.docs.first.data() as Map<String, dynamic>;
      String tempEmail = userData['tempEmail'];

      // 3. Sign in with Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: tempEmail,
        password: password,
      );

      String userId = credential.user!.uid;

      // 4. Check if active
      if (userData['isActive'] == false) {
        await _firebaseAuth.signOut();
        return {
          'success': false,
          'error': 'Account is deactivated',
        };
      }

      // 5. Update last login
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'userId': userId,
        'userData': userData,
        'message': 'Login successful',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // CAREGIVER SIGN UP
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signUpCaregiver({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    try {
      // 1. Check if username already exists for caregivers
      QuerySnapshot existingUsername = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'caregiver')
          .where('usernameLower', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (existingUsername.docs.isNotEmpty) {
        return {
          'success': false,
          'error': 'Username already taken',
        };
      }

      // 2. Create user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String userId = credential.user!.uid;

      // 3. Store in Firestore
      await _firestore.collection('users').doc(userId).set({
        'role': 'caregiver',
        'email': email.trim(),
        'emailLower': email.trim().toLowerCase(),
        'username': username.trim(),
        'usernameLower': username.trim().toLowerCase(),
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // 4. Update display name
      if (fullName != null && fullName.isNotEmpty) {
        await credential.user!.updateDisplayName(fullName);
      }

      return {
        'success': true,
        'userId': userId,
        'message': 'Caregiver account created successfully',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // CAREGIVER SIGN IN
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signInCaregiver({
    required String username,
    required String password,
  }) async {
    try {
      // 1. Find caregiver by username
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'caregiver')
          .where('usernameLower', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {
          'success': false,
          'error': 'Invalid username',
        };
      }

      // 2. Get user data
      Map<String, dynamic> userData = query.docs.first.data() as Map<String, dynamic>;
      String email = userData['email'];

      // 3. Sign in with Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = credential.user!.uid;

      // 4. Check if active
      if (userData['isActive'] == false) {
        await _firebaseAuth.signOut();
        return {
          'success': false,
          'error': 'Account is deactivated',
        };
      }

      // 5. Update last login
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'userId': userId,
        'userData': userData,
        'message': 'Login successful',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // SIGN OUT
  // ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // ──────────────────────────────────────────────────────────────
  // RESET PASSWORD
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // GET USER DATA
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // UPDATE USER DATA
  // ──────────────────────────────────────────────────────────────
  Future<bool> updateUserData(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // DELETE ACCOUNT
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      String? userId = currentUser?.uid;
      
      if (userId == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      // Delete Firestore data
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete auth account
      await currentUser!.delete();

      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete account: $e',
      };
    }
  }

  // ──────────────────────────────────────────────────────────────
  // ERROR MESSAGE HELPER
  // ──────────────────────────────────────────────────────────────
  String _getAuthErrorMessage(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

// ──────────────────────────────────────────────────────────────
// USAGE EXAMPLE
// ──────────────────────────────────────────────────────────────
/*
void main() async {
  final authService = AuthService();

  // PATIENT SIGN UP
  var result = await authService.signUpPatient(
    email: 'patient@test.com',
    phone: '+1234567890',
    password: 'password123',
    fullName: 'John Doe',
  );
  
  if (result['success']) {
    print('Success: ${result['message']}');
    print('User ID: ${result['userId']}');
  } else {
    print('Error: ${result['error']}');
  }

  // PATIENT SIGN IN
  var loginResult = await authService.signInPatient(
    email: 'patient@test.com',
    password: 'password123',
  );

  // DOCTOR SIGN UP
  var docResult = await authService.signUpDoctor(
    doctorId: 'DR12345',
    username: 'dr_john',
    password: 'password123',
    fullName: 'Dr. John Smith',
  );

  // DOCTOR SIGN IN
  var docLogin = await authService.signInDoctor(
    identifier: 'DR12345', // or 'dr_john'
    password: 'password123',
  );

  // CAREGIVER SIGN UP
  var careResult = await authService.signUpCaregiver(
    email: 'caregiver@test.com',
    username: 'caregiver_jane',
    password: 'password123',
    fullName: 'Jane Doe',
  );

  // CAREGIVER SIGN IN
  var careLogin = await authService.signInCaregiver(
    username: 'caregiver_jane',
    password: 'password123',
  );

  // SIGN OUT
  await authService.signOut();
}
*/