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
    // String path = join(await getDatabasesPath(), 'notes.db');

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
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     await db.execute(
      //       'ALTER TABLE notes ADD COLUMN priority INTEGER DEFAULT 1',
      //     );
      //     await db.execute('ALTER TABLE notes ADD COLUMN created_at TEXT');
      //   }
      //   if (oldVersion < 3) {
      //     await db.execute('ALTER TABLE notes ADD COLUMN updated_at TEXT');
      //   }
      // },
    );
  }

  // 📋 Get All
  Future<List<Note>> getNotes() async {
    final db = await database;
    // final result = await db.query('notes');

    final result = await db.query('notes', orderBy: 'priority DESC');

    return result.map((e) => Note.fromMap(e)).toList();
  }

  // ➕ Insert
  Future<int> insertNote(Note note) async {
    final db = await database;

    print('Inserting note: ${note.toMap()}');

    // return await db.insert('notes', note.toMap());
    return await db.insert('notes', {
      ...note.toMap(),
      'created_at': note.createdAt,
    });
  }

  // ✏️ Update
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      // note.toMap(),
      {...note.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // 🗑️ Delete
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
