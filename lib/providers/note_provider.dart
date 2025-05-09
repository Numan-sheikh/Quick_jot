import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  final _noteService = NoteService();
  List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  void fetchNotes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _noteService.getNotes(uid).listen((noteList) {
      _notes = noteList;
      notifyListeners();
    });
  }

  Future<void> addNote(String title, String content) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _noteService.addNote(uid, title, content);
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    await _noteService.updateNote(id, data);
  }

  Future<void> deleteNote(String id) async {
    await _noteService.deleteNote(id);
  }
}
