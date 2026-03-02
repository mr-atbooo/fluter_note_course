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
      version: 4,
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
          updated_at TEXT,
          repeat_type TEXT DEFAULT 'none',
          repeat_days TEXT,
          repeat_interval INTEGER,
          vibrate INTEGER DEFAULT 1,
          sound TEXT,
          last_notified TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // إضافة الحقول الجديدة
          await db.execute(
            'ALTER TABLE notes ADD COLUMN repeat_type TEXT DEFAULT "none"',
          );
          await db.execute('ALTER TABLE notes ADD COLUMN repeat_days TEXT');
          await db.execute(
            'ALTER TABLE notes ADD COLUMN repeat_interval INTEGER',
          );
          await db.execute(
            'ALTER TABLE notes ADD COLUMN vibrate INTEGER DEFAULT 1',
          );
          await db.execute('ALTER TABLE notes ADD COLUMN sound TEXT');
          await db.execute('ALTER TABLE notes ADD COLUMN last_notified TEXT');
        }
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
    final regularCount = Sqflite.firstIntValue(result) ?? 0;
    // final repeatCount = await getRecurringNotesCount();

    // return regularCount + repeatCount;
    return regularCount;
  }

  Future<int> getThisWeekNotesCount() async {
    final db = await database;
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
      "SELECT COUNT(*) as count FROM notes WHERE repeat_type != 'none' AND repeat_type != 'null'",
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

  Future<List<Note>> getTodayNotesWith() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    print('📅 Getting today notes at: ${now.hour}:${now.minute}');

    List<Note> todayNotes = [];

    // 1️⃣ الملاحظات العادية (اللي ليها تاريخ النهارده)
    final regularResult = await db.query(
      'notes',
      where: 'published_at BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'priority DESC, created_at DESC',
    );

    todayNotes.addAll(regularResult.map((e) => Note.fromMap(e)));
    print('📝 Regular notes today: ${regularResult.length}');

    // 2️⃣ الملاحظات المتكررة (كل اللي نوعها مش none)
    final repeatResult = await db.query(
      'notes',
      where: "repeat_type != 'none'",
    );

    int repeatAdded = 0;
    for (var noteMap in repeatResult) {
      final note = Note.fromMap(noteMap);

      // نتأكد إن عندها وقت
      if (note.publishedAt != null) {
        final noteTime = note.publishedAt!;

        // هل الوقت ده مناسب للعرض النهارده؟
        bool shouldShowToday = false;

        switch (note.repeatType) {
          case 'daily':
            // يومياً: يظهر كل يوم (بغض النظر عن التاريخ)
            shouldShowToday = true;
            break;

          case 'weekly':
            // أسبوعياً: يظهر لو النهارده نفس يوم الأسبوع
            shouldShowToday = (now.weekday == noteTime.weekday);
            break;

          case 'custom':
            // أيام مخصصة
            if (note.repeatDays != null && note.repeatDays!.isNotEmpty) {
              final days = note.repeatDays!.split(',').map(int.parse).toList();
              shouldShowToday = days.contains(now.weekday);
            }
            break;

          case 'hourly':
            // كل ساعة: يظهر دايماً (هيتفلتر بالوقت بعدين)
            shouldShowToday = true;
            break;

          default:
            shouldShowToday = false;
        }

        if (shouldShowToday) {
          todayNotes.add(note);
          repeatAdded++;
        }
      }
    }

    print('🔄 Repeating notes added: $repeatAdded');

    // 3️⃣ إزالة التكرار (لو نفس النوتة ظهرت مرتين)
    final uniqueNotes = <Note>{};
    final seenIds = <int>{};

    for (var note in todayNotes) {
      if (note.id != null && !seenIds.contains(note.id)) {
        seenIds.add(note.id!);
        uniqueNotes.add(note);
      }
    }

    // 4️⃣ ترتيب النوتات
    final sortedNotes = uniqueNotes.toList()
      ..sort((a, b) {
        // الأولوية الأعلى أولاً
        int priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;

        // ثم حسب الوقت
        if (a.publishedAt == null) return 1;
        if (b.publishedAt == null) return -1;
        return a.publishedAt!.compareTo(b.publishedAt!);
      });

    print('🎯 Total unique today notes: ${sortedNotes.length}');
    return sortedNotes;
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

  // Future<List<Map<String, dynamic>>> getDueNotifications(String nowIso) async {
  //   final db = await database;
  //   return await db.rawQuery(
  //     '''
  //     SELECT * FROM notes
  //     WHERE published_at IS NOT NULL
  //     AND published_at <= ?
  //     AND is_published = 0
  //     ''',
  //     [nowIso],
  //   );
  // }

  // Future<void> markAsNotified(int id) async {
  //   final db = await database;
  //   await db.update(
  //     'notes',
  //     {'is_published': 1},
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  Future<List<Map<String, dynamic>>> getDueNotifications() async {
    final db = await database;

    // الوقت الحالي
    final now = DateTime.now();

    // بداية اليوم (00:00:00)
    final startOfDay = DateTime(now.year, now.month, now.day);

    // نهاية اليوم (23:59:59)
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // جلب الملاحظات المستحقة اليوم فقط
    return await db.rawQuery(
      '''
    SELECT * FROM notes 
    WHERE is_published = 0 
    AND published_at IS NOT NULL
    AND datetime(published_at) BETWEEN datetime(?) AND datetime(?)
    ORDER BY published_at ASC
  ''',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
  }

  // في NotesDB
  // Future<List<Note>> getDueNotificationsWithRepeat() async {
  //   final db = await database;
  //   final now = DateTime.now();
  //
  //   // بداية اليوم
  //   final startOfDay = DateTime(now.year, now.month, now.day);
  //   final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  //
  //   // الملاحظات العادية (غير مكررة) المستحقة اليوم
  //   final regularNotes = await db.rawQuery(
  //     '''
  //   SELECT * FROM notes
  //   WHERE is_published = 0
  //   AND (repeat_type = 'none' OR repeat_type IS NULL)
  //   AND published_at IS NOT NULL
  //   AND datetime(published_at) BETWEEN datetime(?) AND datetime(?)
  // ''',
  //     [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
  //   );
  //
  //   // الملاحظات المتكررة
  //   final repeatNotes = await db.rawQuery('''
  //   SELECT * FROM notes
  //   WHERE repeat_type != 'none'
  //   AND repeat_type IS NOT NULL
  //   AND published_at IS NOT NULL
  // ''');
  //
  //   // تصفية الملاحظات المتكررة المستحقة اليوم
  //   List<Map<String, dynamic>> allDueNotes = [];
  //   allDueNotes.addAll(regularNotes);
  //
  //   for (var note in repeatNotes) {
  //     if (_isNoteDueToday(note, now)) {
  //       allDueNotes.add(note);
  //     }
  //   }
  //
  //   return allDueNotes.map((e) => Note.fromMap(e)).toList();
  // }
  Future<List<Map<String, dynamic>>> getDueNotificationsWithRepeat() async {
    final db = await database;
    final now = DateTime.now();

    final result = await db.query('notes', where: 'published_at IS NOT NULL');

    List<Map<String, dynamic>> dueNotes = [];

    for (var note in result) {
      final publishedAtString = note['published_at'] as String?;
      if (publishedAtString == null) continue;

      final publishedAt = DateTime.parse(publishedAtString);
      final repeatType = note['repeat_type']?.toString() ?? 'none';
      final isPublished = note['is_published'] ?? 0;

      // ⛔ لو مش متكرر واتنشر قبل كده → نعديه
      if (repeatType == 'none' && isPublished == 1) continue;

      bool isDue = false;

      switch (repeatType) {
        case 'none':
          isDue = now.isAfter(publishedAt);
          break;

        case 'daily':
          isDue =
              now.hour == publishedAt.hour && now.minute == publishedAt.minute;
          break;

        case 'weekly':
          isDue =
              now.weekday == publishedAt.weekday &&
              now.hour == publishedAt.hour &&
              now.minute == publishedAt.minute;
          break;

        case 'hourly':
          final interval = (note['repeat_interval'] as int?) ?? 1;
          final diff = now.difference(publishedAt).inMinutes;

          isDue = diff >= 0 && diff % (interval * 60) == 0;
          break;

        case 'custom':
          final days =
              note['repeat_days']
                  ?.toString()
                  .split(',')
                  .map(int.parse)
                  .toList() ??
              [];
          isDue =
              days.contains(now.weekday) &&
              now.hour == publishedAt.hour &&
              now.minute == publishedAt.minute;
          break;
      }

      if (isDue) {
        dueNotes.add(note);
      }
    }

    return dueNotes;
  }

  bool _isNoteDueToday(Map<String, dynamic> note, DateTime now) {
    final publishedAt = DateTime.parse(note['published_at']);
    final repeatType = note['repeat_type'] as String? ?? 'none';

    switch (repeatType) {
      case 'daily':
        // يومياً - نفس الوقت كل يوم
        return true;

      case 'hourly':
        // كل ساعة
        final interval = note['repeat_interval'] as int? ?? 1;
        final diff = now.difference(publishedAt).inHours;
        return diff % interval == 0;

      case 'weekly':
        // أسبوعياً - نفس اليوم من الأسبوع
        return now.weekday == publishedAt.weekday;

      case 'custom':
        // أيام مخصصة
        final days =
            note['repeat_days']
                ?.toString()
                .split(',')
                .map(int.parse)
                .toList() ??
            [];
        return days.contains(now.weekday);

      default:
        return false;
    }
  }

  // بعد عرض الإشعار، نحدث is_published
  Future<void> markAsNotified(int id) async {
    final db = await database;
    final note = await getNoteById(id);

    if (note != null) {
      if (note.repeatType != null && note.repeatType != 'none') {
        // لو متكرر، نسيب is_published = 0 عشان يجي تاني
        // ويمكن نحدث آخر مرة تم الإشعار فيها
        await db.update(
          'notes',
          {'last_notified': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        // لو مش متكرر، نخليه منشور
        await db.update(
          'notes',
          {'is_published': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Note.fromMap(result.first);
    }
    return null;
  }
}
