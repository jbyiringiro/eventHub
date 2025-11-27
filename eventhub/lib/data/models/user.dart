class User {
  final String id;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final String? firebaseUid; // Add Firebase UID
  final String? phone; // Add phone field

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
    required this.createdAt,
    this.firebaseUid, // Add this parameter
    this.phone, // Add this parameter
  });

  // Add a factory constructor for empty user
  factory User.empty() {
    return User(id: '', email: '', name: '', createdAt: DateTime.now());
  }

  // Create user from Firebase User - ADD THIS METHOD
  factory User.fromFirebaseUser(dynamic firebaseUser, {String? phone}) {
    // Extract name from displayName or email
    String userName = 'User';
    if (firebaseUser.displayName != null &&
        firebaseUser.displayName!.isNotEmpty) {
      userName = firebaseUser.displayName!;
    } else if (firebaseUser.email != null) {
      // Extract name from email (before @)
      userName = firebaseUser.email!
          .split('@')[0]
          .replaceAll('.', ' ')
          .replaceAll('_', ' ');
      // Capitalize first letter of each word
      userName = userName
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word,
          )
          .join(' ');
    }

    return User(
      id: firebaseUser.uid, // Use Firebase UID as ID
      email: firebaseUser.email ?? '',
      name: userName,
      profilePictureUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      firebaseUid: firebaseUser.uid,
      phone: phone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'firebaseUid': firebaseUid, // Add this
      'phone': phone, // Add this
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      firebaseUid: json['firebaseUid'], // Add this
      phone: json['phone'], // Add this
    );
  }

  // Add copyWith method - ADD THIS METHOD
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePictureUrl,
    DateTime? createdAt,
    String? firebaseUid,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      phone: phone ?? this.phone,
    );
  }
}
