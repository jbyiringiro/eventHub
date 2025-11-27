import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';

/// Base class for event states
abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EventInitial extends EventState {
  const EventInitial();
}

/// Loading state
class EventLoading extends EventState {
  const EventLoading();
}

/// Events loaded state
class EventLoaded extends EventState {
  final List<EventEntity> events;

  const EventLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

/// Single event loaded state
class SingleEventLoaded extends EventState {
  final EventEntity event;

  const SingleEventLoaded({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Event operation success state
class EventOperationSuccess extends EventState {
  final String message;

  const EventOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class EventError extends EventState {
  final String message;

  const EventError({required this.message});

  @override
  List<Object?> get props => [message];
}
