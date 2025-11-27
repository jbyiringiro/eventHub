import '../entities/event_entity.dart';

/// Event repository interface
abstract class EventRepository {
  Future<List<EventEntity>> getAllEvents();
  Future<EventEntity?> getEventById(String id);
  Future<void> createEvent(EventEntity event);
  Future<void> updateEvent(EventEntity event);
  Future<void> deleteEvent(String id);
  Future<List<EventEntity>> getUserEvents(String userId);
}
