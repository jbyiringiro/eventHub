import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import 'local_storage_service.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final LocalStorageService _storageService = LocalStorageService();

  // User stream that combines Firebase and local storage
  Stream<User?> get user {
    return _auth.authStateChanges().asyncMap((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        await _storageService.logout();
        return null;
      }
      
      // Try to get user from local storage first
      User? localUser = await _storageService.getCurrentUser();
      
      if (localUser != null && localUser.firebaseUid == firebaseUser.uid) {
        return localUser;
      }
      
      // Create new user from Firebase
      final newUser = User.fromFirebaseUser(firebaseUser);
      await _storageService.saveUser(newUser);
      await _storageService.setCurrentUser(newUser);
      
      return newUser;
    });
  }

  // Get current user
  Future<User?> get currentUser async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    final localUser = await _storageService.getCurrentUser();
    if (localUser != null && localUser.firebaseUid == firebaseUser.uid) {
      return localUser;
    }
    
    final newUser = User.fromFirebaseUser(firebaseUser);
    await _storageService.saveUser(newUser);
    await _storageService.setCurrentUser(newUser);
    
    return newUser;
  }

  // Get ID token for backend requests (keep for future use)
  Future<String?> getToken() async {
    if (_auth.currentUser != null) {
      return await _auth.currentUser!.getIdToken();
    }
    return null;
  }

  // Register with email and password - NO BACKEND CALL
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      debugPrint('🔄 Step 1: Creating user in Firebase Auth...');
      
      // 1. Create user in Firebase Auth ONLY
      firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Step 1: Firebase user created: ${userCredential.user!.uid}');

      // 2. Update display name in Firebase
      debugPrint('🔄 Step 2: Updating display name...');
      await userCredential.user!.updateDisplayName('$firstName $lastName');
      debugPrint('✅ Step 2: Display name updated');

      // 3. Create local user ONLY (NO BACKEND CALL)
      debugPrint('🔄 Step 3: Creating local user...');
      final user = User(
        id: userCredential.user!.uid,
        email: email,
        name: '$firstName $lastName',
        profilePictureUrl: null,
        createdAt: DateTime.now(),
        firebaseUid: userCredential.user!.uid,
        phone: phone,
      );
      
      await _storageService.saveUser(user);
      await _storageService.setCurrentUser(user);

      debugPrint('✅ Step 3: Local user created and saved');
      debugPrint('🎉 Registration completed successfully!');

      return user;
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      rethrow;
    }
  }

  // Login with email and password
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔄 Attempting Firebase login for: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Firebase login successful: ${userCredential.user!.uid}');

      // Get or create local user
      final user = User.fromFirebaseUser(userCredential.user!);
      await _storageService.saveUser(user);
      await _storageService.setCurrentUser(user);

      debugPrint('✅ Local user synchronized');
      return user;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _storageService.logout();
      debugPrint('✅ Signed out from Firebase and local storage');
    } catch (e) {
      rethrow;
    }
  }

  // Password reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
    } catch (e) {
      rethrow;
    }
  }

  // Update profile in Firebase
  Future<User> updateProfile({
    required String name,
    String? profilePictureUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Update Firebase profile
      await currentUser.updateDisplayName(name);
      if (profilePictureUrl != null) {
        await currentUser.updatePhotoURL(profilePictureUrl);
      }

      // Update local storage
      final localUser = await _storageService.getCurrentUser();
      if (localUser != null) {
        final updatedUser = localUser.copyWith(
          name: name,
          profilePictureUrl: profilePictureUrl,
        );
        await _storageService.saveUser(updatedUser);
        await _storageService.setCurrentUser(updatedUser);
        
        return updatedUser;
      }

      throw Exception('User not found in local storage');
    } catch (e) {
      rethrow;
    }
  }
}