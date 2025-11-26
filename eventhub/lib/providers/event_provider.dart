import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event e) {
    _events.add(e);
    notifyListeners();
  }

  void removeEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Event? getById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
