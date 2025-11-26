import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>().events;
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Dashboard')),
      body: events.isEmpty
          ? const Center(child: Text('No events yet'))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, i) => EventCard(event: events[i]),
            ),
    );
  }
}
