import 'package:flutter/material.dart'; // Provides core Flutter functionalities, including ChangeNotifier.
import 'package:firebase_auth/firebase_auth.dart'; // Used for authenticating users and getting current user ID.
import '../services/note_service.dart'; // Imports the service responsible for interacting with the backend (e.g., Firestore).
import '../models/note_model.dart'; // Imports the data model for a single note.
import 'dart:async'; // Provides StreamSubscription for listening to real-time data.
import 'package:logger/logger.dart'; // Imports the logger library for detailed logging.

// Create a logger instance for the NoteProvider.
final logger = Logger(); // Logger instance for debugging.

class NoteProvider extends ChangeNotifier {
  final _noteService =
      NoteService(); // Instance of NoteService for data operations.
  List<NoteModel> _notes = []; // Private list to store notes.
  StreamSubscription<List<NoteModel>>?
  _notesSubscription; // Manages stream subscription.
  String? _currentUserId; // Stores the ID of the currently logged-in user.

  // State for initial loading.
  bool _isInitialDataLoaded =
      false; // Tracks if the initial data has been loaded.

  List<NoteModel> get notes => _notes; // Public getter for notes list.
  bool get isInitialDataLoaded =>
      _isInitialDataLoaded; // Public getter for initial loading status.

  NoteProvider() {
    logger.i('NoteProvider instance created'); // Log provider creation.
  }

  /// Initializes the NoteProvider to start listening to notes for a given user.
  /// Only starts a new listener if the user ID changes or if no listener is active.
  /// [uid]: The ID of the currently logged-in user.
  void initialize(String? uid) {
    logger.i(
      'NoteProvider initialize called with UID: $uid',
    ); // Log initialization.

    if (uid == null) {
      logger.w(
        'NoteProvider initialize called with null UID. Cancelling existing subscription if any.',
      ); // Warn if UID is null.
      _notesSubscription?.cancel(); // Cancel any existing subscription.
      _notesSubscription = null; // Clear the subscription.
      _currentUserId = null; // Clear the current user ID.
      _notes = []; // Clear notes if no user.
      _isInitialDataLoaded = false; // Reset initial load state.
      notifyListeners(); // Notify listeners about cleared state.
      return; // Exit if UID is null.
    }

    // Only start listening if the user ID has changed or if we haven't started yet.
    if (_currentUserId != uid || _notesSubscription == null) {
      logger.d(
        'Starting new note stream listener for user: $uid',
      ); // Log new listener.
      _currentUserId = uid; // Set the current user ID.

      // Reset initial load state when starting a new listener for a different user.
      if (_isInitialDataLoaded) {
        _isInitialDataLoaded = false; // Reset the initial data loaded flag.
        logger.d('_isInitialDataLoaded reset to false'); // Log the reset.
      }
      notifyListeners(); // Notify widgets about the loading state change.
      startListeningToNotes(uid); // Begin listening to notes for the new user.
    } else {
      logger.d(
        'Listener already active for user: $_currentUserId. Skipping re-initialization.',
      ); // Log if already active.
    }
  }

