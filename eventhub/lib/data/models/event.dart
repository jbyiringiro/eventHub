class Event {
  final String? id;
  final String title;
  final DateTime date;
  final String? time;
  final String location;
  final String description;
  final String image; // This will be ImageKit.io URL
  final int attendees;
  final String organizer;
  final String? category;
  final String? status;
  final String? userId;
  final DateTime? createdAt;
  final List<String>? attendeesList;

  Event({
    this.id,
    required this.title,
    required this.date,
    this.time,
    required this.location,
    required this.description,
    required this.image,
    required this.attendees,
    required this.organizer,
    this.category,
    this.status,
    this.userId,
    this.createdAt,
    this.attendeesList,
  });

  // Create Event from JSON (for local storage)
  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime eventDate = DateTime.now();
    if (json['date'] != null) {
      if (json['date'] is String) {
        eventDate = DateTime.parse(json['date']);
      } else if (json['date'] is DateTime) {
        eventDate = json['date'] as DateTime;
      }
    }

    DateTime? createdAtDate;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        createdAtDate = DateTime.parse(json['createdAt']);
      } else if (json['createdAt'] is DateTime) {
        createdAtDate = json['createdAt'] as DateTime;
      }
    }

    return Event(
      id: json['id'],
      title: json['title'] ?? '',
      date: eventDate,
      time: json['time'] ?? _extractTimeFromDateTime(eventDate),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      attendees: json['attendees'] ?? 0,
      organizer: json['organizer'] ?? '',
      category: json['category'],
      status: json['status'] ?? 'active',
      userId: json['userId'],
      createdAt: createdAtDate,
      attendeesList: json['attendeesList'] != null 
          ? List<String>.from(json['attendeesList'])
          : [],
    );
  }

  // Convert Event to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time ?? _extractTimeFromDateTime(date),
      'location': location,
      'description': description,
      'image': image,
      'attendees': attendees,
      'organizer': organizer,
      'category': category,
      'status': status ?? 'active',
      'userId': userId,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'attendeesList': attendeesList ?? [],
    };
  }

  // Helper method to extract time from DateTime
  static String _extractTimeFromDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? time,
    String? location,
    String? description,
    String? image,
    int? attendees,
    String? organizer,
    String? category,
    String? status,
    String? userId,
    DateTime? createdAt,
    List<String>? attendeesList,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      description: description ?? this.description,
      image: image ?? this.image,
      attendees: attendees ?? this.attendees,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      attendeesList: attendeesList ?? this.attendeesList,
    );
  }

  // Get optimized image URL for display
  String getOptimizedImageUrl({int width = 400, int height = 300}) {
    if (image.isEmpty) return '';
    
    // If it's already an ImageKit URL, add transformations
    if (image.contains('ik.imagekit.io')) {
      return '$image?tr=w-$width,h-$height,c-maintain_ratio,f-webp,q-80';
    }
    
    return image; // Return original if not ImageKit URL
  }

  // Get thumbnail URL
  String getThumbnailUrl({int size = 150}) {
    if (image.isEmpty) return '';
    
    if (image.contains('ik.imagekit.io')) {
      return '$image?tr=w-$size,h-$size,c-fill,f-webp,q-70';
    }
    
    return image;
  }
}