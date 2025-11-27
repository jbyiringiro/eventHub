
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import 'local_storage_service.dart';
import 'firebase_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final LocalStorageService _storageService = LocalStorageService();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();


  // Use Firebase auth state changes

   Stream<User?> get authStateChanges => _firebaseAuth.user;

  // Get current user (prefer Firebase, fallback to local)
  
   Future<User?> get currentUser async {
    final firebaseUser = await _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return firebaseUser;
    }
    return await _storageService.getCurrentUser();
  }

  // Sign up with email and password - USE FIREBASE

   Future<User> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      debugPrint('🔄 Attempting Firebase registration for: $email');
      
      // Use Firebase registration
      final user = await _firebaseAuth.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      
      debugPrint('✅ Firebase registration successful for: $email');
      return user;
      
    } catch (e) {
      debugPrint('❌ Firebase registration failed: $e');
      
      // Fallback to local storage if Firebase fails
      debugPrint('🔄 Falling back to local storage registration...');
      
      final users = await _storageService.getUsers();
      final existingUser = users.values.firstWhere(
        (user) => user.email == email,
        orElse: () => User.empty(),
      );

      if (existingUser.id.isNotEmpty) {
        throw Exception('Account already exists for that email.');
      }

      // Create new user in local storage only
        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: '$firstName $lastName',
          profilePictureUrl: null,
          createdAt: DateTime.now(),
          phone: phone,
      );

      await _storageService.saveUser(newUser);
      await _storageService.setCurrentUser(newUser);

      debugPrint('✅ Local storage registration successful for: $email');
      return newUser;
    }
  }

  // Login with email and password - USE FIREBASE
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔄 Attempting Firebase login for: $email');
      
      // Use Firebase login
      final user = await _firebaseAuth.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ Firebase login successful for: $email');
      return user;
      
    } catch (e) {
      debugPrint('❌ Firebase login failed: $e');
      
      // Fallback to local storage if Firebase fails
      debugPrint('🔄 Falling back to local storage login...');
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please enter email and password');
      }

      final users = await _storageService.getUsers();
      final user = users.values.firstWhere(
        (user) => user.email == email,
        orElse: () => User.empty(),
      );

      if (user.id.isEmpty) {
        throw Exception('User not found.');
      }

      // Simple password check (in real app, use proper hashing)
      if (password.length < 6) {
        throw Exception('Invalid email or password.');
      }

      await _storageService.setCurrentUser(user);
      debugPrint('✅ Local storage login successful for: $email');
      return user;
    }
  }

  // Password reset - USE FIREBASE
  Future<void> resetPassword({required String email}) async {
    try {
      debugPrint('🔄 Attempting Firebase password reset for: $email');
      await _firebaseAuth.resetPassword(email: email);
      debugPrint('✅ Firebase password reset email sent to: $email');
    } catch (e) {
      debugPrint('❌ Firebase password reset failed: $e');
      // Fallback: just log for local users
      debugPrint('🔄 Using local storage fallback for password reset...');
      await Future.delayed(Duration(seconds: 1));
      debugPrint('📧 Password reset requested for: $email (local user)');
    }
  }
  // Logout - USE FIREBASE
  Future<void> logout() async {
    try {
      debugPrint('🔄 Attempting Firebase logout...');
      await _firebaseAuth.signOut();
      debugPrint('✅ Firebase logout successful');
    } catch (e) {
      debugPrint('❌ Firebase logout failed: $e');
      await _storageService.logout();
      debugPrint('✅ Local storage logout successful');
    }
  }

// Update user profile - USE FIREBASE
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? profilePictureUrl,
  }) async {
    try {
      debugPrint('🔄 Attempting Firebase profile update...');
      final user = await _firebaseAuth.updateProfile(
        name: name ?? '',
        profilePictureUrl: profilePictureUrl,
      );
      
      debugPrint('✅ Firebase profile update successful');
      return user;
    } catch (e) {
      debugPrint('❌ Firebase profile update failed: $e');
      // Fallback to local storage
      final user = await _storageService.getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final updatedUser = User(
        id: user.id,
        email: user.email,
        name: name ?? user.name,
        profilePictureUrl: profilePictureUrl ?? user.profilePictureUrl,
        createdAt: user.createdAt,
        firebaseUid: user.firebaseUid,
        phone: user.phone,
      );

      await _storageService.saveUser(updatedUser);
      
      final currentUser = await _storageService.getCurrentUser();
      if (currentUser?.id == userId) {
        await _storageService.setCurrentUser(updatedUser);
      }

      debugPrint('✅ Local storage profile update successful');
      return updatedUser;
    }
  }

  // Delete account
  Future<void> deleteAccount(String userId) async {
    try {
      // Try to delete Firebase user first
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        debugPrint('✅ Firebase user deleted');
      }
    } catch (e) {
      debugPrint('❌ Could not delete Firebase user: $e');
    }
    
    await _storageService.logout();
    debugPrint('✅ Local storage cleared');
  }
}
