import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../services/notification_service.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({Key? key}) : super(key: key);

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  DateTime? _dateTime;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 18, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete form & pick date/time')));
      return;
    }
    final id = const Uuid().v4();
    final event = Event(
      id: id,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      dateTime: _dateTime!,
      location: _location.text.trim(),
      organizerId: 'local',
    );

    final provider = context.read<EventProvider>();
    provider.addEvent(event);

    // schedule notifications: 24 hours and 1 hour
    final notif = NotificationService();
    final before24 = event.dateTime.subtract(const Duration(hours: 24));
    final before1 = event.dateTime.subtract(const Duration(hours: 1));
    if (before24.isAfter(DateTime.now())) {
      notif.scheduleReminder(
        id: id.hashCode,
        title: 'Event tomorrow: ${event.title}',
        body: '${event.title} at ${event.location}',
        scheduledDate: before24,
      );
    }
    if (before1.isAfter(DateTime.now())) {
      notif.scheduleReminder(
        id: id.hashCode ^ 0xFFFF,
        title: 'Event in 1 hour: ${event.title}',
        body: '${event.title} at ${event.location}',
        scheduledDate: before1,
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_dateTime == null
                    ? 'Pick date & time'
                    : _dateTime.toString()),
                trailing: ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
