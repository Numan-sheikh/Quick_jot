import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:logger/logger.dart';

// Import your providers from the correct 'core/providers' path
import '../providers/note_provider.dart';
import '../providers/auth_provider.dart';

// Import your utility files
import '../core/utils/app_utils.dart';
// Solve the name collision by aliasing your custom DateUtils
import '../core/utils/date_utils.dart' as customdateutils;

// Import other screens and widgets
import 'login_screen.dart';
import 'note_editor_screen.dart';
import '../widgets/note_tile.dart';
// Import your new custom app bar
import '../widgets/app_bar.dart';
// Import the new account management screen
import 'account_management_screen.dart';

final _logger = Logger();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  // User info for the app bar
  String? _userDisplayName;
  String? _userEmail;
  String? _userPhotoUrl; // New: User's profile photo URL

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _logger.w('initState callback executed after widget was disposed.');
        return;
      }

      _initializeUserDataAndNotes();
    });

    // Listen for changes in the search bar
    _searchController.addListener(_onSearchChanged);
  }

  // Helper method to initialize user data and notes
  Future<void> _initializeUserDataAndNotes() async {
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        _logger.i('User logged in: ${user.uid}');
        setState(() {
          _userDisplayName = user.displayName;
          _userEmail = user.email;
          _userPhotoUrl = user.photoURL; // Fetch user's photo URL
        });
        _logger.i('Initializing NoteProvider for UID: ${user.uid}');
        noteProvider.initialize(user.uid);
      } else {
        _logger.w('User not logged in, navigating to LoginScreen');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      _logger.e(
        'Error accessing/initializing data in initState callback',
        error: e,
      );
      if (mounted) {
        _logger.i('Navigating to LoginScreen after data access error.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentSearchQuery = _searchController.text;
      _logger.d('Search query changed: $_currentSearchQuery');
    });
  }

  void _onProfileButtonPressed() {
    _logger.i('Profile button pressed, navigating to AccountManagementScreen');
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountManagementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final theme = Theme.of(context); // Access the current theme

    // Filter notes based on the current search query
    final filteredNotes =
        noteProvider.notes.where((note) {
          final titleLower = note.title.toLowerCase();
          final contentLower = note.content.toLowerCase();
          final searchQueryLower = _currentSearchQuery.toLowerCase();
          return titleLower.contains(searchQueryLower) ||
              contentLower.contains(searchQueryLower);
        }).toList();

    Widget bodyContent;

    if (!noteProvider.isInitialDataLoaded) {
      _logger.d('Showing loading indicator');
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (filteredNotes.isEmpty && _currentSearchQuery.isEmpty) {
      _logger.d('Showing empty state');
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 90,
                color: AppUtils.applyOpacity(theme.colorScheme.onSurface, 0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'No notes found.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppUtils.applyOpacity(
                    theme.colorScheme.onSurface,
                    0.7,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start by adding your thoughts, ideas, or to-dos.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppUtils.applyOpacity(
                    theme.colorScheme.onSurface,
                    0.6,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  _logger.i('Empty state: Add first note button pressed');
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Note'),
              ),
            ],
          ),
        ),
      );
    } else if (filteredNotes.isEmpty && _currentSearchQuery.isNotEmpty) {
      _logger.d('No results for search query: $_currentSearchQuery');
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 90,
                color: AppUtils.applyOpacity(theme.colorScheme.onSurface, 0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'No notes match "$_currentSearchQuery"',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppUtils.applyOpacity(
                    theme.colorScheme.onSurface,
                    0.7,
                  ),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Try adjusting your search or adding a new note.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppUtils.applyOpacity(
                    theme.colorScheme.onSurface,
                    0.6,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      _logger.d('Showing notes list (${filteredNotes.length} notes)');
      bodyContent = ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredNotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          final String noteDate = customdateutils.DateUtils.formatShortDate(
            note.createdAt,
          );

          return NoteTile(
            title: note.title,
            content: note.content,
            trailing: Text(
              noteDate,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(
                  150,
                ), // Slightly transparent date text
              ),
            ),
            onTap: () {
              _logger.i('Note tile tapped: ${note.title}');
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(existingNote: note.toMap()),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: QuickJotAppBar(
        searchController: _searchController,
        onSearchChanged: (query) {
          // The _onSearchChanged listener is already attached to the controller,
          // so this explicit callback is not strictly necessary for basic search,
          // but can be used for additional logic if needed.
        },
        onMenuPressed: () {
          _logger.i('Menu button pressed');
          Scaffold.of(context).openDrawer();
        },
        onProfilePressed: _onProfileButtonPressed, // Call the new method
        userDisplayName: _userDisplayName, // Pass user display name
        userEmail: _userEmail, // Pass user email
        userPhotoUrl: _userPhotoUrl, // Pass user photo URL
      ),
      body: bodyContent,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
        onPressed: () {
          _logger.i('New Note button pressed');
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
        },
        tooltip: 'Add a new note',
        heroTag: 'addNoteFab',
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Display user's profile picture in the drawer header
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.onPrimary.withAlpha(100),
                    backgroundImage:
                        _userPhotoUrl?.isNotEmpty == true
                            ? NetworkImage(_userPhotoUrl!)
                            : null,
                    child:
                        _userPhotoUrl?.isEmpty ?? true
                            ? Text(
                              _userDisplayName?.isNotEmpty == true
                                  ? _userDisplayName![0].toUpperCase()
                                  : (_userEmail?.isNotEmpty == true
                                      ? _userEmail![0].toUpperCase()
                                      : 'U'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userDisplayName ?? 'Guest User', // Display user name
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _userEmail ?? 'Not logged in', // Display user email
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withAlpha(200),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Manage Account'),
              onTap: () {
                _logger.i('Drawer: Manage Account tapped');
                Navigator.pop(context); // Close the drawer
                _onProfileButtonPressed(); // Navigate to account management screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                _logger.i('Drawer: Logout tapped');
                if (!mounted) return;
                final navigator = Navigator.of(context);
                Provider.of<NoteProvider>(context, listen: false).dispose();
                await authProvider.logout();
                _logger.i(
                  'Drawer: Logout successful, navigating to LoginScreen',
                );
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
