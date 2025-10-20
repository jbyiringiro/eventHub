import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>().events;
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No events yet',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/create'),
                    child: const Text('Create Event'),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, i) => EventCard(event: events[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
