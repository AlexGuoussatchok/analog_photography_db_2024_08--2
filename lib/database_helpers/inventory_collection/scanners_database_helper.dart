import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_scanners.dart';

class ScannersDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertScanners(InventoryScanners scanners) async {
    final db = await _initDatabase();
    return await db.insert('film_scanners', scanners.toMap());
  }

  static Future<InventoryScanners?> getScanners(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('film_scanners', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryScanners.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all scanners for displaying
  static Future<List<InventoryScanners>> fetchScanners() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('film_scanners');
    return maps.map((scannersMap) => InventoryScanners.fromMap(scannersMap)).toList();
  }
}
