import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyNotesDatabaseHelper {
  static const _dbName = 'my_notes.db';
  static const _dbVersion = 1;
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  static Future<Database> _initializeDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static void showNoteDetails(BuildContext context, Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(note['film_name'] ?? 'Note Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date: ${note['date'] ?? 'N/A'}'),
                Text('Film Number: ${note['film_number'] ?? 'N/A'}'),
                Text('Film Name: ${note['film_name'] ?? 'N/A'}'),
                Text('Film Type: ${note['film_type'] ?? 'N/A'}'),
                Text('Film Size: ${note['film_size'] ?? 'N/A'}'),
                Text('ISO: ${note['ISO'] ?? 'N/A'}'),
                Text('Expired: ${note['film_exp_date'] ?? 'N/A'}'),
                Text('Camera: ${note['camera'] ?? 'N/A'}'),
                Text('Lenses: ${note['lenses'] ?? 'N/A'}'),
                Text('Developer: ${note['developer'] ?? 'N/A'}'),
                Text('Lab: ${note['lab'] ?? 'N/A'}'),
                Text('Dilution: ${note['dilution'] ?? 'N/A'}'),
                Text('Development Time: ${note['dev_time'] ?? 'N/A'}'),
                Text('Temperature: ${note['temp'] ?? 'N/A'}'),
                Text('Comments: ${note['comments'] ?? 'N/A'}'),
                // ... Add more fields as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  static Future<void> _onCreate(Database db, int version) async {
    var tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='my_film_dev_notes'"
    );

    // If the query returns no rows, the table does not exist and should be created.
    if (tableExists.isEmpty) {
      await db.execute('''
      CREATE TABLE my_film_dev_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        film_number TEXT,
        film_name TEXT,
        film_type TEXT,
        film_size TEXT,
        ISO TEXT,
        film_expired TEXT,
        film_exp_date TEXT,
        camera TEXT,
        lenses TEXT,
        developer TEXT,
        lab TEXT,
        dilution TEXT,
        dev_time TEXT,
        temp TEXT,
        comments TEXT
      );
    ''');
    }

    // Repeat the same process for other tables
    tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='my_films_history_notes'"
    );

    if (tableExists.isEmpty) {
      await db.execute('''
      CREATE TABLE my_films_history_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        film_number TEXT
      );
    ''');
    }
  }

  Future<List<Map<String, dynamic>>> getDevelopingNotes() async {
    final db = await database;
    if (db == null) {
      throw Exception("Database not initialized");
    }
    final List<Map<String, dynamic>> notes = await db.query(
        'my_film_dev_notes',
        orderBy: 'date DESC' // Sort by date in descending order
    );
    return notes;
  }

  Future<void> insertDevelopingNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert(
      'my_film_dev_notes',
      note,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getMaxFilmNumber() async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX(film_number) as max_number FROM my_film_dev_notes');
    if (result.isNotEmpty && result.first['max_number'] != null) {
      return int.tryParse(result.first['max_number'].toString()) ?? 0;
    }
    return 0;
  }

  Future<void> deleteDevelopingNote(int id) async {
    final db = await database;
    await db.delete(
      'my_film_dev_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
