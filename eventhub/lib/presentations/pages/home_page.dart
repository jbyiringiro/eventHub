import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_footer.dart';
import '../widgets/event_card.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/event/event_event.dart';
import '../bloc/event/event_state.dart';
import 'create_event_page.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavTap;

  HomePage({this.onNavTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load events from Firestore when page initializes
    context.read<EventBloc>().add(const LoadEvents());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() {
        _showFloatingButton = true;
      });
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() {
        _showFloatingButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        List<EventEntity> events = [];
        bool isLoading = false;

        if (state is EventLoading) {
          isLoading = true;
        } else if (state is EventLoaded) {
          events = List.from(state.events)
            ..sort((a, b) => b.date.compareTo(a.date));
        }

        return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with Create Button
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.gray200,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo and Title
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.emerald600.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.event_rounded,
                                color: AppColors.emerald600,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'EventEase',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // Create Button - TOP RIGHT
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateEventPage()),
                            );
                          },
                          icon: Icon(Icons.add_rounded, size: 20),
                          label: Text(
                            'Create',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.emerald600.withOpacity(0.3),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Hero Section - GRADIENT CARD
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [AppColors.emerald600, AppColors.blue600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald600.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Create & Discover\nAmazing Events',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Simple event management for universities,\nNGOs, and community groups.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CreateEventPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.emerald600,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Create Event',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => widget.onNavTap?.call(1),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white, width: 2),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Browse Events',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Events Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Events',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Discover what\'s happening',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => widget.onNavTap?.call(1),
                            icon: Text(
                              'View all',
                              style: TextStyle(
                                color: AppColors.emerald600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            label: Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppColors.emerald600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Display events from Firestore
                      if (isLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(color: AppColors.emerald600),
                          ),
                        )
                      else if (events.isEmpty)
                        Container(
                          padding: EdgeInsets.all(48),
                          child: Column(
                            children: [
                              Icon(Icons.event_available, size: 64, color: AppColors.gray400),
                              SizedBox(height: 16),
                              Text(
                                'No events yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create one to get started!',
                                style: TextStyle(fontSize: 14, color: AppColors.gray500),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) => EventCard(event: events[index]),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                CustomFooter(),
              ],
            ),
          ),
        ],
      ),
      // FLOATING CREATE BUTTON - Appears on scroll
      floatingActionButton: AnimatedScale(
        scale: _showFloatingButton ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEventPage()),
            );
          },
          backgroundColor: AppColors.emerald600,
          elevation: 4,
          icon: Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Create Event',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
        );
      },
    );
  }
}