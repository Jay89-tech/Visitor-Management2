// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () {
              // Mark all as read
            },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Placeholder
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                ),
              ),
              title: const Text(
                'Visit Approved',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Your visit for Jan 15 has been approved',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const Text(
                '2h ago',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
