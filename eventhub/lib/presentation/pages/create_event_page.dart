import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/event_entity.dart';
import '../../data/datasources/event_service.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/event/event_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
class CreateEventPage extends StatefulWidget {
  final EventEntity? eventToEdit;

  const CreateEventPage({Key? key, this.eventToEdit}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService(); // Keep for image upload only
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController();

  XFile? _selectedImage;
  bool _isUploading = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedCategory;
  bool _showCustomCategory = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    final event = widget.eventToEdit!;
    _titleController.text = event.title;
    _locationController.text = event.location;
    _descriptionController.text = event.description;
    if (event.maxAttendees != null) {
      _maxAttendeesController.text = event.maxAttendees.toString();
    }
    _selectedDate = event.date;
    _selectedTime = TimeOfDay.fromDateTime(event.date);
    _selectedCategory = event.category;
  }

  final List<String> _categories = [
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
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      
      if (authState is! AuthAuthenticated) {
        _showErrorDialog('Please log in to ${widget.eventToEdit != null ? 'update' : 'create'} events');
        return;
      }

      final bool isEditing = widget.eventToEdit != null;

      if (_selectedImage == null && !isEditing) {
        _showErrorDialog('Please select an image for the event');
        return;
      }

      // Combine date and time
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      setState(() {
        _isUploading = true;
      });

      try {
        // Determine the final category value
        String? finalCategory;
        if (_selectedCategory == 'Other' && _showCustomCategory) {
          finalCategory = _customCategoryController.text.isNotEmpty 
              ? _customCategoryController.text 
              : null;
        } else {
          finalCategory = _selectedCategory;
        }

        // Upload new image if selected, otherwise keep existing image
        String imageUrl = isEditing ? widget.eventToEdit!.image : '';
        if (_selectedImage != null) {
          final tempEvent = await _eventService.createEvent(
            title: _titleController.text,
            date: eventDateTime,
            location: _locationController.text,
            description: _descriptionController.text,
            imageFile: _selectedImage!,
            organizer: authState.user.name,
            userId: authState.user.id,
            category: finalCategory,
          );
          imageUrl = tempEvent.image;
        }

        // Create or update event entity for Firestore
        final int? maxAttendees = _maxAttendeesController.text.isNotEmpty 
            ? int.tryParse(_maxAttendeesController.text) 
            : null;
        
        final eventData = EventEntity(
          id: isEditing ? widget.eventToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          date: eventDateTime,
          time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
          location: _locationController.text,
          description: _descriptionController.text,
          image: imageUrl,
          attendees: isEditing ? widget.eventToEdit!.attendeeIds.length : 0,
          organizer: authState.user.name,
          category: finalCategory,
          status: 'Upcoming',
          userId: authState.user.id,
          createdAt: isEditing ? widget.eventToEdit!.createdAt : DateTime.now(),
          attendeeIds: isEditing ? widget.eventToEdit!.attendeeIds : [],
          maxAttendees: maxAttendees,
        );

        // Save to Firestore via EventBloc
        if (isEditing) {
          context.read<EventBloc>().add(UpdateEvent(event: eventData));
        } else {
          context.read<EventBloc>().add(CreateEvent(event: eventData));
        }
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Event updated successfully!' : 'Event created and saved to Firestore!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to ${widget.eventToEdit != null ? 'update' : 'create'} event: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald600),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '${widget.eventToEdit != null ? 'Updating' : 'Creating'} your event...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: AppColors.gray800, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: AppColors.gray200, width: 1),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(60, 20, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald600.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppColors.emerald600,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.eventToEdit != null ? 'Edit Event' : 'Create New Event',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gray800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        widget.eventToEdit != null ? 'Update your event details' : 'Share your event with the community',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Upload Section
                          _buildImageUploadSection(),
                          SizedBox(height: 24),
                          
                          // Event Details Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gray800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 20),
                                
                                // Event Title
                                TextFormField(
                                  controller: _titleController,
                                  style: TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'Event Title *',
                                    labelStyle: TextStyle(
                                      color: AppColors.gray600,
                                      fontSize: 14,
                                    ),
                                    hintText: 'Enter a catchy title',
                                    hintStyle: TextStyle(color: AppColors.gray400),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(Icons.title_rounded, color: AppColors.emerald600, size: 22),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.gray50,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter event title';
                                    }
                                    return null;
                                  },
                                ),
                                            SizedBox(height: 16),
                                
                                // Date and Time Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _selectDate,
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            style: TextStyle(fontSize: 15),
                                            decoration: InputDecoration(
                                              labelText: 'Date *',
                                              labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                              prefixIcon: Container(
                                                padding: EdgeInsets.all(12),
                                                child: Icon(Icons.calendar_today_rounded, color: AppColors.blue600, size: 20),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: AppColors.gray300),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: AppColors.gray300),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: AppColors.blue600, width: 2),
                                              ),
                                              filled: true,
                                              fillColor: AppColors.blue50.withOpacity(0.3),
                                            ),
                                            controller: TextEditingController(
                                              text: _formatDate(_selectedDate),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Select date';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _selectTime,
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            style: TextStyle(fontSize: 15),
                                            decoration: InputDecoration(
                                              labelText: 'Time *',
                                              labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                              prefixIcon: Container(
                                                padding: EdgeInsets.all(12),
                                                child: Icon(Icons.access_time_rounded, color: AppColors.purple600, size: 20),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: AppColors.gray300),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: AppColors.gray300),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: AppColors.purple600, width: 2),
                                              ),
                                              filled: true,
                                              fillColor: AppColors.purple100.withOpacity(0.3),
                                            ),
                                            controller: TextEditingController(
                                              text: _formatTime(_selectedTime),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Select time';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                            SizedBox(height: 16),
                                
                                // Location
                                TextFormField(
                                  controller: _locationController,
                                  style: TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'Location *',
                                    labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                    hintText: 'Where will this event take place?',
                                    hintStyle: TextStyle(color: AppColors.gray400),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(Icons.location_on_rounded, color: Colors.red.shade400, size: 22),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    filled: true,
                                    fillColor: Colors.red.shade50.withOpacity(0.3),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter location';
                                    }
                                    return null;
                                  },
                                ),
                                            SizedBox(height: 16),
                                
                                // Category Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  style: TextStyle(fontSize: 15, color: AppColors.gray800),
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                    hintText: 'Select a category',
                                    hintStyle: TextStyle(color: AppColors.gray400),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(Icons.category_rounded, color: AppColors.yellow600, size: 22),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.yellow600, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.yellow100.withOpacity(0.2),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                  isExpanded: true,
                                  items: _categories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                      _showCustomCategory = newValue == 'Other';
                                    });
                                  },
                                ),
                                            SizedBox(height: 16),
                                
                                // Custom Category Field (shown when "Other" is selected)
                                if (_showCustomCategory)
                                  Column(
                                    children: [
                                      TextFormField(
                                        controller: _customCategoryController,
                                        style: TextStyle(fontSize: 15),
                                        decoration: InputDecoration(
                                          labelText: 'Enter Custom Category',
                                          labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                          hintText: 'Type your custom category',
                                          hintStyle: TextStyle(color: AppColors.gray400),
                                          prefixIcon: Container(
                                            padding: EdgeInsets.all(12),
                                            child: Icon(Icons.edit_rounded, color: AppColors.emerald600, size: 22),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: AppColors.gray300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: AppColors.gray300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.red.shade300),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.emerald50.withOpacity(0.3),
                                        ),
                                        validator: (value) {
                                          if (_selectedCategory == 'Other' && (value == null || value.isEmpty)) {
                                            return 'Please enter a custom category';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  ),
                                
                                // Max Attendees
                                TextFormField(
                                  controller: _maxAttendeesController,
                                  style: TextStyle(fontSize: 15),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Maximum Attendees (Optional)',
                                    labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                    hintText: 'Leave empty for unlimited',
                                    hintStyle: TextStyle(color: AppColors.gray400),
                                    prefixIcon: Icon(Icons.group, color: AppColors.emerald600),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.gray50,
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final number = int.tryParse(value);
                                      if (number == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (number < 1) {
                                        return 'Must be at least 1';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                
                                // Description
                                TextFormField(
                                  controller: _descriptionController,
                                  style: TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'Description *',
                                    labelStyle: TextStyle(color: AppColors.gray600, fontSize: 14),
                                    hintText: 'Tell people what your event is about...',
                                    hintStyle: TextStyle(color: AppColors.gray400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.gray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.gray50,
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter description';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                                SizedBox(height: 32),
                          
                          // Create Button with gradient
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.emerald600, AppColors.blue600],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emerald600.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _createEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(widget.eventToEdit != null ? Icons.save_outlined : Icons.add_circle_outline_rounded, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    widget.eventToEdit != null ? 'Update Event' : 'Create Event',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          
                          // Help text
                          Center(
                            child: Text(
                              'Your event will be visible to the community',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.gray500,
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_rounded,
                  color: AppColors.blue600,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Choose an eye-catching image',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedImage == null 
                      ? AppColors.gray300 
                      : AppColors.emerald600,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                color: _selectedImage == null 
                    ? AppColors.gray50 
                    : Colors.transparent,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.emerald50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 40,
                            color: AppColors.emerald600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Upload Event Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to select from gallery',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _selectedImage!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.emerald600,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_selectedImage != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.emerald600,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Image selected: ${_selectedImage!.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.emerald600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}