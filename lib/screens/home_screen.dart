// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:logger/logger.dart';

import '../providers/note_provider.dart';
import '../providers/auth_provider.dart';
import '../core/utils/app_utils.dart';
import '../core/utils/date_utils.dart' as customdateutils;

import '../models/note_model.dart'; // Import NoteModel
import 'login_screen.dart';
import 'note_editor_screen.dart';
import '../widgets/note_tile.dart';
import '../widgets/app_bar.dart';
import 'account_management_screen.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import for color picker dialog

final _logger = Logger(); // Logger instance for logging messages.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search bar.
  String _currentSearchQuery = ''; // Stores the current search query.

  String? _userDisplayName; // Stores the user's display name.
  String? _userEmail; // Stores the user's email.
  String? _userPhotoUrl; // Stores the user's photo URL.

  // New state for note selection: stores IDs of selected notes
  final Set<String> _selectedNoteIds =
      {}; // Set to store IDs of currently selected notes.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the widget is still mounted before executing callback.
      if (!mounted) {
        _logger.w('initState callback executed after widget was disposed.');
        return;
      }
      _initializeUserDataAndNotes(); // Initialize user data and fetch notes.
    });
    _searchController.addListener(
      _onSearchChanged,
    ); // Listen for changes in the search input.
  }

  Future<void> _initializeUserDataAndNotes() async {
    try {
      final noteProvider = Provider.of<NoteProvider>(
        context,
        listen: false,
      ); // Get NoteProvider instance.
      final user =
          FirebaseAuth.instance.currentUser; // Get current Firebase user.

      if (user != null) {
        _logger.i('User logged in: ${user.uid}');
        setState(() {
          _userDisplayName = user.displayName; // Update user display name.
          _userEmail = user.email; // Update user email.
          _userPhotoUrl = user.photoURL; // Update user photo URL.
        });
        _logger.i('Initializing NoteProvider for UID: ${user.uid}');
        noteProvider.initialize(
          user.uid,
        ); // Initialize NoteProvider with user's UID.
      } else {
        _logger.w('User not logged in, navigating to LoginScreen');
        // Ensure the widget is still mounted before navigating.
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ), // Navigate to LoginScreen.
          );
        }
      }
    } catch (e) {
      _logger.e(
        'Error accessing/initializing data in initState callback',
        error: e,
      );
      // Ensure the widget is still mounted before navigating.
      if (mounted) {
        _logger.i('Navigating to LoginScreen after data access error.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ), // Navigate to LoginScreen on error.
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _onSearchChanged,
    ); // Remove listener to prevent memory leaks.
    _searchController.dispose(); // Dispose the search controller.
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentSearchQuery =
          _searchController.text; // Update search query state.
      _logger.d('Search query changed: $_currentSearchQuery');
    });
  }

  void _onProfileButtonPressed() {
    _logger.i('Profile button pressed, navigating to AccountManagementScreen');
    if (!mounted) return; // Check if widget is mounted before navigation.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountManagementScreen(),
      ), // Navigate to Account Management screen.
    );
  }

  // --- Note Selection Logic ---

  // Toggles the selection status of a single note.
  void _toggleNoteSelection(NoteModel note) {
    setState(() {
      if (_selectedNoteIds.contains(note.id)) {
        _selectedNoteIds.remove(note.id); // Remove note from selection.
        _logger.d('Note unselected: ${note.id}');
      } else {
        _selectedNoteIds.add(note.id); // Add note to selection.
        _logger.d('Note selected: ${note.id}');
      }
    });
  }

  // Initiates selection mode by selecting a single note (typically on long-press).
  void _startNoteSelection(NoteModel note) {
    setState(() {
      _selectedNoteIds.clear(); // Clear any previous selection.
      _selectedNoteIds.add(note.id); // Add the long-pressed note to selection.
      _logger.d('Started selection mode with note: ${note.id}');
    });
  }

  // Cancels selection mode and clears all selected notes.
  void _cancelSelection() {
    setState(() {
      _selectedNoteIds.clear(); // Clear all selected notes.
      _logger.d('Selection cancelled.');
    });
  }

  // --- AppBar Action Methods (for selected notes) ---

  // Handles deletion of all currently selected notes.
  Future<void> _deleteSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) {
      return; // Do nothing if no notes are selected.
    }

    final initialContext = context; // Capture context before async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(
      initialContext,
    ); // Get ScaffoldMessenger early.

    final bool? confirm = await showDialog<bool>(
      context: initialContext, // Use the captured context for the dialog.
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete ${_selectedNoteIds.length} Note(s)?', // Dialog title.
          ),
          content: const Text(
            'Are you sure you want to delete the selected note(s)? This cannot be undone.', // Dialog content.
          ),
          actions: <Widget>[
            TextButton(
              onPressed:
                  () =>
                      Navigator.of(dialogContext).pop(false), // Cancel button.
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(
                      dialogContext,
                    ).colorScheme.error, // Red background for delete button.
              ),
              onPressed:
                  () => Navigator.of(dialogContext).pop(true), // Delete button.
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      _logger.w('Widget unmounted after delete confirmation dialog.');
      return; // Exit if widget is unmounted.
    }

    if (confirm == true) {
      _logger.i('User confirmed deletion of ${_selectedNoteIds.length} notes.');
      final noteProvider = Provider.of<NoteProvider>(
        initialContext, // Use the captured context for Provider.
        listen: false,
      ); // Get NoteProvider.
      try {
        for (final id in _selectedNoteIds) {
          await noteProvider.deleteNote(id); // Delete each selected note.
          _logger.d('Deleted note ID: $id');
        }
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            // Use captured ScaffoldMessenger.
            AppUtils.buildSnackBar(
              '${_selectedNoteIds.length} note(s) deleted!', // Show success message.
            ),
          );
        }
        _cancelSelection(); // Exit selection mode after deletion.
      } catch (e) {
        _logger.e('Failed to delete selected notes', error: e);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            // Use captured ScaffoldMessenger.
            AppUtils.buildSnackBar(
              'Failed to delete notes.',
              isError: true, // Indicate an error.
            ),
          );
        }
      }
    } else {
      _logger.d('Deletion of selected notes cancelled.');
    }
  }

  // Handles copying of all currently selected notes.
  Future<void> _copySelectedNotes() async {
    if (_selectedNoteIds.isEmpty) {
      return; // Do nothing if no notes are selected.
    }
    _logger.i('Attempting to copy ${_selectedNoteIds.length} notes.');

    final initialContext = context; // Capture context before async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(
      initialContext,
    ); // Get ScaffoldMessenger early.

    final noteProvider = Provider.of<NoteProvider>(
      initialContext, // Use captured context for Provider.
      listen: false,
    ); // Get NoteProvider.

    // Get the actual NoteModel objects for the selected IDs
    final selectedNotes =
        noteProvider.notes
            .where((note) => _selectedNoteIds.contains(note.id))
            .toList();

    try {
      for (final note in selectedNotes) {
        await noteProvider.copyNote(
          note.id,
        ); // Call copyNote on NoteProvider, passing ID.
        _logger.d('Copied note ID: ${note.id}');
      }
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          // Use captured ScaffoldMessenger.
          AppUtils.buildSnackBar(
            '${_selectedNoteIds.length} note(s) copied!', // Show success message.
          ),
        );
      }
      _cancelSelection(); // Exit selection mode after copying.
    } catch (e) {
      _logger.e('Failed to copy selected notes', error: e);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          // Use captured ScaffoldMessenger.
          AppUtils.buildSnackBar(
            'Failed to copy notes.',
            isError: true, // Show error message.
          ),
        );
      }
    }
  }

  // Handles toggling the pinned status for all currently selected notes.
  Future<void> _togglePinForSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) {
      return; // Do nothing if no notes are selected.
    }
    _logger.i('Attempting to toggle pin for ${_selectedNoteIds.length} notes.');

    final initialContext = context; // Capture context before async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(
      initialContext,
    ); // Get ScaffoldMessenger early.

    final noteProvider = Provider.of<NoteProvider>(
      initialContext, // Use captured context for Provider.
      listen: false,
    ); // Get NoteProvider.

    // Determine the target pinned status: if ANY selected note is UNPINNED, pin them all.
    // Otherwise (if ALL selected notes are already pinned), unpin them all.
    bool shouldPin = false;
    for (final id in _selectedNoteIds) {
      final note = noteProvider.notes.firstWhere(
        (n) => n.id == id,
        orElse:
            () => NoteModel(
              id: '',
              title: '',
              content: '',
              createdAt: DateTime.now(),
              isPinned: false, // Default to unpinned for orElse case.
            ),
      );
      if (!note.isPinned) {
        shouldPin = true; // Found an unpinned note, so we should pin them all.
        break;
      }
    }

    try {
      for (final id in _selectedNoteIds) {
        await noteProvider.updateNotePinnedStatus(
          id,
          shouldPin,
        ); // Update pinned status for each note.
        _logger.d('Toggled pin for note ID: $id to $shouldPin');
      }
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          // Use captured ScaffoldMessenger.
          AppUtils.buildSnackBar(
            '${_selectedNoteIds.length} note(s) ${shouldPin ? 'pinned' : 'unpinned'}!', // Show success message.
          ),
        );
      }
      _cancelSelection(); // Exit selection mode after action.
    } catch (e) {
      _logger.e('Failed to toggle pin for selected notes', error: e);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          // Use captured ScaffoldMessenger.
          AppUtils.buildSnackBar(
            'Failed to toggle pin status.',
            isError: true, // Indicate an error.
          ),
        );
      }
    }
  }

  // Handles setting the background color for all currently selected notes.
  Future<void> _setColorsForSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) {
      return; // Do nothing if no notes are selected.
    }
    _logger.i('Attempting to set color for ${_selectedNoteIds.length} notes.');

    final initialContext = context; // Capture context before async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(
      initialContext,
    ); // Get ScaffoldMessenger early.

    final noteProvider = Provider.of<NoteProvider>(
      initialContext, // Use captured context for Provider.
      listen: false,
    ); // Get NoteProvider.

    // Show a color picker dialog
    Color? selectedColor = await showDialog<Color>(
      context: initialContext, // Use the captured context for the dialog.
      builder: (BuildContext dialogContext) {
        Color tempColor = Colors.blue; // Default color for the picker.
        return AlertDialog(
          title: const Text('Select Color for Notes'), // Dialog title.
          content: SingleChildScrollView(
            child: BlockPicker(
              // Using BlockPicker from flutter_colorpicker
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color; // Update temporary color as user picks.
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed:
                  () => Navigator.of(dialogContext).pop(), // Cancel button.
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  () => Navigator.of(
                    dialogContext,
                  ).pop(tempColor), // Return selected color.
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      _logger.w('Widget unmounted after color picker dialog.');
      return; // Exit if widget is unmounted.
    }

    if (selectedColor != null) {
      try {
        for (final id in _selectedNoteIds) {
          await noteProvider.updateNoteColor(
            id,
            selectedColor
                .toARGB32(), // Pass color as int value (using toARGB32).
          );
          _logger.d(
            'Set color for note ID: $id to ${selectedColor.toARGB32()}',
          );
        }
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            // Use captured ScaffoldMessenger.
            AppUtils.buildSnackBar(
              'Colors updated for ${_selectedNoteIds.length} note(s)!', // Show success message.
            ),
          );
        }
        _cancelSelection(); // Exit selection mode after action.
      } catch (e) {
        _logger.e('Failed to set color for selected notes', error: e);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            // Use captured ScaffoldMessenger.
            AppUtils.buildSnackBar(
              'Failed to set note colors.',
              isError: true, // Indicate an error.
            ),
          );
        }
      }
    } else {
      _logger.d('Color selection cancelled.');
    }
  }

  // Handles assigning labels to all currently selected notes.
  Future<void> _assignLabelsToSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) {
      return; // Do nothing if no notes are selected.
    }
    _logger.i(
      'Attempting to assign labels to ${_selectedNoteIds.length} notes.',
    );

    final initialContext = context; // Capture context before async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(
      initialContext,
    ); // Get ScaffoldMessenger early.

    final noteProvider = Provider.of<NoteProvider>(
      initialContext, // Use captured context for Provider.
      listen: false,
    ); // Get NoteProvider.

    // Get existing labels from the first selected note to pre-populate or suggest
    // For simplicity, we'll just show a text field. A more advanced feature might
    // fetch all unique labels from selected notes or from all notes.
    final TextEditingController labelsDialogController =
        TextEditingController(); // Controller for the labels input field.
    if (_selectedNoteIds.isNotEmpty) {
      // Find the first selected note and pre-fill its labels (or common labels)
      final firstSelectedNote = noteProvider.notes.firstWhere(
        (n) => n.id == _selectedNoteIds.first,
        orElse:
            () => NoteModel(
              id: '',
              title: '',
              content: '',
              createdAt: DateTime.now(),
              labels: [],
            ), // Provide a default if note not found.
      );
      labelsDialogController.text = firstSelectedNote.labels.join(
        ', ',
      ); // Pre-fill with existing labels.
    }

    String? labelsInput = await showDialog<String>(
      context: initialContext, // Use the captured context for the dialog.
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Assign Labels'), // Dialog title.
          content: TextField(
            controller: labelsDialogController, // Text field for label input.
            decoration: const InputDecoration(
              hintText: 'Enter labels (comma-separated)',
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: <Widget>[
            TextButton(
              onPressed:
                  () => Navigator.of(dialogContext).pop(), // Cancel button.
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  () => Navigator.of(
                    dialogContext,
                  ).pop(labelsDialogController.text), // Return entered labels.
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      _logger.w('Widget unmounted after label assignment dialog.');
      return; // Exit if widget is unmounted.
    }

    if (labelsInput != null) {
      // Parse the input string into a list of labels
      final newLabels =
          labelsInput
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(); // Parse comma-separated labels.
      try {
        for (final id in _selectedNoteIds) {
          await noteProvider.updateNoteLabels(
            id,
            newLabels,
          ); // Update labels for each note.
          _logger.d('Set labels for note ID: $id to $newLabels');
        }
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            // Use captured ScaffoldMessenger.
            AppUtils.buildSnackBar(
              'Labels updated for ${_selectedNoteIds.length} note(s)!', // Show success message.
            ),
          );
        }
        _cancelSelection(); // Exit selection mode after action.
      } catch (e) {
        _logger.e('Failed to assign labels to selected notes', error: e);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            // Use captured ScaffoldMessenger.
            AppUtils.buildSnackBar(
              'Failed to assign labels.',
              isError: true, // Indicate an error.
            ),
          );
        }
      }
    } else {
      _logger.d('Label assignment cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(
      context,
    ); // Get NoteProvider for listening.
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    ); // Get AuthProvider.

    final theme = Theme.of(context); // Get current theme.

    // Filter notes based on the current search query
    final List<NoteModel> filteredAndSortedNotes =
        noteProvider.notes.where((note) {
            final titleLower = note.title.toLowerCase(); // Get lowercase title.
            final contentLower =
                note.content.toLowerCase(); // Get lowercase content.
            final searchQueryLower =
                _currentSearchQuery
                    .toLowerCase(); // Get lowercase search query.
            return titleLower.contains(searchQueryLower) ||
                contentLower.contains(
                  searchQueryLower,
                ); // Check if title or content contains search query.
          }).toList()
          ..sort((a, b) {
            // Pinned notes come before unpinned notes
            if (a.isPinned && !b.isPinned) {
              return -1; // 'a' comes before 'b'.
            } else if (!a.isPinned && b.isPinned) {
              return 1; // 'b' comes before 'a'.
            }
            // For notes with the same pinned status, sort by creation date (newest first)
            return b.createdAt.compareTo(
              a.createdAt,
            ); // Sort by creation date (newest first).
          });

    Widget bodyContent; // Widget to display in the body.

    if (!noteProvider.isInitialDataLoaded) {
      _logger.d('Showing loading indicator');
      bodyContent = const Center(
        child: CircularProgressIndicator(),
      ); // Show loading indicator.
    } else if (filteredAndSortedNotes.isEmpty && _currentSearchQuery.isEmpty) {
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
                color: AppUtils.applyOpacity(
                  theme.colorScheme.onSurface,
                  0.4,
                ), // Icon color with opacity.
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
                  if (!mounted) {
                    return; // Check if widget is mounted before navigation.
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NoteEditorScreen(),
                    ), // Navigate to Note Editor.
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Note'),
              ),
            ],
          ),
        ),
      );
    } else if (filteredAndSortedNotes.isEmpty &&
        _currentSearchQuery.isNotEmpty) {
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
                color: AppUtils.applyOpacity(
                  theme.colorScheme.onSurface,
                  0.4,
                ), // Icon color with opacity.
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
      _logger.d('Showing notes list (${filteredAndSortedNotes.length} notes)');
      bodyContent = ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredAndSortedNotes.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(height: 12), // Separator between list items.
        itemBuilder: (context, index) {
          final note = filteredAndSortedNotes[index]; // Current note.
          final String noteDate = customdateutils.DateUtils.formatShortDate(
            note.createdAt,
          );
          final bool isSelected = _selectedNoteIds.contains(
            note.id,
          ); // Check if current note is selected.

          return NoteTile(
            title: note.title,
            content: note.content,
            labels: note.labels,
            isPinned: note.isPinned,
            noteColor: note.noteColor, // Pass the note's color.
            isSelected: isSelected, // Pass selection status to NoteTile.
            trailing:
                isSelected // Only show date if not in selection mode
                    ? null // Hide date when note is selected (to make space for checkmark)
                    : Text(
                      noteDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
            onTap: () {
              _logger.i('Note tile tapped: ${note.title}');
              if (!mounted) return; // Check if widget is mounted.
              if (_selectedNoteIds.isNotEmpty) {
                // If in selection mode, toggle selection
                _toggleNoteSelection(note); // Toggle note selection.
              } else {
                // If not in selection mode, navigate to editor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => NoteEditorScreen(
                          existingNote:
                              note.toMapForEditing(), // Pass existing note data.
                        ),
                  ),
                );
              }
            },
            onLongPress: () {
              _logger.i('Note tile long-pressed: ${note.title}');
              _startNoteSelection(note); // Start selection mode.
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: QuickJotAppBar(
        searchController:
            _searchController, // Pass search controller to AppBar.
        onSearchChanged: (query) {
          // The _onSearchChanged listener is already attached to the controller,
          // so this explicit callback is not strictly necessary for basic search,
          // but can be used for additional logic if needed.
        },
        onMenuPressed: () {
          _logger.i('Menu button pressed');
          Scaffold.of(context).openDrawer(); // Open the drawer.
        },
        onProfilePressed:
            _onProfileButtonPressed, // Callback for profile button.
        userDisplayName: _userDisplayName,
        userEmail: _userEmail,
        userPhotoUrl: _userPhotoUrl,
        // Pass selection state to AppBar
        inSelectionMode:
            _selectedNoteIds.isNotEmpty, // Indicate if in selection mode.
        selectedNotesCount:
            _selectedNoteIds.length, // Number of selected notes.
        onCancelSelection: _cancelSelection, // Callback to cancel selection.
        // Pass specific callbacks for selected notes actions
        onSelectedNotesDelete:
            _deleteSelectedNotes, // Callback for deleting notes.
        onSelectedNotesCopy: _copySelectedNotes, // Callback for copying notes.
        onSelectedNotesLabels:
            _assignLabelsToSelectedNotes, // Callback for assigning labels.
        onSelectedNotesColor:
            _setColorsForSelectedNotes, // Callback for setting colors.
        onSelectedNotesPin:
            _togglePinForSelectedNotes, // Callback for toggling pin status.
      ),
      body: bodyContent, // Display the main content.
      floatingActionButton:
          _selectedNoteIds
                  .isEmpty // Hide FAB when in selection mode
              ? FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('New Note'),
                onPressed: () {
                  _logger.i('New Note button pressed');
                  if (!mounted) {
                    return; // Check if widget is mounted before navigation.
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NoteEditorScreen(),
                    ), // Navigate to Note Editor.
                  );
                },
                tooltip: 'Add a new note',
                heroTag: 'addNoteFab',
              )
              : null, // Hide FAB when in selection mode.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ), // Drawer header background.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.onPrimary.withAlpha(
                      100,
                    ), // Avatar background.
                    backgroundImage:
                        _userPhotoUrl?.isNotEmpty == true
                            ? NetworkImage(
                              _userPhotoUrl!,
                            ) // User's profile image.
                            : null,
                    child:
                        _userPhotoUrl?.isEmpty ?? true
                            ? Text(
                              _userDisplayName?.isNotEmpty == true
                                  ? _userDisplayName![0].toUpperCase()
                                  : (_userEmail?.isNotEmpty == true
                                      ? _userEmail![0].toUpperCase()
                                      : 'U'), // Display first letter of name/email.
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userDisplayName ?? 'Guest User', // Display user name.
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _userEmail ?? 'Not logged in', // Display user email.
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
                Navigator.pop(context); // Close the drawer.
                _onProfileButtonPressed(); // Navigate to account management.
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                _logger.i('Drawer: Logout tapped');
                if (!mounted) {
                  return; // Check if widget is mounted before navigation.
                }
                final navigator = Navigator.of(
                  context,
                ); // Get navigator before async gap.
                Provider.of<NoteProvider>(
                  context,
                  listen: false,
                ).dispose(); // Dispose NoteProvider resources.
                await authProvider.logout(); // Sign out the user.
                _logger.i('User signed out.');
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ), // Navigate to LoginScreen.
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure your AppUtils has a buildSnackBar method that returns a SnackBar widget.
// The showSnackBar method should then use ScaffoldMessenger directly.
// Example of AppUtils.dart:
// class AppUtils {
//   static SnackBar buildSnackBar(String message, {bool isError = false}) {
//     return SnackBar(
//       content: Text(message),
//       backgroundColor: isError ? Colors.red : Colors.green,
//     );
//   }

//   // You can remove this showSnackBar or adapt it to use ScaffoldMessenger internally,
//   // but the direct usage in HomeScreen methods is more robust for async operations.
//   static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       buildSnackBar(message, isError: isError),
//     );
//   }

//   static Color applyOpacity(Color color, double opacity) {
//     return color.withOpacity(opacity);
//   }
// }
