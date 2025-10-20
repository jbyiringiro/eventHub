import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Event>> fetchEvents() async {
    // Replace with real endpoint
    final uri = Uri.parse('$baseUrl/events');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => Event.fromMap(e)).toList();
    } else {
      throw Exception('Failed to fetch events');
    }
  }

  Future<bool> createEvent(Event event) async {
    final uri = Uri.parse('$baseUrl/events');
    final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toMap()));
    return resp.statusCode == 201 || resp.statusCode == 200;
  }
}
