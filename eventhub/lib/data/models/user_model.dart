import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User data model for Firestore
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.profilePictureUrl,
    super.phone,
    required super.createdAt,
  });

  /// Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      phone: data['phone'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      profilePictureUrl: entity.profilePictureUrl,
      phone: entity.phone,
      createdAt: entity.createdAt,
    );
  }
}
