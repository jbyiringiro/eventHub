import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_footer.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/event/event_event.dart';
import '../bloc/event/event_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'create_event_page.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  const EventDetailsPage({required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load all events and find the specific one
    context.read<EventBloc>().add(const LoadEvents());
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;

        return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        EventEntity? event;
        bool isLoading = false;

        if (state is EventLoading) {
          isLoading = true;
        } else if (state is EventLoaded) {
          // Find the event with matching ID
          try {
            event = state.events.firstWhere((e) => e.id == widget.eventId);
          } catch (e) {
            event = null;
          }
        }

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Icon(Icons.event, color: AppColors.emerald600),
                  SizedBox(width: 8),
                  Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.gray800),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.emerald600),
            ),
          );
        }

        if (event == null && !isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Icon(Icons.event, color: AppColors.emerald600),
                  SizedBox(width: 8),
                  Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.gray800),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
                  SizedBox(height: 16),
                  Text(
                    'Event not found',
                    style: TextStyle(fontSize: 18, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          );
        }

        // At this point, event is guaranteed to be non-null
        final eventData = event!;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.event, color: AppColors.emerald600),
                SizedBox(width: 8),
                Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.gray800),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            Image.network(
                              eventData.image, 
                              height: 200, 
                              width: double.infinity, 
                              fit: BoxFit.cover
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          eventData.title, 
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: eventData.maxAttendees != null && eventData.attendees >= eventData.maxAttendees!
                                              ? Colors.red.shade100
                                              : AppColors.emerald100, 
                                          borderRadius: BorderRadius.circular(16)
                                        ),
                                        child: Text(
                                          eventData.maxAttendees != null
                                              ? '${eventData.attendees}/${eventData.maxAttendees} attending'
                                              : '${eventData.attendees} attending', 
                                          style: TextStyle(
                                            color: eventData.maxAttendees != null && eventData.attendees >= eventData.maxAttendees!
                                                ? Colors.red.shade700
                                                : AppColors.emerald600, 
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: AppColors.gray600), 
                                      SizedBox(width: 8), 
                                      Text(
                                        '${_formatDate(eventData.date)} • ${_formatTime(eventData.date)}', 
                                        style: TextStyle(color: AppColors.gray600)
                                      )
                                    ]
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: AppColors.gray600), 
                                      SizedBox(width: 8), 
                                      Expanded(
                                        child: Text(
                                          eventData.location, 
                                          style: TextStyle(color: AppColors.gray600)
                                        )
                                      )
                                    ]
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'About This Event', 
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray800)
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    eventData.description, 
                                    style: TextStyle(color: AppColors.gray600, height: 1.6)
                                  ),
                                  SizedBox(height: 24),
                                  Column(
                                    children: [
                                      // Show Edit and Delete buttons only if user owns the event
                                      if (currentUserId != null && eventData.userId == currentUserId) ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CreateEventPage(eventToEdit: eventData),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(Icons.edit_outlined, size: 20),
                                                label: Text('Edit Event'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.emerald600,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 16),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _showDeleteDialog(context, eventData),
                                                icon: Icon(Icons.delete_outline, size: 20),
                                                label: Text('Delete'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                      ],
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: currentUserId == null ? null : () {
                                            // Check if user already RSVP'd
                                            final hasRSVPd = eventData.attendeeIds.contains(currentUserId);
                                            final isFull = eventData.maxAttendees != null && eventData.attendees >= eventData.maxAttendees!;
                                            
                                            // Don't allow new RSVP if event is full
                                            if (!hasRSVPd && isFull) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Event is full! Maximum ${eventData.maxAttendees} attendees reached.'),
                                                  backgroundColor: Colors.red,
                                                )
                                              );
                                              return;
                                            }
                                            
                                            List<String> updatedAttendeeIds;
                                            int updatedAttendeesCount;
                                            String message;
                                            
                                            if (hasRSVPd) {
                                              // Cancel RSVP
                                              updatedAttendeeIds = List<String>.from(eventData.attendeeIds)..remove(currentUserId);
                                              updatedAttendeesCount = eventData.attendees - 1;
                                              message = 'RSVP cancelled';
                                            } else {
                                              // Add RSVP
                                              updatedAttendeeIds = List<String>.from(eventData.attendeeIds)..add(currentUserId);
                                              updatedAttendeesCount = eventData.attendees + 1;
                                              message = 'RSVP confirmed!';
                                            }
                                            
                                            final updatedEvent = EventEntity(
                                              id: eventData.id,
                                              title: eventData.title,
                                              date: eventData.date,
                                              time: eventData.time,
                                              location: eventData.location,
                                              description: eventData.description,
                                              image: eventData.image,
                                              attendees: updatedAttendeesCount,
                                              organizer: eventData.organizer,
                                              category: eventData.category,
                                              status: eventData.status,
                                              userId: eventData.userId,
                                              createdAt: eventData.createdAt,
                                              attendeeIds: updatedAttendeeIds,
                                              maxAttendees: eventData.maxAttendees,
                                            );
                                            
                                            context.read<EventBloc>().add(UpdateEvent(event: updatedEvent));
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('$message Total attendees: $updatedAttendeesCount'),
                                                backgroundColor: hasRSVPd ? AppColors.gray600 : AppColors.emerald600,
                                              )
                                            );
                                          },
                                          icon: Icon(
                                            eventData.attendeeIds.contains(currentUserId) 
                                              ? Icons.cancel 
                                              : (eventData.maxAttendees != null && eventData.attendees >= eventData.maxAttendees! 
                                                  ? Icons.block 
                                                  : Icons.check_circle), 
                                            size: 20
                                          ),
                                          label: Text(
                                            eventData.attendeeIds.contains(currentUserId) 
                                              ? 'Cancel RSVP' 
                                              : (eventData.maxAttendees != null && eventData.attendees >= eventData.maxAttendees! 
                                                  ? 'Event Full' 
                                                  : 'RSVP Now')
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: eventData.attendeeIds.contains(currentUserId)
                                              ? AppColors.gray600
                                              : (eventData.maxAttendees != null && eventData.attendees >= eventData.maxAttendees! 
                                                  ? Colors.red.shade400 
                                                  : AppColors.emerald600), 
                                            foregroundColor: Colors.white, 
                                            padding: EdgeInsets.symmetric(vertical: 16)
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            // Share functionality
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Share feature coming soon!'))
                                            );
                                          },
                                          icon: Icon(Icons.share, size: 20),
                                          label: Text('Share Event'),
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(vertical: 16)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomFooter(),
              ],
            ),
          ),
        );
      },
    );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, EventEntity event) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete \"${event.title}\"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<EventBloc>().add(DeleteEvent(eventId: event.id));
                Navigator.of(context).pop(); // Go back to previous page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}