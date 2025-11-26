import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pages/home_page.dart';
import '../pages/events_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/profile_page.dart';

class MainAppShell extends StatefulWidget {
  final int initialTab;

  const MainAppShell({this.initialTab = 0});

  @override
  _MainAppShellState createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _pages() => [
    HomePage(onNavTap: _onItemTapped),
    EventsPage(onNavTap: _onItemTapped),
    DashboardPage(onNavTap: _onItemTapped),
    ProfilePage(onNavTap: _onItemTapped),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(
        title: Row(
          children: [
            Icon(Icons.event, color: AppColors.emerald600, size: 24),
            SizedBox(width: 8),
            Text(
              'EventEase',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.explore_rounded,
                  label: 'Browse',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.emerald600.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.emerald600 : AppColors.gray500,
                    size: 26,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.emerald600 : AppColors.gray600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}