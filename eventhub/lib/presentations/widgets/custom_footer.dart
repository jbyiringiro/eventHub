import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray800,
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text('EventEase', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Simple event management for universities, NGOs, and community groups.', 
            style: TextStyle(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text('© 2025 EventEase. All rights reserved.', style: TextStyle(color: AppColors.gray400)),
        ],
      ),
    );
  }
}