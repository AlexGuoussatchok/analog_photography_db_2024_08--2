import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_dryers.dart';

class DryersDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertDryers(InventoryDryers dryers) async {
    final db = await _initDatabase();
    return await db.insert('paper_dryers', dryers.toMap());
  }

  static Future<InventoryDryers?> getDryers(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('paper_dryers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryDryers.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all dryers for displaying
  static Future<List<InventoryDryers>> fetchDryers() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('paper_dryers');
    return maps.map((dryersMap) => InventoryDryers.fromMap(dryersMap)).toList();
  }
}
