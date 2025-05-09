import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Hide AuthProvider from firebase_auth to avoid name conflict with your local AuthProvider
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../providers/note_provider.dart';
import '../providers/auth_provider.dart'; // Your local AuthProvider
import 'login_screen.dart';
import 'note_editor_screen.dart';
import '../widgets/note_tile.dart'; // Import custom NoteTile widget
// Import the logger package
import 'package:logger/logger.dart';

// Create a logger instance
final _logger = Logger();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the NoteProvider starts listening to the Firestore stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before accessing context or providers
      if (!mounted) {
        _logger.w('initState callback executed after widget was disposed.');
        return;
      }

      try {
        // Use listen: false because we are only calling a method (initialize)
        // Attempt to access the provider. This might throw if disposed.
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          // Log that the provider is being initialized
          _logger.i('Initializing NoteProvider for UID: $uid');
          // Initialize the NoteProvider to start the stream listener
          noteProvider.initialize(uid);
        } else {
          // Log that the user is not logged in and navigation is happening
          _logger.w('User not logged in, navigating to LoginScreen');
          if (mounted) {
            // Check mounted before navigating
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        }
      } catch (e) {
        // Catch the error if the provider is disposed or not found
        // Log this error properly
        _logger.e(
          'Error accessing/initializing NoteProvider in initState callback',
          error: e,
        );
        // If the provider is disposed, it likely means the user is logging out
        // or the auth state changed, so navigating to login might be appropriate.
        // Ensure mounted check before navigation in catch block
        if (mounted) {
          _logger.i(
            'Navigating to LoginScreen after NoteProvider access error.',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the NoteProvider for updates.
    final noteProvider = Provider.of<NoteProvider>(context);
    // AuthProvider is used here but not listened to, so listen: false is correct.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final theme = Theme.of(context);

    // Determine what to display based on initial loading state and note list
    Widget bodyContent;
    // Check if initial data is loaded from the provider (assuming NoteProvider has isInitialDataLoaded getter)
    if (!noteProvider.isInitialDataLoaded) {
      // Log when showing the loading indicator
      _logger.d('Showing loading indicator');
      // Show a loader while the initial data is being fetched by the provider
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (noteProvider.notes.isEmpty) {
      // Log when showing the empty state
      _logger.d('Showing empty state');
      // Show the empty state message if no notes are found after initial load
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notes_rounded,
                size: 80,
                color: theme.colorScheme.onSurface.withAlpha(102),
              ),
              const SizedBox(height: 20),
              Text(
                'No notes yet!',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the button below to add your first note.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(127),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      // Log when showing the list of notes
      _logger.d('Showing notes list (${noteProvider.notes.length} notes)');
      // Show the list of notes once data is loaded and the list is not empty
      bodyContent = ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: noteProvider.notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = noteProvider.notes[index];
          return NoteTile(
            title: note.title,
            content: note.content,
            // Pass the color if you added it to NoteModel and NoteTile
            // noteColor: Color(note.colorValue), // Example if note has a colorValue field
            onTap: () {
              // Log the tap event
              _logger.i('Note tile tapped: ${note.title}');
              // Check if the widget is still mounted before navigating
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(existingNote: note.toMap()),
                ),
              );
              // The realtime listener in NoteProvider handles UI updates automatically.
            },
            // Implement swipe to delete or other actions in NoteTile if desired
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Notes',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Log the logout attempt
              _logger.i('Attempting logout');
              // Check if the widget is still mounted before navigating
              if (!mounted) return;

              final navigator = Navigator.of(context);
              // Dispose the NoteProvider before logging out to cancel the Firestore stream listener
              _logger.i('Disposing NoteProvider');
              Provider.of<NoteProvider>(context, listen: false).dispose();

              await authProvider.logout();
              _logger.i('Logout successful, navigating to LoginScreen');

              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: bodyContent, // Use the determined content based on state
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
        onPressed: () {
          // Log the new note button press
          _logger.i('New Note button pressed');
          // Check if the widget is still mounted before navigating
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
          // The realtime listener in NoteProvider handles UI updates automatically.
        },
        tooltip: 'Add a new note',
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
