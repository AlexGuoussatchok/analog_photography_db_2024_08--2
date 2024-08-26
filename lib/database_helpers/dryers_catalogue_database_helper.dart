import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DryersCatalogueDatabaseHelper {
  static const String dbName = 'dryers_catalogue.db';
  static const _databaseVersion = 20231018;
  static Database? _database;

  static Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initializeDatabase();
    return _database;
  }

  static Future<Database> initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    if (await databaseExists(path)) {
      return await openDatabase(path, version: _databaseVersion, onUpgrade: _onUpgrade);
    } else {
      ByteData data = await rootBundle.load(join('assets/databases', dbName));
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
      return await openDatabase(path, version: _databaseVersion);
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, dbName);
      await db.close();
      await deleteDatabase(path);
      ByteData data = await rootBundle.load(join('assets/databases', dbName));
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
    }
  }

  Future<List<Map<String, dynamic>>> getDryersBrands() async {
    final db = await database;
    try {
      return await db!.query('brands', columns: ['brand'], orderBy: 'brand ASC');
    } catch (e) {
      print("Error fetching dryers brands: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDryersModels(String tableName) async {
    final db = await database;
    try {
      return await db!.query(tableName, columns: ['model'], orderBy: 'model ASC');
    } catch (e) {
      print("Error fetching Dryers models from $tableName: $e");
      return [];
    }
  }


  Future<Map<String, dynamic>> getDryersDetails(String tableName, String model) async {
    final db = await database;
    try {
      var result = await db!.query(tableName, where: "model = ?", whereArgs: [model]);
      if (result.isNotEmpty) {
        return result.first;
      } else {
        throw Exception('Model not found in the database.');
      }
    } catch (e) {
      print("Error fetching Dryers details for $model from $tableName: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDryersModelsByBrand(String brand) async {
    final db = await database;

    if (db == null) {
      throw Exception("Database not initialized");
    }

    final tableName = brand.toLowerCase() + '_dryers_catalogue';
    final result = await db.query(tableName, columns: ['model'], orderBy: 'model ASC');
    return result;
  }


  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
