import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LensesCatalogueDatabaseHelper {
  static const String dbName = 'lenses_catalogue.db';
  static const _databaseVersion = 20240109;
  static Database? _database;

  static Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initializeDatabase();
    return _database;
  }

  String generateTableName(String brand) {
    return '${brand.toLowerCase().replaceAll(' ', '_')}_lenses_catalogue';
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

  static final LensesCatalogueDatabaseHelper _instance = LensesCatalogueDatabaseHelper._privateConstructor();
  factory LensesCatalogueDatabaseHelper() {
    return _instance;
  }
  LensesCatalogueDatabaseHelper._privateConstructor();

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

  Future<List<Map<String, dynamic>>> getLensesBrands() async {
    final db = await database;
    try {
      return await db!.query('lenses_brands', columns: ['brand'], orderBy: 'brand ASC');
    } catch (e) {
      print("Error fetching lenses brands: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLensesModels(String brand) async {
    final db = await database;
    try {
      String tableName = generateTableName(brand);
      return await db!.query(tableName, columns: ['model'], orderBy: 'model ASC');
    } catch (e) {
      print("Error fetching lens models from $brand: $e");
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> getLensesModelsByBrand(String brand) async {
    final db = await database;

    if (db == null) {
      throw Exception("Database not initialized");
    }

    final tableName = brand.toLowerCase() + '_lenses_catalogue';
    final result = await db.query(tableName, columns: ['model'], orderBy: 'model ASC');
    return result;
  }

  Future<Map<String, dynamic>> getItemDetails(String tableName, String model) async {
    final db = await database;
    try {
      var result = await db!.query(tableName, where: "model = ?", whereArgs: [model]);
      if (result.isNotEmpty) {
        return result.first;
      } else {
        throw Exception('Model not found in the database.');
      }
    } catch (e) {
      print("Error fetching item details for $model from $tableName: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLensesDetails(String brand, String model) async {
    String tableName = '${brand.toLowerCase().replaceAll(' ', '_')}_lenses_catalogue';
    return await getItemDetails(tableName, model);
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
