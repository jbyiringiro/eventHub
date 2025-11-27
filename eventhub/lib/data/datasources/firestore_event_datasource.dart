import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

/// Firestore datasource for event operations
class FirestoreEventDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'events';

  /// Create event in Firestore
  Future<void> createEvent(EventModel event) async {
    await _firestore.collection(_collectionName).doc(event.id).set(event.toFirestore());
  }

  /// Get all events
  Future<List<EventModel>> getAllEvents() async {
    final snapshot = await _firestore.collection(_collectionName).orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  /// Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    final doc = await _firestore.collection(_collectionName).doc(eventId).get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  /// Get events by user ID
  Future<List<EventModel>> getUserEvents(String userId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  /// Update event
  Future<void> updateEvent(EventModel event) async {
    await _firestore.collection(_collectionName).doc(event.id).update(event.toFirestore());
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collectionName).doc(eventId).delete();
  }
}
