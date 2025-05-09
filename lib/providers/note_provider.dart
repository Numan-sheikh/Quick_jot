import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';
import 'dart:async';
import 'package:logger/logger.dart'; // Import the logger library

// Create a logger instance for the NoteProvider
final logger = Logger();

class NoteProvider extends ChangeNotifier {
  final _noteService = NoteService();
  List<NoteModel> _notes = [];
  StreamSubscription<List<NoteModel>>? _notesSubscription;
  String? _currentUserId;

  // Add state for initial loading
  bool _isInitialDataLoaded = false;

  List<NoteModel> get notes => _notes;
  // Getter for initial loading state
  bool get isInitialDataLoaded => _isInitialDataLoaded;

  // Constructor (optional, but good place for initial logging if needed)
  NoteProvider() {
    logger.i('NoteProvider instance created');
  }

  void initialize(String uid) {
    logger.i('NoteProvider initialize called with UID: $uid');
    // Only start listening if the user ID has changed or if we haven't started yet
    if (_currentUserId != uid || _notesSubscription == null) {
      logger.d('Starting new note stream listener for user: $uid');
      _currentUserId = uid;
      // Reset initial load state when starting a new listener
      if (_isInitialDataLoaded) {
        _isInitialDataLoaded = false;
        logger.d('_isInitialDataLoaded reset to false');
      }
      notifyListeners(); // Notify listeners about the loading state change
      startListeningToNotes(uid);
    } else {
      logger.d(
        'Listener already active for user: $_currentUserId. Skipping re-initialization.',
      );
    }
    // If called with the same UID and subscription is active, do nothing.
  }

  void startListeningToNotes(String uid) {
    logger.d('startListeningToNotes called for UID: $uid');
    // Cancel any previous subscription before starting a new one
    _notesSubscription?.cancel();
    logger.d('Previous notes subscription cancelled');

    _notesSubscription = _noteService
        .getNotes(uid)
        .listen(
          (noteList) {
            logger.t(
              'Received new note data from stream. Note count: ${noteList.length}',
            );
            // This block is executed whenever the data changes in Firestore
            _notes = noteList; // Update the internal list
            logger.d('Internal _notes list updated');
            // Set initial load state to true after the first snapshot arrives
            if (!_isInitialDataLoaded) {
              _isInitialDataLoaded = true;
              logger.i('Initial note data loaded.');
            }
            notifyListeners(); // Notify widgets that notes or loading state changed
            logger.t('Listeners notified');
          },
          onError: (error) {
            logger.e(
              'Error listening to notes stream for UID: $uid',
              error: error,
            );
            // Consider showing user feedback, e.g., a SnackBar
            // Also, set initial load state to true even on error so the UI doesn't hang on loader
            if (!_isInitialDataLoaded) {
              _isInitialDataLoaded = true;
              logger.w(
                'Setting _isInitialDataLoaded to true after stream error.',
              );
              notifyListeners(); // Notify to show empty state or error message
            }
          },
          // Optional: onDone callback
          onDone: () {
            logger.i("Notes stream for UID: $uid closed");
          },
        );
    logger.d('Started listening to notes stream for UID: $uid');
  }

  // ** CRUCIAL: Implement the dispose method to cancel the subscription **
  @override
  void dispose() {
    logger.i('NoteProvider dispose called');
    // Cancel the stream subscription when the provider is disposed
    _notesSubscription?.cancel();
    _notesSubscription = null; // Set to null
    logger.d('Notes stream subscription cancelled and set to null');
    _currentUserId = null; // Clear the user ID
    logger.d('currentUserId cleared');
    _notes = []; // Clear notes on dispose
    logger.d('Internal _notes list cleared');
    _isInitialDataLoaded = false; // Reset loading state
    logger.d('_isInitialDataLoaded reset to false');
    // No need to call notifyListeners() here as the provider is being disposed
    super.dispose();
    logger.i('NoteProvider disposed');
  }

  // Your other methods remain largely the same, but now they don't need
  // to call notifyListeners() after modifying data via _noteService,
  // because the stream listener will automatically pick up the changes.

  Future<void> addNote(String title, String content) async {
    logger.d('Attempting to add note with title: "$title"');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      logger.w('Cannot add note: current user UID is null.');
      return;
    }
    try {
      await _noteService.addNote(uid, title, content);
      logger.i('Note added successfully for UID: $uid');
      // The stream listener in startListeningToNotes will pick up this change
      // and call notifyListeners(), so no need to call it here.
    } catch (e) {
      logger.e('Error adding note for UID: $uid', error: e);
      // Handle error, maybe show a SnackBar
    }
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    logger.d('Attempting to update note with ID: $id, data: $data');
    try {
      await _noteService.updateNote(id, data);
      logger.i('Note updated successfully with ID: $id');
      // The stream listener will pick up this change
    } catch (e) {
      logger.e('Error updating note with ID: $id', error: e);
      // Handle error
    }
  }

  Future<void> deleteNote(String id) async {
    logger.d('Attempting to delete note with ID: $id');
    try {
      await _noteService.deleteNote(id);
      logger.i('Note deleted successfully with ID: $id');
      // The stream listener will pick up this change
    } catch (e) {
      logger.e('Error deleting note with ID: $id', error: e);
      // Handle error
    }
  }
}