  /// Starts listening to the stream of notes for the specified user ID.
  /// Cancels any existing subscription before starting a new one.
  /// [uid]: The ID of the user whose notes are to be fetched.
  void startListeningToNotes(String uid) {
    logger.d(
      'startListeningToNotes called for UID: $uid',
    ); // Log start listening.
    _notesSubscription?.cancel(); // Cancel the existing stream subscription.
    logger.d('Previous notes subscription cancelled'); // Log cancellation.

    _notesSubscription = _noteService
        .getNotes(uid) // Get a stream of notes for the given user ID.
        .listen(
          (noteList) {
            logger.t(
              'Received new note data from stream. Note count: ${noteList.length}',
            ); // Log new data.
            _notes = noteList; // Update the internal list with the new notes.
            logger.d('Internal _notes list updated'); // Log list update.

            // Set initial load state to true after the first snapshot arrives.
            if (!_isInitialDataLoaded) {
              _isInitialDataLoaded = true; // Mark initial data as loaded.
              logger.i('Initial note data loaded.'); // Log initial data loaded.
            }
            notifyListeners(); // Notify widgets that notes or loading state changed.
            logger.t('Listeners notified'); // Log listeners notified.
          },
          onError: (error) {
            logger.e(
              'Error listening to notes stream for UID: $uid',
              error: error,
            ); // Log stream error.
            // Set initial load state to true even on error so the UI doesn't hang on loader.
            if (!_isInitialDataLoaded) {
              _isInitialDataLoaded = true; // Set initial load to true on error.
              logger.w(
                'Setting _isInitialDataLoaded to true after stream error.',
              ); // Warn about error state.
              notifyListeners(); // Notify to show empty state or error message.
            }
          },
          onDone: () {
            logger.i(
              "Notes stream for UID: $uid closed",
            ); // Log stream closure.
          },
        );
    logger.d(
      'Started listening to notes stream for UID: $uid',
    ); // Log stream started.
  }

  /// Disposes of the NoteProvider, cancelling the stream subscription and clearing data.
  @override
  void dispose() {
    logger.i('NoteProvider dispose called'); // Log dispose call.
    _notesSubscription?.cancel(); // Cancel the stream subscription.
    _notesSubscription = null; // Set subscription to null.
    logger.d(
      'Notes stream subscription cancelled and set to null',
    ); // Log subscription cancellation.
    _currentUserId = null; // Clear the current user ID.
    logger.d('currentUserId cleared'); // Log user ID cleared.
    _notes = []; // Clear notes on dispose.
    logger.d('Internal _notes list cleared'); // Log clearing notes list.
    _isInitialDataLoaded = false; // Reset loading state.
    logger.d(
      '_isInitialDataLoaded reset to false',
    ); // Log resetting initial load state.
    super.dispose(); // Call the dispose method of the parent class.
    logger.i('NoteProvider disposed'); // Log NoteProvider disposed.
  }

  /// Adds a new note to the user's collection.
  /// [title]: The title of the note.
  /// [content]: The content of the note.
  /// [colorValue]: The color value of the note. (Optional: default to 0xFFFFFFFF if not provided)
  /// [labels]: The list of labels for the note. (Optional: default to empty list if not provided)
  /// [isPinned]: Whether the note is pinned. (Optional: default to false if not provided)
  Future<void> addNote(
    String title,
    String content, {
    int colorValue = 0xFFFFFFFF,
    List<String> labels = const [],
    bool isPinned = false,
  }) async {
    logger.d(
      'Attempting to add note with title: "$title"',
    ); // Log add note attempt.
    final uid =
        FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID.
    if (uid == null) {
      logger.w(
        'Cannot add note: current user UID is null.',
      ); // Warn if UID is null.
      throw Exception(
        'User not logged in.',
      ); // Throw exception for UI to handle.
    }
    try {
      await _noteService.addNote(
        uid,
        title,
        content,
        colorValue: colorValue,
        labels: labels,
        isPinned: isPinned,
      ); // Add the note with all properties.
      logger.i('Note added successfully for UID: $uid'); // Log success.
    } catch (e) {
      logger.e('Error adding note for UID: $uid', error: e); // Log error.
      rethrow; // Re-throw the error for UI to handle.
    }
  }

