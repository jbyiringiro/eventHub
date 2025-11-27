import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String usersCollection = 'users';

  // Create user profile after registration
  Future<void> createUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'profileImageUrl': '',
        'bio': '',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'attendingEvents': [],
        'createdEventsCount': 0,
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user profile (real-time)
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    try {
      return _firestore
          .collection(usersCollection)
          .doc(userId)
          .snapshots()
          .map((doc) => doc.data());
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? profileImageUrl,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'bio': bio,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Add event to user's attending list
  Future<void> addAttendingEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'attendingEvents': FieldValue.arrayUnion([eventId]),
      });
    } catch (e) {
      throw Exception('Failed to add attending event: $e');
    }
  }

  // Remove event from user's attending list
  Future<void> removeAttendingEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'attendingEvents': FieldValue.arrayRemove([eventId]),
      });
    } catch (e) {
      throw Exception('Failed to remove attending event: $e');
    }
  }

  // Get user's attending events (real-time)
  Stream<List<String>> getUserAttendingEvents(String userId) {
    try {
      return _firestore.collection(usersCollection).doc(userId).snapshots().map(
        (doc) {
          List<String> events = [];
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            events = List<String>.from(data['attendingEvents'] ?? []);
          }
          return events;
        },
      );
    } catch (e) {
      throw Exception('Failed to get attending events: $e');
    }
  }

  // Increment created events count
  Future<void> incrementCreatedEventsCount(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'createdEventsCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment events count: $e');
    }
  }

  // Decrement created events count
  Future<void> decrementCreatedEventsCount(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'createdEventsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to decrement events count: $e');
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check user profile: $e');
    }
  }
}
