import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/auth_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  final Function(int)? onNavTap;

  const ProfilePage({this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
                SizedBox(height: 16),
                Text(
                  'No user found',
                  style: TextStyle(fontSize: 18, color: AppColors.gray600),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Go to Login'),
                ),
              ],
            ),
          );
        }

        final user = authState.user;
        final authService = AuthService(); // Keep for dialog methods

        // Extract better name from email if name is still "User"
        String displayName = user.name;
        if (displayName == 'User' && user.email.isNotEmpty) {
          displayName = user.email
              .split('@')[0]
              .replaceAll('.', ' ')
              .replaceAll('_', ' ');
          displayName = displayName
              .split(' ')
              .map(
                (word) => word.isNotEmpty
                    ? word[0].toUpperCase() + word.substring(1)
                    : word,
              )
              .join(' ');
        }

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.emerald100,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.emerald600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.gray600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.emerald100, // Use emerald100 directly
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Member since ${_formatDate(user.createdAt)}',
                            style: TextStyle(
                              color: AppColors.emerald600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Account Details
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray800,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildDetailItem('User ID', user.id),
                        _buildDetailItem('Email', user.email),
                        _buildDetailItem('Full Name', user.name),
                        _buildDetailItem(
                          'Member Since',
                          _formatDate(user.createdAt),
                        ),
                        if (user.profilePictureUrl != null)
                          _buildDetailItem('Profile Picture', 'Uploaded'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit, color: AppColors.emerald600),
                        title: Text('Edit Profile'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          _showEditProfileDialog(context, user, authService);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: AppColors.emerald600,
                        ),
                        title: Text('Settings'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.help, color: AppColors.emerald600),
                        title: Text('Help & Support'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to help
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          _showLogoutConfirmation(context, authService);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: AppColors.gray600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authService.logout();
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    dynamic user,
    AuthService authService,
  ) {
    final nameController = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await authService.updateProfile(
                  userId: user.id,
                  name: nameController.text,
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update profile: $e')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
