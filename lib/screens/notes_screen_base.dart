// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../db/notes_db.dart';
// import '../models/note_model.dart';
// import 'add_edit_note_screen.dart';

// abstract class NotesScreenBase<T extends StatefulWidget> extends State<T> {
//   final db = NotesDB();
//   List<Note> notes = [];
//   List<Note> filteredNotes = [];

//   DateTime? fromDate;
//   DateTime? toDate;

//   @override
//   void initState() {
//     super.initState();
//     loadNotes();
//   }

//   void loadNotes() async {
//     notes = await db.getNotes();
//     notes.sort((a, b) => b.priority.compareTo(a.priority));
//     filteredNotes = notes;
//     setState(() {});
//   }

//   Future<void> loadByRange(DateTime from, DateTime to) async {
//     filteredNotes = await db.getNotesByDateRange(from: from, to: to);
//     setState(() {});
//   }

//   void filterToday() {
//     final now = DateTime.now();
//     final start = DateTime(now.year, now.month, now.day);
//     final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
//     loadByRange(start, end);
//   }

//   void filterThisWeek() {
//     final now = DateTime.now();
//     final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     final start = DateTime(
//       startOfWeek.year,
//       startOfWeek.month,
//       startOfWeek.day,
//     );
//     final end = start.add(
//       const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
//     );
//     loadByRange(start, end);
//   }

//   void filterThisMonth() {
//     final now = DateTime.now();
//     final start = DateTime(now.year, now.month, 1);
//     final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
//     loadByRange(start, end);
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inMinutes < 60) {
//       return 'منذ ${difference.inMinutes} دقيقة';
//     } else if (difference.inHours < 24) {
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return DateFormat('yyyy/MM/dd').format(date);
//     }
//   }

//   String formatDateTimeExactly(DateTime dateTime) {
//     return DateFormat('yyyy/MM/dd - hh:mm:ss a').format(dateTime);
//   }

//   Color _getNoteColor(Note note) {
//     if (note.priority == 3) {
//       return Colors.red[50]!;
//     } else if (note.priority == 2) {
//       return Colors.orange[50]!;
//     } else {
//       return Colors.green[50]!;
//     }
//   }

//   String _getNoteTitle(Note note) {
//     final width = MediaQuery.of(context).size.width;
    
//     // سطح المكتب: عرض مع التاريخ
//     if (width >= 900) {
//       return '${note.title} (${formatDateTimeExactly(note.publishedAt!)})';
//     }
//     // الموبايل: بدون تاريخ
//     return note.title;
//   }

//   Widget buildNotesList() {
//     return ListView.builder(
//       itemCount: filteredNotes.length,
//       itemBuilder: (context, index) {
//         final note = filteredNotes[index];

//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(16),
//             tileColor: _getNoteColor(note),
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue[100],
//               child: note.priority == 3
//                   ? Icon(
//                       Icons.local_fire_department,
//                       color: Colors.red[700],
//                       size: 20,
//                     )
//                   : Icon(Icons.note, color: Colors.blue[700], size: 20),
//             ),
//             title: Text(
//               _getNoteTitle(note),
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 4),
//                 Text(
//                   note.content ?? '',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//                 if (note.createdAt != null)
//                   Text(
//                     _formatDate(note.createdAt!),
//                     style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                   ),
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(Icons.delete, color: Colors.red),
//               onPressed: () async {
//                 await db.deleteNote(note.id!);
//                 loadNotes();
//               },
//             ),
//             onTap: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AddEditNoteScreen(note: note),
//                 ),
//               );
//               loadNotes();
//             },
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/notes_db.dart';
import '../models/note_model.dart';
import 'add_edit_note_screen.dart';

abstract class NotesScreenBase<T extends StatefulWidget> extends State<T> {
  final db = NotesDB();
  List<Note> notes = [];
  List<Note> filteredNotes = [];

  // متغيرات العد للـ Sidebar
  int totalCount = 0;
  int todayCount = 0;
  int thisWeekCount = 0;
  int thisMonthCount = 0;
  int importantCount = 0;
  int recurringCount = 0;
  int trashCount = 0;

  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    loadNotes();
    loadAllCounts();
  }

  // دالة جديدة لتحميل كل الأعداد
  Future<void> loadAllCounts() async {
    totalCount = await db.getTotalNotesCount();
    todayCount = await db.getTodayNotesCount();
    thisWeekCount = await db.getThisWeekNotesCount();
    thisMonthCount = await db.getThisMonthNotesCount();
    importantCount = await db.getImportantNotesCount();
    recurringCount = await db.getRecurringNotesCount();
    trashCount = await db.getTrashNotesCount();
    
    if (mounted) setState(() {});
  }

  @override
  void loadNotes() async {
    notes = await db.getNotes();
    notes.sort((a, b) => b.priority.compareTo(a.priority));
    filteredNotes = notes;
    
    // تحديث الأعداد بعد تحميل الملاحظات
    await loadAllCounts();
    
    if (mounted) setState(() {});
  }

  Future<void> loadByRange(DateTime from, DateTime to) async {
    filteredNotes = await db.getNotesByDateRange(from: from, to: to);
    
    // تحديث الأعداد بعد تغيير التصفية
    await loadAllCounts();
    
    if (mounted) setState(() {});
  }

  void filterToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    loadByRange(start, end);
  }

  void filterThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    loadByRange(start, end);
  }

  void filterThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    loadByRange(start, end);
  }

  // دوال التصفية الإضافية
  void filterImportant() async {
    filteredNotes = notes.where((note) => note.priority == 3).toList();
    if (mounted) setState(() {});
  }

  void filterRecurring() async {
    filteredNotes = notes.where((note) => note.publishedAt == null).toList();
    if (mounted) setState(() {});
  }

  void filterTrash() async {
    // حالياً لا يوجد ملاحظات محذوفة
    filteredNotes = [];
    if (mounted) setState(() {});
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
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  String formatDateTimeExactly(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd - hh:mm:ss a').format(dateTime);
  }

  Color _getNoteColor(Note note) {
    if (note.priority == 3) {
      return Colors.red[50]!;
    } else if (note.priority == 2) {
      return Colors.orange[50]!;
    } else {
      return Colors.green[50]!;
    }
  }

  String _getNoteTitle(Note note) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 900) {
      return '${note.title} (${formatDateTimeExactly(note.publishedAt!)})';
    }
    return note.title;
  }

  Widget buildNotesList() {
    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد ملاحظات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            tileColor: _getNoteColor(note),
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
              _getNoteTitle(note),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                    _formatDate(note.createdAt!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red[700]),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text('هل أنت متأكد من حذف هذه الملاحظة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await db.deleteNote(note.id!);
                  loadNotes();
                }
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
    );
  }
}