import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Settings
          const Text(
            'App Settings',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 16),

          // Theme
          Card(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primaryBlue,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Dark' : 'Light',
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Notifications
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notification settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Language
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.language,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Security
          const Text(
            'Security',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.lock_outline,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.fingerprint,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Biometric Authentication'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // About
          const Text(
            'About',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Danger Zone
          const Text(
            'Danger Zone',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 16),

          Card(
            color: AppTheme.dangerRed.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppTheme.dangerRed,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppTheme.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: AppTheme.dangerRed.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: AppTheme.dangerRed,
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  color: AppTheme.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion coming soon'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
    }
  }
}
