import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if you want to open external URLs

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import 'login_screen.dart';

final _logger = Logger();

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

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
                if (!context.mounted) return;

                final navigator = Navigator.of(context);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Ensure consistent background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close), // 'X' icon to close the screen
          color: theme.colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Current User Profile Section
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withAlpha(200),
              backgroundImage:
                  user?.photoURL?.isNotEmpty == true
                      ? NetworkImage(user!.photoURL!)
                      : null,
              child:
                  user?.photoURL?.isEmpty ?? true
                      ? Text(
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
                      )
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Hi, ${user?.displayName?.split(' ')[0] ?? 'User'}!', // "Hi, Numan!"
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // Space between name and email
            Text(
              user?.email ??
                  'Not logged in', // Keep current user's email in center
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Switch Account Section
            // FIX: Replaced Container with Card to correctly apply CardTheme properties
            Card(
              // Card automatically picks up color, elevation, shape, and shadowColor from theme.cardTheme
              // if not explicitly overridden here.
              // We don't need BoxDecoration here anymore.
              child: ExpansionTile(
                initiallyExpanded:
                    true, // Keep it expanded by default like Google Notes
                title: Text(
                  'Switch account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons
                      .keyboard_arrow_up, // Always show up arrow as it's initially expanded
                  color: theme.colorScheme.onSurface,
                ),
                onExpansionChanged: (bool expanded) {
                  // No change needed for icon as per Google Notes style
                },
                children: [
                  // Only Current Account (as a list tile)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withAlpha(200),
                      backgroundImage:
                          user?.photoURL?.isNotEmpty == true
                              ? NetworkImage(user!.photoURL!)
                              : null,
                      child:
                          user?.photoURL?.isEmpty ?? true
                              ? Text(
                                user?.displayName?.isNotEmpty == true
                                    ? user!.displayName![0].toUpperCase()
                                    : (user?.email?.isNotEmpty == true
                                        ? user!.email![0].toUpperCase()
                                        : 'U'),
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
                    ),
                    title: Text(
                      user?.displayName ?? 'Guest User',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      user?.email ?? 'Not logged in',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                    onTap: () {
                      _logger.i('Current account tapped (no action)');
                      // Tapping current account typically does nothing or closes the sheet
                    },
                  ),
                  // Added Logout button inside the ExpansionTile
                  ListTile(
                    leading: Icon(Icons.logout, color: theme.colorScheme.error),
                    title: Text(
                      'Logout',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    onTap: () => _showLogoutConfirmation(context, authProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bottom Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _logger.i('Privacy Policy tapped');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Opening Privacy Policy... (Placeholder)',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Privacy Policy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ),
                Text(
                  ' • ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _logger.i('Terms of Service tapped');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Opening Terms of Service... (Placeholder)',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Terms of Service',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // Space at the bottom
          ],
        ),
      ),
    );
  }
}
