import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DarkroomDatabaseHelper {
  static const String _dbName = 'dev_chart.db';
  static const int _dbVersion = 20231120; // Update this version as needed

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  static Future<Database> _initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);

    // Check if the database exists
    var dbExists = await databaseExists(path);

    if (dbExists) {
      // Open the existing database
      return await openDatabase(path, version: _dbVersion, onUpgrade: _onUpgrade);
    } else {
      // If the database doesn't exist, copy from assets
      ByteData data = await rootBundle.load(join('assets/databases', _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);

      // Open the copied database
      return await openDatabase(path, version: _dbVersion);
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      // Logic to handle database upgrades
      // For example, you might want to clear tables, re-copy from assets, etc.
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _dbName);
      await db.close();
      await deleteDatabase(path);
      ByteData data = await rootBundle.load(join('assets/databases', _dbName));
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
      _database = await openDatabase(path, version: _dbVersion);
    }
  }

  Future<List<String>> getDevelopers() async {
    final db = await database;
    if (db == null) {
      throw Exception("Database not initialized");
    }

    // Query to fetch table names excluding system tables
    var tablesMap = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_metadata'"
    );

    // Extracting table names
    var developers = tablesMap.map((row) => row['name'].toString()).toList();

    // Sorting the list alphabetically
    developers.sort((a, b) => a.compareTo(b));

    return developers;
  }


  Future<List<String>> getFilmsForDeveloper(String developer) async {
    final db = await database;
    if (db == null) {
      throw Exception("Database not initialized");
    }

    // Ensure the table name is properly quoted to handle special characters
    String quotedTableName = developer.contains('-') ? '"$developer"' : developer;

    var filmsMap = await db.rawQuery("SELECT DISTINCT film FROM $quotedTableName");

    // Extracting film names
    var films = filmsMap.map((row) => row['film'].toString()).toList();

    // Sorting the list alphabetically
    films.sort((a, b) => a.compareTo(b));

    return films;
  }


  Future<Map<String, dynamic>> getFilmData(String developer, String film) async {
    final db = await database;

    // Assuming the table name is the same as the developer's name
    String tableName = developer.replaceAll(' ', '_');
    if (db == null) {
      throw Exception("Database not initialized");
    }

    String quotedTableName = developer.contains('-') ? '"$developer"' : developer;

    var result = await db.rawQuery("SELECT * FROM $quotedTableName WHERE film = ?", [film]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Film data not found in the database.');
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

