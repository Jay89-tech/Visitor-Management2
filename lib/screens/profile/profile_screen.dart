// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to settings
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [AppTheme.cardShadow],
              ),
              child: const Center(
                child: Text(
                  'JD',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 4),
            Text(
              'john.doe@company.com',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.mediumText,
              ),
            ),
            const SizedBox(height: 32),

            // Profile Options
            _buildProfileOption(
              context,
              Icons.edit_outlined,
              'Edit Profile',
              () {},
            ),
            _buildProfileOption(
              context,
              Icons.lock_outline,
              'Change Password',
              () {},
            ),
            _buildProfileOption(
              context,
              Icons.notifications_outlined,
              'Notification Settings',
              () {},
            ),
            _buildProfileOption(
              context,
              Icons.help_outline,
              'Help & Support',
              () {},
            ),
            _buildProfileOption(
              context,
              Icons.info_outline,
              'About',
              () {},
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context,
              Icons.logout,
              'Logout',
              () {
                // Show logout dialog
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppTheme.dangerRed : AppTheme.primaryBlue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppTheme.dangerRed : AppTheme.darkText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.mediumText,
        ),
        onTap: onTap,
      ),
    );
  }
}
