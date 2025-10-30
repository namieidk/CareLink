// ──────────────────────────────────────────────────────────────
// auth_service.dart - Improved Firebase Authentication
// ──────────────────────────────────────────────────────────────
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carelink/models/users.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  auth.User? get currentUser => _firebaseAuth.currentUser;
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ──────────────────────────────────────────────
  // PATIENT SIGN UP
  // ──────────────────────────────────────────────
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

      final user = UserFactories.createPatient(
        id: credential.user!.uid,
        email: email.trim(),
        phone: phone.trim(),
        password: password,
        fullName: fullName,
      );

      final data = user.toJson()
        ..['email_lower'] = email.trim().toLowerCase();

      await _firestore.collection('users').doc(user.id).set(data);

      if (fullName != null && fullName.isNotEmpty) {
        await credential.user!.updateDisplayName(fullName);
      }

      return {
        'success': true,
        'userId': user.id,
        'message': 'Patient account created successfully'
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // PATIENT SIGN IN
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> signInPatient({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        await _firebaseAuth.signOut();
        return {'success': false, 'error': 'User data not found'};
      }

      final data = doc.data()!;
      if (data['role'] != 'patient') {
        await _firebaseAuth.signOut();
        return {'success': false, 'error': 'Invalid credentials for patient'};
      }

      if (data['is_active'] == false) {
        await _firebaseAuth.signOut();
        return {'success': false, 'error': 'Account is deactivated'};
      }

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .update({'last_login': FieldValue.serverTimestamp()});
      return {
        'success': true,
        'userId': credential.user!.uid,
        'userData': data,
        'message': 'Login successful'
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // DOCTOR SIGN UP
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> signUpDoctor({
    required String doctorId,
    required String username,
    required String password,
    String? fullName,
  }) async {
    try {
      final doctorIdLower = doctorId.trim().toLowerCase();
      final usernameLower = username.trim().toLowerCase();

      // Check duplicates
      final existingDoctor = await _firestore
          .collection('users')
          .where('doctor_id', isEqualTo: doctorIdLower)
          .limit(1)
          .get();
      if (existingDoctor.docs.isNotEmpty) {
        return {'success': false, 'error': 'Doctor ID already exists'};
      }

      final existingUsername = await _firestore
          .collection('users')
          .where('username_lower', isEqualTo: usernameLower)
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get();
      if (existingUsername.docs.isNotEmpty) {
        return {'success': false, 'error': 'Username already taken'};
      }

      // Create temp email for Firebase Auth
      final tempEmail = '$doctorIdLower@carelink.temp';
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: tempEmail,
        password: password,
      );

      final user = UserFactories.createDoctor(
        id: credential.user!.uid,
        doctorId: doctorId.trim(),
        username: username.trim(),
        password: password,
        fullName: fullName,
      );

      final data = user.toJson()
        ..['username_lower'] = usernameLower
        ..['doctor_id'] = doctorIdLower;

      await _firestore.collection('users').doc(user.id).set(data);

      if (fullName != null && fullName.isNotEmpty) {
        await credential.user!.updateDisplayName(fullName);
      }

      return {
        'success': true,
        'userId': user.id,
        'message': 'Doctor account created successfully'
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // DOCTOR SIGN IN
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> signInDoctor({
    required String identifier,
    required String password,
  }) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('doctor_id', isEqualTo: identifier.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        query = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .where('username_lower', isEqualTo: identifier.trim().toLowerCase())
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) {
        return {'success': false, 'error': 'Invalid doctor ID or username'};
      }

      final data = query.docs.first.data() as Map<String, dynamic>;
      final tempEmail =
          '${data['doctor_id'].toString().toLowerCase()}@carelink.temp';

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: tempEmail,
        password: password,
      );

      if (data['is_active'] == false) {
        await _firebaseAuth.signOut();
        return {'success': false, 'error': 'Account is deactivated'};
      }

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .update({'last_login': FieldValue.serverTimestamp()});
      return {
        'success': true,
        'userId': credential.user!.uid,
        'userData': data,
        'message': 'Login successful'
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // CAREGIVER SIGN UP
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> signUpCaregiver({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    try {
      final usernameLower = username.trim().toLowerCase();

      final existing = await _firestore
          .collection('users')
          .where('username_lower', isEqualTo: usernameLower)
          .where('role', isEqualTo: 'caregiver')
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return {'success': false, 'error': 'Username already taken'};
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = UserFactories.createCaregiver(
        id: credential.user!.uid,
        email: email.trim(),
        username: username.trim(),
        password: password,
        fullName: fullName,
      );

      final data = user.toJson()
        ..['username_lower'] = usernameLower
        ..['email_lower'] = email.trim().toLowerCase();

      await _firestore.collection('users').doc(user.id).set(data);

      if (fullName != null && fullName.isNotEmpty) {
        await credential.user!.updateDisplayName(fullName);
      }

      return {
        'success': true,
        'userId': user.id,
        'message': 'Caregiver account created successfully'
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // CAREGIVER SIGN IN
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> signInCaregiver({
    required String username,
    required String password,
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'caregiver')
          .where('username_lower', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {'success': false, 'error': 'Invalid username'};
      }

      final data = query.docs.first.data() as Map<String, dynamic>;
      final email = data['email'];

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (data['is_active'] == false) {
        await _firebaseAuth.signOut();
        return {'success': false, 'error': 'Account is deactivated'};
      }

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .update({'last_login': FieldValue.serverTimestamp()});
      return {
        'success': true,
        'userId': credential.user!.uid,
        'userData': data,
        'message': 'Login successful'
      };
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // OTHER METHODS
  // ──────────────────────────────────────────────
  Future<void> signOut() async => await _firebaseAuth.signOut();

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return {'success': true, 'message': 'Password reset email sent'};
    } on auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<bool> updateUserData(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        return {'success': false, 'error': 'No user logged in'};
      }

      await _firestore.collection('users').doc(userId).delete();
      await currentUser!.delete();
      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to delete account: $e'};
    }
  }

  String _getAuthErrorMessage(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password too weak.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Wrong password.';
      default:
        return 'Auth error: ${e.message}';
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
