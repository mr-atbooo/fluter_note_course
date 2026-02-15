// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import '../models/note_model.dart';

// class NotesDB {
//   static Database? _db;

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   Future<Database> initDB() async {
//     // String path = join(await getDatabasesPath(), 'notes.db');

//     final directory = await getApplicationDocumentsDirectory();
//     final path = join(directory.path, 'my_notes.db');

//     return await openDatabase(
//       path,
//       version: 3,
//       onCreate: (db, version) async {
//         await db.execute('''
//         CREATE TABLE notes (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           title TEXT,
//           content TEXT,
//           priority INTEGER DEFAULT 1,
//           published_at TEXT,
//           is_published INTEGER DEFAULT 0,
//           created_at TEXT,
//           updated_at TEXT
//         )
//       ''');
//       },
//       // onUpgrade: (db, oldVersion, newVersion) async {
//       //   if (oldVersion < 2) {
//       //     await db.execute(
//       //       'ALTER TABLE notes ADD COLUMN priority INTEGER DEFAULT 1',
//       //     );
//       //     await db.execute('ALTER TABLE notes ADD COLUMN created_at TEXT');
//       //   }
//       //   if (oldVersion < 3) {
//       //     await db.execute('ALTER TABLE notes ADD COLUMN updated_at TEXT');
//       //   }
//       // },
//     );
//   }

//   // 📋 Get All
//   Future<List<Note>> getNotes() async {
//     final db = await database;
//     // final result = await db.query('notes');

//     final result = await db.query(
//       'notes',
//       orderBy: 'priority DESC, created_at DESC',
//     );

//     return result.map((e) => Note.fromMap(e)).toList();
//   }

//   Future<List<Note>> getTodayNotes() async {
//     final db = await database;

//     final today = DateTime.now();
//     final startOfDay = DateTime(today.year, today.month, today.day);
//     final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

//     final result = await db.query(
//       'notes',
//       // where: 'published_at BETWEEN ? AND ?',
//       where: '(published_at BETWEEN ? AND ?) OR published_at IS NULL',

//       whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
//       orderBy: 'priority DESC, created_at DESC',
//     );

//     return result.map((e) => Note.fromMap(e)).toList();
//   }

//   Future<List<Note>> getNotesByDateRange({
//     DateTime? from,
//     DateTime? to,
//     bool includeDaily = true,
//   }) async {
//     final db = await database;

//     String whereClause = '';
//     List<dynamic> whereArgs = [];

//     if (from != null && to != null) {
//       whereClause = 'published_at BETWEEN ? AND ?';
//       whereArgs = [from.toIso8601String(), to.toIso8601String()];

//       if (includeDaily) {
//         whereClause = '($whereClause) OR published_at IS NULL';
//       }
//     }

//     final result = await db.query(
//       'notes',
//       where: whereClause.isEmpty ? null : whereClause,
//       whereArgs: whereArgs.isEmpty ? null : whereArgs,
//       orderBy: 'priority DESC, created_at DESC',
//     );

//     return result.map((e) => Note.fromMap(e)).toList();
//   }

//   // ➕ Insert
//   Future<int> insertNote(Note note) async {
//     final db = await database;
//     final now = DateTime.now().toIso8601String();

//     print('Inserting note: ${note.toMap()}');

//     // return await db.insert('notes', note.toMap());
//     return await db.insert('notes', {
//       ...note.toMap(),
//       'created_at': now, // ✅ يُضاف تلقائياً
//       'updated_at': now, // ✅ يمكن إضافته هنا أيضاً كقيمة أولية
//     });
//   }

//   // ✏️ Update
//   Future<int> updateNote(Note note) async {
//     final db = await database;
//     final now = DateTime.now().toIso8601String();

//     return await db.update(
//       'notes',
//       // note.toMap(),
//       {...note.toMap(), 'updated_at': now},
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//   }

//   // 🗑️ Delete
//   Future<int> deleteNote(int id) async {
//     final db = await database;
//     return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<List<Map<String, dynamic>>> getDueNotifications(String nowIso) async {
//     final db = await database;

//     return await db.rawQuery(
//       '''
//     SELECT * FROM notes
//     WHERE published_at IS NOT NULL
//     AND published_at <= ?
//     AND is_published = 0
//   ''',
//       [nowIso],
//     );
//   }

//   Future<void> markAsNotified(int id) async {
//     final db = await database;
//     await db.update(
//       'notes',
//       {'is_published': 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class NotesDB {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'my_notes.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          priority INTEGER DEFAULT 1,
          published_at TEXT,
          is_published INTEGER DEFAULT 0,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
      },
    );
  }

  // =============== دوال العد الجديدة ===============

  Future<int> getTotalNotesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTodayNotesCount() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE published_at BETWEEN ? AND ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getThisWeekNotesCount() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE published_at BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getThisMonthNotesCount() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE published_at BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getImportantNotesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE priority = 3',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getRecurringNotesCount() async {
    // هنا يمكنك تحديد معيارك للملاحظات المتكررة
    // مثلاً: الملاحظات التي ليس لها تاريخ نشر (published_at IS NULL)
    // أو أي معيار آخر تختاره
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE published_at IS NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTrashNotesCount() async {
    // إذا كان لديك حقل is_deleted في المستقبل
    // حالياً نرجع 0 لأنه لا يوجد سلة محذوفات
    return 0;
  }

  // =============== الدوال الموجودة ===============

  Future<List<Note>> getNotes() async {
    final db = await database;
    final result = await db.query(
      'notes',
      orderBy: 'priority DESC, created_at DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<List<Note>> getTodayNotes() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final result = await db.query(
      'notes',
      where: '(published_at BETWEEN ? AND ?) OR published_at IS NULL',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'priority DESC, created_at DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<List<Note>> getNotesByDateRange({
    DateTime? from,
    DateTime? to,
    bool includeDaily = true,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (from != null && to != null) {
      whereClause = 'published_at BETWEEN ? AND ?';
      whereArgs = [from.toIso8601String(), to.toIso8601String()];

      if (includeDaily) {
        whereClause = '($whereClause) OR published_at IS NULL';
      }
    }

    final result = await db.query(
      'notes',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'priority DESC, created_at DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return await db.insert('notes', {
      ...note.toMap(),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return await db.update(
      'notes',
      {...note.toMap(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getDueNotifications(String nowIso) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT * FROM notes
      WHERE published_at IS NOT NULL
      AND published_at <= ?
      AND is_published = 0
      ''',
      [nowIso],
    );
  }

  Future<void> markAsNotified(int id) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_published': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}