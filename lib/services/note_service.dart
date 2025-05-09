import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NoteService {
  final _notesCollection = FirebaseFirestore.instance.collection('notes');

  Stream<List<NoteModel>> getNotes(String uid) {
    return _notesCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<void> addNote(String uid, String title, String content) async {
    await _notesCollection.add({
      'userId': uid,
      'title': title,
      'content': content,
      'createdAt': DateTime.now(),
      'pinned': false,
    });
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    await _notesCollection.doc(id).update(data);
  }

  Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }
}
