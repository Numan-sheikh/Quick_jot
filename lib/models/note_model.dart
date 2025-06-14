// models/note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Add this import for `Color`

class NoteModel {
  String id;
  String title;
  String content;
  DateTime createdAt;
  bool isPinned; // Renamed from 'pinned'
  List<String> labels;
  int? colorValue; // Stores the ARGB integer value of the color

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isPinned = false, // Renamed in constructor parameter
    this.labels = const [],
    this.colorValue, // Make it optional
  });

  // Getter to convert the stored integer color value back to a Flutter Color object.
  // Defaults to white if no color is set.
  Color get noteColor => colorValue != null ? Color(colorValue!) : Colors.white;

  // Factory constructor to create a NoteModel from a Firestore DocumentSnapshot.
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data for ID ${doc.id} is null.");
    }
    return NoteModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Note',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: data['isPinned'] as bool? ?? false, // Retrieve 'isPinned'
      labels: List<String>.from(data['labels'] as List? ?? []),
      colorValue: data['colorValue'] as int?, // Retrieve color value
    );
  }

  // Method to convert the NoteModel object to a Map for saving/updating in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPinned': isPinned, // Include 'isPinned' when saving
      'labels': labels,
      'colorValue': colorValue, // Include color value when saving
    };
  }

  // A method to convert the NoteModel to a Map *including its ID*,
  // for passing to other screens like NoteEditorScreen.
  Map<String, dynamic> toMapForEditing() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned, // Include 'isPinned'
      'labels': labels,
      'colorValue': colorValue, // Include color value
    };
  }

  // Helper method to create a new NoteModel with updated properties.
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isPinned, // Renamed in copyWith parameter
    List<String>? labels,
    int? colorValue,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned, // Use 'isPinned'
      labels: labels ?? this.labels,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
