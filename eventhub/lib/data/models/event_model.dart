import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event_entity.dart';

/// Event data model for Firestore
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.date,
    super.time,
    required super.location,
    required super.description,
    required super.image,
    required super.attendees,
    required super.organizer,
    super.category,
    super.status,
    super.userId,
    required super.createdAt,
    super.attendeeIds = const [],
    super.maxAttendees,
  });

  /// Convert from Firestore document
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'],
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      attendees: data['attendees'] ?? 0,
      organizer: data['organizer'] ?? '',
      category: data['category'],
      status: data['status'],
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      attendeeIds: data['attendeeIds'] != null ? List<String>.from(data['attendeeIds']) : [],
      maxAttendees: data['maxAttendees'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'description': description,
      'image': image,
      'attendees': attendees,
      'organizer': organizer,
      'category': category,
      'status': status,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'attendeeIds': attendeeIds,
      'maxAttendees': maxAttendees,
    };
  }

  /// Convert from entity
  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      time: entity.time,
      location: entity.location,
      description: entity.description,
      image: entity.image,
      attendees: entity.attendees,
      organizer: entity.organizer,
      category: entity.category,
      status: entity.status,
      userId: entity.userId,
      createdAt: entity.createdAt,
      attendeeIds: entity.attendeeIds,
      maxAttendees: entity.maxAttendees,
    );
  }
}
