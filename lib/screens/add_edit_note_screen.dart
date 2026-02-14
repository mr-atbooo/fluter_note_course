import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../db/notes_db.dart';
import '../models/note_model.dart';
import '../services/sound_service.dart';
import '../main.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  AddEditNoteScreen({this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final db = NotesDB();

  DateTime? publishedAt;
  int selectedPriority = 1;

  /// 🔔 Notifications instance
  // final FlutterLocalNotificationsPlugin notifications =
  //     FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    SoundService.stop();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content ?? '';
      selectedPriority = widget.note!.priority;
      publishedAt = widget.note!.publishedAt;
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
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: contentController,
              maxLines: 4, // 👈 عدد الأسطر
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
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
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.schedule),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    publishedAt == null
                        ? 'No publish time selected'
                        : 'Publish at: ${publishedAt!.toLocal()}',
                  ),
                ),
                TextButton(
                  onPressed: pickPublishDateTime,
                  child: Text('Choose'),
                ),
              ],
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
                      publishedAt: publishedAt,
                    ),
                  );
                } else {
                  await db.updateNote(
                    Note(
                      id: widget.note!.id,
                      title: titleController.text,
                      content: contentController.text,
                      priority: selectedPriority,
                      publishedAt: publishedAt,
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),

            ElevatedButton(
              onPressed: () {
                notifications.show(
                  id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                  title: 'Test Notification',
                  body: 'If you see this, notifications work',
                  notificationDetails: NotificationDetails(
                    android: AndroidNotificationDetails(
                      'test_channel',
                      'Test',
                      channelDescription: 'Test notifications',
                      importance: Importance.max,
                      priority: Priority.high,
                      playSound: true,
                    ),
                  ),
                );
              },
              child: const Text('Test Notification'),
            ),

            //             ElevatedButton(
            //   onPressed: () async {
            //     await SoundService.playLinux('ding.wav');
            //   },
            //   child: const Text('🔊 Test Sound'),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> pickPublishDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: publishedAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(publishedAt ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      publishedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }
}
