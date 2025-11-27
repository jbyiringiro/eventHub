import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

/// BLoC for event management
class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository eventRepository;

  EventBloc({required this.eventRepository}) : super(const EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadUserEvents>(_onLoadUserEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<LoadEventById>(_onLoadEventById);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final events = await eventRepository.getAllEvents();
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserEvents(
      LoadUserEvents event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final events = await eventRepository.getUserEvents(event.userId);
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onCreateEvent(CreateEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await eventRepository.createEvent(event.event);
      emit(const EventOperationSuccess(message: 'Event created successfully'));
      
      // Reload events
      final events = await eventRepository.getAllEvents();
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onUpdateEvent(UpdateEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await eventRepository.updateEvent(event.event);
      emit(const EventOperationSuccess(message: 'Event updated successfully'));
      
      // Reload events
      final events = await eventRepository.getAllEvents();
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onDeleteEvent(DeleteEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      await eventRepository.deleteEvent(event.eventId);
      emit(const EventOperationSuccess(message: 'Event deleted successfully'));
      
      // Reload events
      final events = await eventRepository.getAllEvents();
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onLoadEventById(
      LoadEventById event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    try {
      final eventEntity = await eventRepository.getEventById(event.eventId);
      
      if (eventEntity != null) {
        emit(SingleEventLoaded(event: eventEntity));
      } else {
        emit(const EventError(message: 'Event not found'));
      }
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }
}
