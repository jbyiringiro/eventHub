import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Firestore datasource for user operations
class FirestoreUserDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  /// Create user in Firestore
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(_collectionName)
        .doc(user.id)
        .set(user.toFirestore());
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(_collectionName).doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(_collectionName)
        .doc(user.id)
        .update(user.toFirestore());
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collectionName).doc(userId).delete();
  }
}
