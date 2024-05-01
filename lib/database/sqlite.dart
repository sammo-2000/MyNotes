import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/services/notificationService.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  static int version = 1;
  static String dbName = 'note.db';
  static String sql = '''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY,
      title TEXT,
      note TEXT,
      filePath TEXT,
      reminderDateTime TEXT,
      createAt TEXT,
      editAt TEXT,
      email TEXT
    );
  ''';

  // Connect to DB
  static Future<Database> getDB() async {
    try {
      final databasePath = await getDatabasesPath();
      final database = await openDatabase(
        join(databasePath, dbName),
        onCreate: (db, version) async {
          print('Creating new table');
          await db.execute(sql);
        },
        version: version,
      );

      // Check if the 'notes' table exists
      final tables = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='notes'");
      if (tables.isEmpty) {
        await database.execute(sql);
      } else {
        // Check if 'notes' table is empty, add dummy data if needed
        final countResult =
            await database.rawQuery("SELECT COUNT(*) AS count FROM notes");
        final count = Sqflite.firstIntValue(countResult);
        if (count == 0) {
          User? user = FirebaseAuth.instance.currentUser;
          Note newNote = Note(
            title: 'Dummy',
            note: 'Dummy',
            createAt: DateTime.now(),
            email: user!.email,
          );
          MyDatabase.addNote(newNote);
        }
      }

      return database;
    } catch (e) {
      print('Error opening database: $e');
      throw 'Error opening database: $e';
    }
  }

  // Create note
  static Future<int> addNote(Note note) async {
    if (note.reminderDateTime != null) {
      NotificationServices.displayNotification(
        notificationTitle: note.title,
        body: note.note,
        scheduled: true,
        time: note.reminderDateTime,
      );
    }
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
