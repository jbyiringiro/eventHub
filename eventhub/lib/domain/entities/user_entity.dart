import 'package:equatable/equatable.dart';

/// User entity representing domain model
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final String? phone;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
    this.phone,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, profilePictureUrl, phone, createdAt];
}