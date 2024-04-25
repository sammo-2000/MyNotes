import 'package:notes/models/noteModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  static int version = 3;
  static String dbName = 'note.db';
  static String sql = '''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY,
      title TEXT,
      note TEXT,
      filePath TEXT,
      reminderDateTime TEXT,
      createAt TEXT,
      editAt TEXT
    );
  ''';

  // Connect to DB
  static Future<Database> getDB() async {
    try {
      return openDatabase(
        join(await getDatabasesPath(), dbName),
        onCreate: (db, version) async {
          await db.execute(sql);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            await db.execute('ALTER TABLE notes ADD COLUMN email TEXT');
          }
        },
        version: version,
      );
    } catch (e) {
      print('Error opening database: $e');
      throw 'Error opening database: $e';
    }
  }

  // Create note
  static Future<int> addNote(Note note) async {
    final db = await getDB();
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update note
  static Future<int> updateNote(Note note) async {
    final db = await getDB();
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete note
  static Future<int> deleteNote(Note note) async {
    final db = await getDB();
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Get notes
  static Future<List<Note>?> getAllNotes() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query("notes");
    if (maps.isEmpty) {
      return null;
    }
    return List.generate(maps.length, (index) => Note.fromMap(maps[index]));
  }
}
