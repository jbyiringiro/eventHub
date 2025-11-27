import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/user.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _usersKey = 'users';
  static const String _eventsKey = 'events';
  static const String _currentUserKey = 'currentUser';
  static const String _appDataKey = 'appData';

  // User management
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    users[user.id] = user;
    
    final usersJson = users.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_usersKey, json.encode(usersJson));
    debugPrint('💾 User saved: ${user.name}');
  }

  Future<Map<String, User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);
    
    if (usersString == null) return {};
    
    try {
      final usersJson = json.decode(usersString) as Map<String, dynamic>;
      return usersJson.map((key, value) => MapEntry(key, User.fromJson(value)));
    } catch (e) {
      debugPrint('❌ Error parsing users: $e');
      return {};
    }
  }

  Future<User?> getUser(String id) async {
    final users = await getUsers();
    return users[id];
  }

  // Event management
  Future<void> saveEvent(Event event) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    
    if (index != -1) {
      events[index] = event;
    } else {
      events.add(event);
    }
    
    await _saveEvents(events);
    debugPrint('💾 Event saved: ${event.title}');
  }

  Future<List<Event>> getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKey);
    
    if (eventsString == null) return [];
    
    try {
      final List<dynamic> eventsJson = json.decode(eventsString);
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error parsing events: $e');
      return [];
    }
  }

  Future<void> saveEvents(List<Event> events) async {
    await _saveEvents(events);
    debugPrint('💾 ${events.length} events saved');
  }

  Future<void> _saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((event) => event.toJson()).toList();
    await prefs.setString(_eventsKey, json.encode(eventsJson));
  }

  Future<void> deleteEvent(String eventId) async {
    final events = await getAllEvents();
    events.removeWhere((event) => event.id == eventId);
    await _saveEvents(events);
    debugPrint('🗑️ Event deleted: $eventId');
  }

  // Current user session
  Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));
    debugPrint('👤 Current user set: ${user.name}');
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);
    
    if (userString == null) return null;
    
    try {
      return User.fromJson(json.decode(userString));
    } catch (e) {
      debugPrint('❌ Error parsing current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    debugPrint('👤 User logged out');
  }

  // App data management
  Future<void> saveAppData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appDataKey, json.encode(data));
  }

  Future<Map<String, dynamic>> getAppData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_appDataKey);
    
    if (dataString == null) return {};
    
    try {
      return json.decode(dataString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  // Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('🧹 All data cleared');
  }
}