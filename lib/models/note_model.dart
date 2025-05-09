import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String title;
  String content;
  DateTime createdAt;
  bool pinned;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.pinned = false,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> data) {
    return NoteModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      pinned: data['pinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'pinned': pinned,
    };
  }
}
