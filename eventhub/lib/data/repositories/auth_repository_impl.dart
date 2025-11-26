import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firestore_user_datasource.dart';
import '../datasources/google_auth_datasource.dart';
import '../models/user_model.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreUserDatasource _firestoreUserDatasource = FirestoreUserDatasource();
  final GoogleAuthDatasource _googleAuthDatasource = GoogleAuthDatasource();

  @override
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) return null;
      
      // Get user data from Firestore
      final userModel = await _firestoreUserDatasource.getUser(userCredential.user!.uid);
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> registerWithEmailAndPassword(
      String email, String password, String name, String phone) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return null;

      // Create user in Firestore
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestoreUserDatasource.createUser(userModel);
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final user = await _googleAuthDatasource.signInWithGoogle();
      
      if (user == null) return null;

      // Check if user exists in Firestore
      UserModel? userModel = await _firestoreUserDatasource.getUser(user.uid);

      // If not, create new user
      if (userModel == null) {
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          profilePictureUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestoreUserDatasource.createUser(userModel);
      }

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleAuthDatasource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final userModel = await _firestoreUserDatasource.getUser(user.uid);
    return userModel;
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
