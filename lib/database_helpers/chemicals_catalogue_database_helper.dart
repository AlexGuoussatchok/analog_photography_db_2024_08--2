import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ChemicalsCatalogueDatabaseHelper {
  static const _dbName = 'chemicals_catalogue.db';
  static const _databaseVersion = 20231121;
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  static Future<Database> _initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);

    // Copy from assets if not exist or if an upgrade is needed
    if (!await databaseExists(path) || await _isUpgradeNeeded(path)) {
      await _copyFromAssets(path);
    }

    return await openDatabase(path, version: _databaseVersion, onUpgrade: _onUpgrade);
  }

  static Future<bool> _isUpgradeNeeded(String path) async {
    try {
      var db = await openReadOnlyDatabase(path);
      var version = await db.getVersion();
      await db.close();
      return version < _databaseVersion;
    } catch (e) {
      return true;
    }
  }

  static Future<void> _copyFromAssets(String path) async {
    ByteData data = await rootBundle.load(join('assets/databases', _dbName));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Here you can add the logic for updating the database if needed
    // For example, creating new tables or altering existing ones
    // If the structure of the database changes significantly, you might need to export and import data
  }

  Future<List<Map<String, dynamic>>> getChemicals(String table, String columnName) async {
    final db = await database;

    if (db == null) {
      throw Exception("Database not initialized");
    }

    final result = await db.query(table, columns: ['id', columnName]);
    return result;
  }

  Future<List<Map<String, String>>> fetchChemicalsList() async {
    final db = await database; // Use the 'database' getter you have defined
    List<Map<String, String>> chemicalsList = [];

    // Fetch developers
    final developerResults = await db.query('developers', columns: ['developer']);
    chemicalsList.addAll(developerResults.map((e) => {'name': e['developer'] as String, 'type': 'developer'}));

    // Fetch fixers
    final fixerResults = await db.query('fixers', columns: ['fixer']);
    chemicalsList.addAll(fixerResults.map((e) => {'name': e['fixer'] as String, 'type': 'fixer'}));

    // Sort by name
    chemicalsList.sort((a, b) => a['name']!.compareTo(b['name']!));
    return chemicalsList;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}

