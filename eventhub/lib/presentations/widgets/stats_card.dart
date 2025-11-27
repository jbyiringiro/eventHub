import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const StatsCard({
    required this.title, 
    required this.value, 
    required this.subtitle, 
    required this.icon, 
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: TextStyle(color: AppColors.gray500, fontSize: 12, fontWeight: FontWeight.w500)
                      ),
                      SizedBox(height: 4),
                      Text(
                        value, 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray800)
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              subtitle, 
              style: TextStyle(color: AppColors.gray500, fontSize: 12)
            ),
          ],
        ),
      ),
    );
  }
}