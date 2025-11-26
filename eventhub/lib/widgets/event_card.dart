import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMEd().add_jm().format(event.dateTime);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text('$dateStr • ${event.location}'),
        trailing: IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: share link
            }),
        onTap: () {
          // TODO: open details
        },
      ),
    );
  }
}
