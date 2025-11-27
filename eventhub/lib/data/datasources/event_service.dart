import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event.dart';
import './imagekit_service.dart';
import './local_storage_service.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final LocalStorageService _storageService = LocalStorageService();

  // Initialize with mock data if no events exist
  Future<void> initializeMockData() async {
    final existingEvents = await _storageService.getAllEvents();
    debugPrint('🔄 EventService: Checking if mock data needed. Current events: ${existingEvents.length}');
    if (existingEvents.isEmpty) {
      debugPrint('🎯 EventService: Initializing with ${mockEvents.length} mock events');
      await _storageService.saveEvents(mockEvents);
      debugPrint('✅ EventService: Mock events saved to storage');
    }
  }

  static final List<Event> mockEvents = [
    Event(
      id: "1",
      title: "Campus Clean-Up Day",
      date: DateTime(2024, 2, 15, 9, 0),
      location: "University Main Campus",
      description: "Join us for a day of giving back to our campus! We'll be cleaning up various areas and planting new trees.",
      image: "https://picsum.photos/400/300?random=1",
      attendees: 45,
      organizer: "Green Campus Initiative",
      category: "Community",
      status: "Upcoming",
      userId: "org1",
      createdAt: DateTime(2024, 1, 1),
    ),
    Event(
      id: "2",
      title: "Tech Entrepreneurship Workshop",
      date: DateTime(2024, 2, 20, 14, 0),
      location: "Computer Science Building, Room 101",
      description: "Learn how to turn your tech ideas into viable businesses from successful local entrepreneurs.",
      image: "https://picsum.photos/400/300?random=2",
      attendees: 32,
      organizer: "Innovation Hub",
      category: "Workshop",
      status: "Upcoming",
      userId: "org2",
      createdAt: DateTime(2024, 1, 5),
    ),
    Event(
      id: "3",
      title: "Community Health Fair",
      date: DateTime(2024, 2, 25, 10, 0),
      location: "Community Center",
      description: "Free health screenings, consultations, and wellness workshops for the whole family.",
      image: "https://picsum.photos/400/300?random=3",
      attendees: 28,
      organizer: "Health & Wellness NGO",
      category: "Community",
      status: "Upcoming",
      userId: "org3",
      createdAt: DateTime(2024, 1, 10),
    ),
  ];

  // Get all events
  Future<List<Event>> getEvents() async {
    final events = await _storageService.getAllEvents();
    debugPrint('📅 EventService: Loaded ${events.length} events from storage');
    if (events.isEmpty) {
      debugPrint('⚠️ EventService: No events found, initializing mock data');
      await initializeMockData();
      return await _storageService.getAllEvents();
    }
    return events;
  }

  // Get event by ID
  Future<Event?> getEventById(String id) async {
    final events = await getEvents();
    try {
      return events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new event with ImageKit.io image upload
  Future<Event> createEvent({
    required String title,
    required DateTime date,
    required String location,
    required String description,
    required XFile? imageFile,
    required String organizer,
    required String userId,
    String? category,
  }) async {
    String imageUrl = '';
    
    // Upload image to ImageKit.io if provided
    if (imageFile != null) {
      try {
        final response = await ImageKitService.uploadEventImage(imageFile);
        imageUrl = response.url;
      } catch (e) {
        debugPrint('Failed to upload image: $e');
        // Use a placeholder image if upload fails
        imageUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
      }
    } else {
      // Use random placeholder if no image
      imageUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    }

    final newEvent = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
      location: location,
      description: description,
      image: imageUrl,
      attendees: 0,
      organizer: organizer,
      category: category,
      status: 'Upcoming',
      userId: userId,
      createdAt: DateTime.now(),
      attendeesList: [],
    );

    await _storageService.saveEvent(newEvent);
    return newEvent;
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    await _storageService.saveEvent(event);
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    await _storageService.deleteEvent(eventId);
  }

  // Add attendee to event
  Future<void> addAttendee(String eventId, String userId) async {
    final event = await getEventById(eventId);
    if (event != null) {
      final attendeesList = List<String>.from(event.attendeesList ?? []);
      if (!attendeesList.contains(userId)) {
        attendeesList.add(userId);
        final updatedEvent = event.copyWith(
          attendees: event.attendees + 1,
          attendeesList: attendeesList,
        );
        await updateEvent(updatedEvent);
      }
    }
  }

  // Remove attendee from event
  Future<void> removeAttendee(String eventId, String userId) async {
    final event = await getEventById(eventId);
    if (event != null) {
      final attendeesList = List<String>.from(event.attendeesList ?? []);
      attendeesList.remove(userId);
      final updatedEvent = event.copyWith(
        attendees: event.attendees > 0 ? event.attendees - 1 : 0,
        attendeesList: attendeesList,
      );
      await updateEvent(updatedEvent);
    }
  }

  // Check if user is attending event
  Future<bool> isUserAttending(String eventId, String userId) async {
    final event = await getEventById(eventId);
    if (event != null) {
      return event.attendeesList?.contains(userId) ?? false;
    }
    return false;
  }

  // Get events by organizer
  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    final events = await getEvents();
    return events.where((event) => event.userId == organizerId).toList();
  }

  // Get upcoming events
  Future<List<Event>> getUpcomingEvents() async {
    final events = await getEvents();
    final now = DateTime.now();
    final upcoming = events
        .where((event) => event.date.isAfter(now))
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    debugPrint('🚀 EventService: Found ${upcoming.length} upcoming events');
    return upcoming;
  }

  // Get popular events (most attendees)
  Future<List<Event>> getPopularEvents() async {
    final events = await getEvents();
    return events
        .toList()
        ..sort((a, b) => b.attendees.compareTo(a.attendees));
  }

  // Search events
  Future<List<Event>> searchEvents(String query) async {
    final events = await getEvents();
    final lowercaseQuery = query.toLowerCase();
    
    return events.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
             event.location.toLowerCase().contains(lowercaseQuery) ||
             event.description.toLowerCase().contains(lowercaseQuery) ||
             (event.category?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get events by category
  Future<List<Event>> getEventsByCategory(String category) async {
    final events = await getEvents();
    return events
        .where((event) => event.category?.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Format date for display
  static String formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Format time for display
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get relative time (e.g., "in 2 days", "tomorrow")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'now';
      }
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else if (difference.inDays < 7) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'in $weeks week${weeks == 1 ? '' : 's'}';
    } else {
      return formatDate(date);
    }
  }
}