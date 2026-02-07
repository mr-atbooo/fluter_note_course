import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // void loadNotes() async {
  //   notes = await db.getNotes();
  //   setState(() {});
  // }

  void loadNotes() async {
    notes = await db.getNotes();

    notes.sort((a, b) {
      return b.priority.compareTo(a.priority);
    });

    // filteredNotes = notes;
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
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              tileColor: _getNoteColor(note),
              // tileColor: Colors.grey[200],
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: note.priority == 3
                    ? Icon(
                        Icons.local_fire_department,
                        color: Colors.red[700],
                        size: 20,
                      )
                    : Icon(Icons.note, color: Colors.blue[700], size: 20),
              ),
              title: Text(
                getDeviceSpecificNoteTitle(note),
                // '${note.title} (${formatDateTimeExactly(note.createdAt)})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // subtitle: Text(note.content ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    note.content ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (note.createdAt != null)
                    Text(
                      _formatDate(DateTime.parse(note.createdAt)),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
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
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String formatDateTimeExactly(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy/MM/dd - hh:mm:ss a').format(dateTime);
    // hh صغيرة = 12 ساعة
    // HH كبيرة = 24 ساعة
  }

  Color _getNoteColor(Note note) {
    // يمكنك استخدام أي منطق لتحديد اللون

    // 1. حسب الأولوية
    if (note.priority == 3) {
      return Colors.red[50]!;
    } else if (note.priority == 2) {
      return Colors.orange[50]!;
    } else {
      return Colors.green[50]!;
    }

    // 2. حسب الفئة
    // switch (note.category?.toLowerCase()) {
    //   case 'work':
    //     return Colors.blue[50]!;
    //   case 'personal':
    //     return Colors.purple[50]!;
    //   case 'important':
    //     return Colors.yellow[50]!;
    //   default:
    //     return Colors.grey[50]!;
    // }

    // 3. حسب الحالة
    // if (note.isCompleted) {
    //   return Colors.green[50]!;
    // } else {
    //   return Colors.red[50]!;
    // }

    // 4. ألوان متدرجة حسب الـ index
    // final colors = [
    //   Colors.blue[50]!,
    //   Colors.green[50]!,
    //   Colors.yellow[50]!,
    //   Colors.purple[50]!,
    //   Colors.pink[50]!,
    // ];
    // return colors[note.id! % colors.length];
  }

  String getDeviceSpecificNoteTitle(Note note) {
    print(Platform.isLinux);

    final screenWidth = MediaQuery.of(context).size.width;

    if (kIsWeb) {
      // إذا كان تطبيق ويب
      return '${note.title} (${formatDateTimeExactly(note.createdAt)})';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (screenWidth < 600) {
        // تابلت: بدون التاريخ
        return note.title;
      } else {
        // إذا كان ديسكتوب
        return '${note.title} (${formatDateTimeExactly(note.createdAt)})';
      }
    } else {
      // إذا كان موبايل (Android, iOS)
      return note.title; // بدون التاريخ
    }
  }
}
