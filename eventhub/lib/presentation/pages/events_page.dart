import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_footer.dart';
import '../widgets/event_card.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/event/event_event.dart';
import '../bloc/event/event_state.dart';

class EventsPage extends StatefulWidget {
  final Function(int)? onNavTap;

  const EventsPage({this.onNavTap});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<EventEntity> _filteredEvents = [];
  
  final List<String> _categories = [
    'All',
    'Business',
    'Conference',
    'Workshop',
    'Seminar',
    'Networking',
    'Sports',
    'Football',
    'Basketball',
    'Marathon',
    'Fitness',
    'Music',
    'Concert',
    'Festival',
    'Live Performance',
    'DJ Night',
    'Art',
    'Exhibition',
    'Gallery Opening',
    'Art Class',
    'Painting',
    'Technology',
    'Hackathon',
    'Tech Talk',
    'Product Launch',
    'Coding Bootcamp',
    'Community',
    'Charity',
    'Fundraiser',
    'Volunteer',
    'Social Gathering',
    'Education',
    'Training',
    'Lecture',
    'Study Group',
    'Webinar',
    'Entertainment',
    'Comedy Show',
    'Theater',
    'Movie Screening',
    'Gaming',
    'Food & Drink',
    'Food Festival',
    'Wine Tasting',
    'Cooking Class',
    'Restaurant Opening',
    'Health & Wellness',
    'Yoga',
    'Meditation',
    'Health Fair',
    'Mental Health',
    'Fashion',
    'Fashion Show',
    'Trunk Show',
    'Shopping Event',
    'Religious',
    'Church Service',
    'Prayer Meeting',
    'Religious Festival',
    'Politics',
    'Political Rally',
    'Town Hall',
    'Debate',
  ];

  @override
  void initState() {
    super.initState();
    // Load events from Firestore
    context.read<EventBloc>().add(const LoadEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEvents(List<EventEntity> allEvents) {
    List<EventEntity> filtered = allEvents;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((event) =>
        event.title.toLowerCase().contains(query) ||
        event.location.toLowerCase().contains(query) ||
        event.description.toLowerCase().contains(query) ||
        (event.category?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    if (_selectedCategory != 'All') {
      filtered = filtered.where((event) =>
        event.category?.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }

    setState(() {
      _filteredEvents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        List<EventEntity> allEvents = [];
        bool isLoading = false;

        if (state is EventLoading) {
          isLoading = true;
        } else if (state is EventLoaded) {
          allEvents = state.events;
          // Apply filters whenever events change
          if (_filteredEvents.isEmpty && _searchController.text.isEmpty && _selectedCategory == 'All') {
            _filteredEvents = allEvents;
          }
        }

        return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<EventBloc>().add(const LoadEvents());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Events', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gray800)
                    ),
                    SizedBox(height: 16),
                    
                    // Search and Filter
                    Column(
                      children: [
                        // Search TextField
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => _filterEvents(allEvents),
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            prefixIcon: Icon(Icons.search, color: AppColors.gray400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.gray300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.gray300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Category Filter
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          onChanged: (value) {
                            setState(() => _selectedCategory = value!);
                            _filterEvents(allEvents);
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.filter_list, color: AppColors.emerald600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.gray300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.gray300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem(
                              value: category, 
                              child: Text(category)
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Events List
                    isLoading
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: AppColors.emerald600),
                            ),
                          )
                        : _filteredEvents.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off, size: 64, color: AppColors.gray400),
                                    SizedBox(height: 16),
                                    Text(
                                      'No events found',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.gray600),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _searchController.text.isNotEmpty 
                                        ? 'Try a different search term'
                                        : 'Try a different category',
                                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _filteredEvents.length,
                                itemBuilder: (context, index) => EventCard(event: _filteredEvents[index]),
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
  }
}