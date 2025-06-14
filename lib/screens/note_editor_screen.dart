// screens/note_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import color picker

import '../providers/note_provider.dart';
import '../core/utils/app_utils.dart';

final _logger = Logger();

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _labelsController = TextEditingController();
  String? _docId;
  bool _isNewNote = true;
  bool _isPinned = false;
  Color _noteColor = Colors.white; // Default note color

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _isNewNote = false;
      _docId = widget.existingNote!['id'];
      _titleController.text = widget.existingNote!['title'] ?? '';
      _contentController.text = widget.existingNote!['content'] ?? '';
      _isPinned = widget.existingNote!['pinned'] as bool? ?? false;

      final List<String> existingLabels = List<String>.from(
        widget.existingNote!['labels'] as List? ?? [],
      );
      _labelsController.text = existingLabels.join(', ');

      // Initialize note color from existingNote or default to white
      _noteColor =
          widget.existingNote!['colorValue'] != null
              ? Color(widget.existingNote!['colorValue'] as int)
              : Colors.white;

      _logger.d('Editing existing note: $_docId');
    } else {
      _logger.d('Creating new note.');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _labelsController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final labels =
        _labelsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (title.isEmpty && content.isEmpty) {
      _logger.w('Save attempt: Title and content are empty. Showing snackbar.');
      AppUtils.showSnackBar(context, 'Note cannot be empty!', isError: true);
      return;
    }

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (_isNewNote) {
        _logger.i('Attempting to add new note.');
        await noteProvider.addNote(
          title,
          content,
          labels: labels,
          isPinned: _isPinned,
          colorValue: _noteColor.value, // Pass color value
        );
        AppUtils.showSnackBar(context, 'Note added!');
      } else {
        if (_docId == null) {
          _logger.e('Error: Attempted to edit a note with a null document ID.');
          AppUtils.showSnackBar(
            context,
            'Error: Cannot edit note without an ID.',
            isError: true,
          );
          return;
        }
        _logger.i('Attempting to update note: $_docId');
        await noteProvider.updateNote(_docId!, {
          'title': title,
          'content': content,
          'pinned': _isPinned,
          'labels': labels,
          'colorValue': _noteColor.value, // Include color value in update
          'createdAt':
              widget
                  .existingNote!['createdAt'], // Keep original createdAt for existing notes
        });
        AppUtils.showSnackBar(context, 'Note updated!');
      }
      _logger.i('Note saved successfully. Navigating back.');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e('Error saving note', error: e);
      AppUtils.showSnackBar(context, 'Failed to save note.', isError: true);
    }
  }

  // Method to show color picker dialog
  Future<void> _showColorPickerDialog() async {
    Color tempColor = _noteColor; // Temporarily hold selected color for dialog
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Note Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              // Use BlockPicker from flutter_colorpicker
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color; // Update temporary color
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(tempColor); // Confirm selection
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      setState(() {
        _noteColor = selectedColor; // Update note color
        _logger.d('Note color set to: $_noteColor');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _noteColor.withAlpha(175), // Apply note background color
      appBar: AppBar(
        title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
        backgroundColor: _noteColor.withAlpha(
          128,
        ), // Apply a slightly opaque version to app bar too
        actions: [
          // Pin/Unpin Button
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color:
                  _isPinned
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
                _logger.d('Pinned status toggled: $_isPinned');
              });
            },
            tooltip: _isPinned ? 'Unpin Note' : 'Pin Note',
          ),
          // Color Picker Button
          IconButton(
            icon: Icon(
              Icons.palette,
              color:
                  _noteColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
            ), // Dynamic icon color for contrast
            onPressed: _showColorPickerDialog,
            tooltip: 'Set Note Color',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            TextField(
              controller: _labelsController,
              decoration: InputDecoration(
                hintText: 'Add labels (e.g., work, personal, ideas)',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              style: theme.textTheme.bodyMedium,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
