import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity?> registerWithEmailAndPassword(String email, String password, String name, String phone);
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> resetPassword(String email);
}
