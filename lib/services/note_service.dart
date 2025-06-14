// services/note_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NoteService {
  final _notesCollection = FirebaseFirestore.instance.collection('notes');

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
          logger.t(
            'Received Firestore snapshot for UID: $uid with ${snap.docs.length} documents.',
          );
          return snap.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
        });
  }

  // Updated addNote to accept colorValue
  Future<void> addNote(
    String uid,
    String title,
    String content, {
    List<String> labels = const [],
    bool pinned = false,
    int? colorValue, required bool isPinned,
  }) async {
    logger.d(
      'Attempting to add note for UID: $uid with title: "$title", labels: $labels, pinned: $pinned, color: $colorValue',
    );
    try {
      final docRef = await _notesCollection.add({
        'userId': uid,
        'title': title,
        'content': content,
        'createdAt': DateTime.now(),
        'pinned': pinned,
        'labels': labels,
        'colorValue': colorValue, // Include color here
      });
      logger.i('Note added successfully with ID: ${docRef.id}');
    } on FirebaseException catch (e) {
      logger.e('Firebase Exception adding note for UID: $uid', error: e);
      rethrow;
    } catch (e) {
      logger.e(
        'An unexpected error occurred adding note for UID: $uid',
        error: e,
      );
      rethrow;
    } finally {
      logger.d('Add note operation finished for UID: $uid');
    }
  }

  // updateNote already accepts a Map, so it will handle 'colorValue' if passed
  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    logger.d('Attempting to update note with ID: $id, data: $data');
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