  /// Updates an existing note.
  /// [id]: The ID of the note to update.
  /// [data]: A map containing the fields to update.
  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    logger.d(
      'Attempting to update note with ID: $id, data: $data',
    ); // Log update attempt.
    try {
      await _noteService.updateNote(id, data); // Update the note.
      logger.i('Note updated successfully with ID: $id'); // Log success.
    } catch (e) {
      logger.e('Error updating note with ID: $id', error: e); // Log error.
      rethrow; // Re-throw the error for UI to handle.
    }
  }

  /// Deletes a note.
  /// [id]: The ID of the note to delete.
  Future<void> deleteNote(String id) async {
    logger.d('Attempting to delete note with ID: $id'); // Log delete attempt.
    try {
      await _noteService.deleteNote(id); // Delete the note.
      logger.i('Note deleted successfully with ID: $id'); // Log success.
    } catch (e) {
      logger.e('Error deleting note with ID: $id', error: e); // Log error.
      rethrow; // Re-throw the error for UI to handle.
    }
  }

  /// Copies an existing note, creating a new one with "(Copy)" appended to its title.
  /// [noteId]: The ID of the note to copy.
  Future<void> copyNote(String noteId) async {
    logger.d(
      'Attempting to copy note with ID: $noteId',
    ); // Log copy note attempt.
    final uid = FirebaseAuth.instance.currentUser?.uid; // Get current user ID.
    if (uid == null) {
      logger.w(
        'Cannot copy note: current user UID is null.',
      ); // Warn if UID is null.
      throw Exception('User not logged in.'); // Throw exception.
    }

    try {
      // Find the note to copy in the current list.
      final noteToCopy = _notes.firstWhere(
        (note) => note.id == noteId,
      ); // Find the note by ID.

      // Create a new note with the same properties, but modified title.
      await addNote(
        '${noteToCopy.title} (Copy)', // Append "(Copy)" to the title.
        noteToCopy.content, // Use original content.
        colorValue:
            noteToCopy.colorValue ??
            0xFFFFFFFF, // Use original color, default to white if null.
        labels: noteToCopy.labels, // Use original labels.
        isPinned:
            noteToCopy.isPinned, // Use the 'pinned' property from NoteModel.
      );
      logger.i('Note copied successfully from ID: $noteId'); // Log success.
    } catch (e) {
      logger.e('Error copying note with ID: $noteId', error: e); // Log error.
      rethrow; // Re-throw the error for UI to handle.
    }
  }

  // --- Methods for Note Properties ---

  /// Updates the pinned status of a note.
  /// [id]: The ID of the note.
  /// [isPinned]: The new pinned status.
  Future<void> updateNotePinnedStatus(String id, bool isPinned) async {
    logger.d(
      'Attempting to update pinned status for note ID: $id to $isPinned',
    ); // Log update pinned status attempt.
    try {
      await _noteService.updateNote(id, {
        'pinned': isPinned, // Update 'pinned' field to match NoteModel.
      });
      logger.i(
        'Note pinned status updated successfully for ID: $id',
      ); // Log success.
    } catch (e) {
      logger.e(
        'Error updating pinned status for note ID: $id',
        error: e,
      ); // Log error.
      rethrow; // Re-throw the error for UI to handle if needed.
    }
  }

  /// Updates the color of a note.
  /// [id]: The ID of the note.
  /// [colorValue]: The new color value (integer representation).
  Future<void> updateNoteColor(String id, int colorValue) async {
    logger.d(
      'Attempting to update color for note ID: $id to color value: 0x${colorValue.toRadixString(16)}',
    ); // Log update color attempt.
    try {
      await _noteService.updateNote(id, {
        'colorValue': colorValue, // Update 'colorValue' field.
      });
      logger.i('Note color updated successfully for ID: $id'); // Log success.
    } catch (e) {
      logger.e('Error updating color for note ID: $id', error: e); // Log error.
      rethrow; // Re-throw the error for UI to handle if needed.
    }
  }

  /// Updates the labels associated with a note.
  /// [id]: The ID of the note.
  /// [labels]: The new list of labels.
  Future<void> updateNoteLabels(String id, List<String> labels) async {
    logger.d(
      'Attempting to update labels for note ID: $id to $labels',
    ); // Log update labels attempt.
    try {
      await _noteService.updateNote(id, {
        'labels': labels, // Update 'labels' field.
      });
      logger.i('Note labels updated successfully for ID: $id'); // Log success.
    } catch (e) {
      logger.e(
        'Error updating labels for note ID: $id',
        error: e,
      ); // Log error.
      rethrow; // Re-throw the error for UI to handle if needed.
    }
  }
}
