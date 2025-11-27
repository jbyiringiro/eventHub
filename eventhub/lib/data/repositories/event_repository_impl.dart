import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/firestore_event_datasource.dart';
import '../models/event_model.dart';

/// Implementation of event repository
class EventRepositoryImpl implements EventRepository {
  final FirestoreEventDatasource _firestoreEventDatasource = FirestoreEventDatasource();

  @override
  Future<void> createEvent(EventEntity event) async {
    final eventModel = EventModel.fromEntity(event);
    await _firestoreEventDatasource.createEvent(eventModel);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _firestoreEventDatasource.deleteEvent(id);
  }

  @override
  Future<List<EventEntity>> getAllEvents() async {
    final events = await _firestoreEventDatasource.getAllEvents();
    return events;
  }

  @override
  Future<EventEntity?> getEventById(String id) async {
    final event = await _firestoreEventDatasource.getEventById(id);
    return event;
  }

  @override
  Future<List<EventEntity>> getUserEvents(String userId) async {
    final events = await _firestoreEventDatasource.getUserEvents(userId);
    return events;
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    final eventModel = EventModel.fromEntity(event);
    await _firestoreEventDatasource.updateEvent(eventModel);
  }
}
