import 'package:flutter/material.dart';
import '../db/notes_db.dart';
import '../models/note_model.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final db = NotesDB();
  List<Note> notes = [];

  void loadNotes() async {
    notes = await db.getNotes();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
          );
          loadNotes();
        },
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await db.deleteNote(note.id!);
                loadNotes();
              },
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditNoteScreen(note: note),
                ),
              );
              loadNotes();
            },
          );
        },
      ),
    );
  }
}
