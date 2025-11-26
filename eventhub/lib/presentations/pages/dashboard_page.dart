import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/stats_card.dart';
import '../widgets/custom_footer.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/event/event_event.dart';
import '../bloc/event/event_state.dart';
import 'create_event_page.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? onNavTap;

  const DashboardPage({this.onNavTap});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load events from Firestore
    context.read<EventBloc>().add(const LoadEvents());
  }

  Future<void> _refreshData() async {
    context.read<EventBloc>().add(const LoadEvents());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            body: Center(
              child: Text('Please login to view dashboard'),
            ),
          );
        }

        final currentUser = authState.user;

        return BlocBuilder<EventBloc, EventState>(
          builder: (context, eventState) {
            List<EventEntity> allEvents = [];
            bool isLoading = false;

            if (eventState is EventLoading) {
              isLoading = true;
            } else if (eventState is EventLoaded) {
              allEvents = eventState.events;
            }

            // Filter events by current user
            final userEvents = allEvents.where((event) => event.userId == currentUser.id).toList();

            return Scaffold(
              body: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Dashboard', 
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => CreateEventPage())
                                    ),
                                    icon: Icon(Icons.add, size: 20),
                                    label: Text('Create Event'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.emerald600, 
                                      foregroundColor: Colors.white, 
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),

                              // User Stats
                              isLoading
                                  ? Container(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(color: AppColors.emerald600),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.2,
                                      ),
                                      itemCount: 4,
                                      itemBuilder: (context, index) => _buildStatsCard(index, userEvents, allEvents, currentUser.id),
                                    ),
                              SizedBox(height: 24),

                              // Your Events Section
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                        children: [
                                          Text(
                                            'Your Events', 
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray800)
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.refresh),
                                            onPressed: _refreshData,
                                          ),
                                        ]
                                      ),
                                      SizedBox(height: 16),
                                      isLoading
                                          ? Center(child: CircularProgressIndicator(color: AppColors.emerald600))
                                          : userEvents.isEmpty
                                              ? Container(
                                                  padding: EdgeInsets.all(32),
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.event_note, size: 48, color: AppColors.gray400),
                                                      SizedBox(height: 12),
                                                      Text(
                                                        'No events created yet',
                                                        style: TextStyle(color: AppColors.gray600),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Column(
                                                  children: userEvents.map((event) => _buildEventItem(event)).toList(),
                                                ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomFooter(),
                      ],
                    ),
                  ),
                ),
              );
          },
        );
      },
    );
  }

  Widget _buildStatsCard(int index, List<EventEntity> userEvents, List<EventEntity> allEvents, String currentUserId) {
    final createdCount = userEvents.length;
    // Count events where current user has RSVP'd (not created by them)
    final attendingCount = allEvents.where((event) => 
      event.attendeeIds.contains(currentUserId) && event.userId != currentUserId
    ).length;

    final stats = [
      {
        'title': 'Events Created',
        'value': createdCount.toString(),
        'subtitle': 'Total events created',
        'icon': Icons.calendar_today,
        'color': AppColors.blue600,
      },
      {
        'title': 'Attending',
        'value': attendingCount.toString(),
        'subtitle': 'Events you joined',
        'icon': Icons.check_circle,
        'color': AppColors.emerald600,
      },
      {
        'title': 'Total Attendees',
        'value': userEvents.fold(0, (sum, event) => sum + event.attendees).toString(),
        'subtitle': 'Across all events',
        'icon': Icons.people,
        'color': AppColors.purple600,
      },
      {
        'title': 'This Month',
        'value': userEvents.where((event) => 
          event.createdAt.month == DateTime.now().month && 
          event.createdAt.year == DateTime.now().year
        ).length.toString(),
        'subtitle': 'Events created',
        'icon': Icons.trending_up,
        'color': AppColors.yellow600,
      },
    ];
    
    if (index >= stats.length) return SizedBox();
    
    final stat = stats[index];
    return StatsCard(
      title: stat['title'] as String,
      value: stat['value'] as String,
      subtitle: stat['subtitle'] as String,
      icon: stat['icon'] as IconData,
      color: stat['color'] as Color,
    );
  }

  Widget _buildEventItem(EventEntity event) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.emerald100,
                child: Icon(Icons.event, size: 16, color: AppColors.emerald600),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      event.category ?? 'Event',
                      style: TextStyle(color: AppColors.gray600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${event.date.toString().split(' ')[0]}',
                style: TextStyle(fontSize: 12, color: AppColors.gray600),
              ),
              Text(
                '${event.attendees} attendees',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showDeleteDialog(event),
                icon: Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _navigateToEditEvent(event),
                icon: Icon(Icons.edit_outlined, size: 16, color: AppColors.emerald600),
                label: Text('Edit', style: TextStyle(color: AppColors.emerald600, fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(EventEntity event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<EventBloc>().add(DeleteEvent(eventId: event.id));
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

  void _navigateToEditEvent(EventEntity event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(eventToEdit: event),
      ),
    );
  }
}