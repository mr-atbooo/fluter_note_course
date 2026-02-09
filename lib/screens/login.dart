import 'package:flutter/material.dart';
import '../db/notes_db.dart';
import '../models/note_model.dart';

class LoginScreen extends StatefulWidget {
  final Note? note;

  LoginScreen({this.note});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final db = NotesDB();

  int selectedPriority = 1;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content ?? '';
      selectedPriority = widget.note!.priority;
    }
  }

  String priorityLabel(int value) {
    switch (value) {
      case 1:
        return 'Normal';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
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

              SizedBox(height: 16),

              // 🔽 Priority Dropdown
              DropdownButtonFormField<int>(
                value: selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Normal')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('High')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (widget.note == null) {
                    await db.insertNote(
                      Note(
                        title: titleController.text,
                        content: contentController.text,
                        priority: selectedPriority,
                        // createdAt: DateTime.now().toIso8601String(),
                      ),
                    );
                  } else {
                    await db.updateNote(
                      Note(
                        id: widget.note!.id,
                        title: titleController.text,
                        content: contentController.text,
                        priority: selectedPriority,
                        createdAt: widget.note!.createdAt, // نخلي التاريخ ثابت
                      ),
                    );
                  }

                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
