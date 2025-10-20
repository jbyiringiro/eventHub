class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String organizerId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.organizerId,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] as String),
      location: map['location'] ?? '',
      organizerId: map['organizerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'organizerId': organizerId,
    };
  }
}
