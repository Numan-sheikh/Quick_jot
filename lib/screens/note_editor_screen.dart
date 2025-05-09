import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!['title'] ?? '';
      _contentController.text = widget.existingNote!['content'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNote != null;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Note' : 'New Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          final title = _titleController.text.trim();
          final content = _contentController.text.trim();

          if (title.isEmpty && content.isEmpty) return;

          final navigator = Navigator.of(context); // extract before await

          if (isEditing) {
            final docId = widget.existingNote!['id'];
            await noteProvider.updateNote(docId, {
              'title': title,
              'content': content,
            });
          } else {
            await noteProvider.addNote(title, content);
          }

          navigator.pop(); // safe usage after await
        },
      ),
    );
  }
}
