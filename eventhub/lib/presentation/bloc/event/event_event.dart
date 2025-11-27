import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';

/// Base class for event events
abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all events
class LoadEvents extends EventEvent {
  const LoadEvents();
}

/// Event to load user events
class LoadUserEvents extends EventEvent {
  final String userId;

  const LoadUserEvents({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to create event
class CreateEvent extends EventEvent {
  final EventEntity event;

  const CreateEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Event to update event
class UpdateEvent extends EventEvent {
  final EventEntity event;

  const UpdateEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Event to delete event
class DeleteEvent extends EventEvent {
  final String eventId;

  const DeleteEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Event to load single event by ID
class LoadEventById extends EventEvent {
  final String eventId;

  const LoadEventById({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
