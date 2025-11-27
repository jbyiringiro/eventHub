<<<<<<< HEAD
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/user.dart';

class BackendService {
  // Replace with your actual backend URL
  static const String _baseUrl = 'https://your-backend.com/api';
  
  // Events endpoints
  static Future<List<Event>> getEvents() async {
=======

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google authentication datasource
class GoogleAuthDatasource {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Google

   Future<User?> signInWithGoogle() async {
>>>>>>> a842aa5b73b7b0e28193c764dc235922de9f5b51
    try {
      final response = await http.get(Uri.parse('$_baseUrl/events'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events');
      }
<<<<<<< HEAD
=======

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential

       final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase

       final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
>>>>>>> a842aa5b73b7b0e28193c764dc235922de9f5b51
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Event> createEvent(Event event) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Event.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User endpoints
  static Future<User> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );
      
      if (response.statusCode == 201) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<User?> getUser(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));
      
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}