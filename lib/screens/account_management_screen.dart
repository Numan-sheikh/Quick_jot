import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider; // FIX: Hide AuthProvider from firebase_auth
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import 'login_screen.dart';

final _logger = Logger();

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Management',
          style: theme.textTheme.titleLarge?.copyWith(
            color:
                theme
                    .colorScheme
                    .onSurface, // Use onSurface for text on transparent app bar
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            Colors.transparent, // Match the transparent app bar style
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ), // Back button color
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withAlpha(200),
                    child: Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName![0].toUpperCase()
                          : (user?.email?.isNotEmpty == true
                              ? user!.email![0].toUpperCase()
                              : 'U'),
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Guest User',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Not logged in',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Account Actions
            Text(
              'Account Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(200),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(
                Icons.switch_account,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Switch Account (Requires re-login)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                _logger.i(
                  'Switch Account tapped - initiating logout for re-login',
                );
                // This would typically involve logging out and then
                // prompting the user to sign in again, potentially with a different account.
                // For this example, we'll just log out.
                _showLogoutConfirmation(context, authProvider);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.manage_accounts,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Manage Google Account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                _logger.i('Manage Google Account tapped - Placeholder');
                // In a real app, you might open a URL to Google Account settings
                // using the url_launcher package.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Feature: Manage Google Account (external link)',
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                'Logout',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () => _showLogoutConfirmation(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to show logout confirmation dialog
  void _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                _logger.i('Confirming logout...');
                if (!context.mounted) {
                  return; // Check context before async operations
                }

                final navigator = Navigator.of(context);
                // Dispose NoteProvider before logging out
                Provider.of<NoteProvider>(context, listen: false).dispose();
                await authProvider.logout();
                _logger.i('Logout successful, navigating to LoginScreen');
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
