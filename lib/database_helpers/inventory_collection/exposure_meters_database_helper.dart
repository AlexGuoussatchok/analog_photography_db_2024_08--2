import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_meters.dart';

class MetersDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertMeters(InventoryMeters meters) async {
    final db = await _initDatabase();
    return await db.insert('exposure_meters', meters.toMap());
  }

  static Future<InventoryMeters?> getMeters(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('exposure_meters', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryMeters.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all exposure meters for displaying
  static Future<List<InventoryMeters>> fetchMeters() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('exposure_meters');
    return maps.map((metersMap) => InventoryMeters.fromMap(metersMap)).toList();
  }
}
