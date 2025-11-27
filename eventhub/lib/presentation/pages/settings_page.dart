import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/preferences_service.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _prefsService = PreferencesService();

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en';
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final theme = await _prefsService.getThemeMode();
    final language = await _prefsService.getLanguage();
    final notifications = await _prefsService.getNotificationsEnabled();

    setState(() {
      _themeMode = theme;
      _language = language;
      _notificationsEnabled = notifications;
      _isLoading = false;
    });
  }

  Future<void> _updateTheme(ThemeMode? mode) async {
    if (mode == null) return;

    await _prefsService.setThemeMode(mode);
    setState(() => _themeMode = mode);

    // Update app theme
    if (context.mounted) {
      EventEaseApp.of(context)?.changeTheme(mode);
    }

    _showSnackBar('Theme updated to ${mode.name}');
  }

  Future<void> _updateLanguage(String? languageCode) async {
    if (languageCode == null) return;

    await _prefsService.setLanguage(languageCode);
    setState(() => _language = languageCode);

    _showSnackBar('Language updated');
  }

  Future<void> _updateNotifications(bool value) async {
    await _prefsService.setNotificationsEnabled(value);
    setState(() => _notificationsEnabled = value);

    _showSnackBar(value ? 'Notifications enabled' : 'Notifications disabled');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.emerald600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.emerald600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: AppColors.emerald600),
                      const SizedBox(width: 12),
                      Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    subtitle: const Text('Always use light theme'),
                    value: ThemeMode.light,
                    groupValue: _themeMode,
                    onChanged: _updateTheme,
                    activeColor: AppColors.emerald600,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    subtitle: const Text('Always use dark theme'),
                    value: ThemeMode.dark,
                    groupValue: _themeMode,
                    onChanged: _updateTheme,
                    activeColor: AppColors.emerald600,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System'),
                    subtitle: const Text('Follow system theme'),
                    value: ThemeMode.system,
                    groupValue: _themeMode,
                    onChanged: _updateTheme,
                    activeColor: AppColors.emerald600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, color: AppColors.emerald600),
                      const SizedBox(width: 12),
                      Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    ],
                    onChanged: _updateLanguage,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: AppColors.emerald600),
                      const SizedBox(width: 12),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive event updates and reminders'),
                    value: _notificationsEnabled,
                    onChanged: _updateNotifications,
                    activeColor: AppColors.emerald600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.emerald600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Settings are saved automatically',
                    style: TextStyle(fontSize: 14, color: AppColors.gray600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restart the app to see all theme changes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
