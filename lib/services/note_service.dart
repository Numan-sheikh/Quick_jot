import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'package:logger/logger.dart'; // Import the logger library

// Create a logger instance for the NoteService
final logger = Logger();

class NoteService {
  final _notesCollection = FirebaseFirestore.instance.collection('notes');

  // Constructor (The logger instance is created when NoteService is instantiated)
  NoteService() {
    logger.i('NoteService instance created');
  }

  Stream<List<NoteModel>> getNotes(String uid) {
    logger.d('Setting up notes stream for UID: $uid');
    return _notesCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          // Log when a snapshot is received, but avoid logging every single document transformation
          logger.t(
            'Received Firestore snapshot for UID: $uid with ${snap.docs.length} documents.',
          );
          return snap.docs
              .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
              .toList();
        })
    // Error handling for the stream itself is typically done in the .listen() method
    // in the consumer (like the NoteProvider), as it receives the stream errors.
    ;
  }

  Future<void> addNote(String uid, String title, String content) async {
    logger.d('Attempting to add note for UID: $uid with title: "$title"');
    try {
      final docRef = await _notesCollection.add({
        'userId': uid,
        'title': title,
        'content': content,
        'createdAt': DateTime.now(),
        'pinned': false,
      });
      logger.i('Note added successfully with ID: ${docRef.id}');
    } on FirebaseException catch (e) {
      logger.e('Firebase Exception adding note for UID: $uid', error: e);
      // Rethrow the exception for handling in the calling code (e.g., NoteProvider)
      rethrow;
    } catch (e) {
      logger.e(
        'An unexpected error occurred adding note for UID: $uid',
        error: e,
      );
      // Rethrow any other unexpected errors
      rethrow;
    } finally {
      logger.d('Add note operation finished for UID: $uid');
    }
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    logger.d('Attempting to update note with ID: $id');
    try {
      await _notesCollection.doc(id).update(data);
      logger.i('Note updated successfully with ID: $id');
    } on FirebaseException catch (e) {
      logger.e('Firebase Exception updating note with ID: $id', error: e);
      rethrow;
    } catch (e) {
      logger.e(
        'An unexpected error occurred updating note with ID: $id',
        error: e,
      );
      rethrow;
    } finally {
      logger.d('Update note operation finished for ID: $id');
    }
  }

  Future<void> deleteNote(String id) async {
    logger.d('Attempting to delete note with ID: $id');
    try {
      await _notesCollection.doc(id).delete();
      logger.i('Note deleted successfully with ID: $id');
    } on FirebaseException catch (e) {
      logger.e('Firebase Exception deleting note with ID: $id', error: e);
      rethrow;
    } catch (e) {
      logger.e(
        'An unexpected error occurred deleting note with ID: $id',
        error: e,
      );
      rethrow;
    } finally {
      logger.d('Delete note operation finished for ID: $id');
    }
  }
}
