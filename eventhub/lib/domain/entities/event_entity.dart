import 'package:equatable/equatable.dart';

/// Event entity representing domain model
class EventEntity extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final String? time;
  final String location;
  final String description;
  final String image;
  final int attendees;
  final String organizer;
  final String? category;
  final String? status;
  final String? userId;
  final DateTime createdAt;
  final List<String> attendeeIds; // Track user IDs who RSVP'd
  final int? maxAttendees; // Maximum number of attendees allowed

  const EventEntity({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.location,
    required this.description,
    required this.image,
    required this.attendees,
    required this.organizer,
    this.category,
    this.status,
    this.userId,
    required this.createdAt,
    this.attendeeIds = const [],
    this.maxAttendees,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        time,
        location,
        description,
        image,
        attendees,
        organizer,
        category,
        status,
        userId,
        createdAt,
        attendeeIds,
        maxAttendees,
      ];
}