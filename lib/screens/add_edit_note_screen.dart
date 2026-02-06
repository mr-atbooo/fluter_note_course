import 'package:flutter/material.dart';
import '../db/notes_db.dart';
import '../models/note_model.dart';

class AddEditNoteScreen extends StatelessWidget {
  final Note? note;
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final db = NotesDB();

  AddEditNoteScreen({this.note}) {
    if (note != null) {
      titleController.text = note!.title;
      contentController.text = note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (note == null) {
                  await db.insertNote(
                    Note(
                      title: titleController.text,
                      content: contentController.text,
                    ),
                  );
                } else {
                  await db.updateNote(
                    Note(
                      id: note!.id,
                      title: titleController.text,
                      content: contentController.text,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
