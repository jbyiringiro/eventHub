import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pages/home_page.dart';
import '../pages/events_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/login_page.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.event, color: AppColors.emerald600),
          SizedBox(width: 8),
          Text('EventEase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Mobile-friendly navigation - icons instead of text
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
          icon: Icon(Icons.home, color: AppColors.gray600),
          tooltip: 'Home',
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventsPage())),
          icon: Icon(Icons.explore, color: AppColors.gray600),
          tooltip: 'Browse Events',
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage())),
          icon: Icon(Icons.dashboard, color: AppColors.gray600),
          tooltip: 'Dashboard',
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
          icon: Icon(Icons.person, color: AppColors.gray600),
          tooltip: 'Login',
        ),
      ],
    );
  }
}