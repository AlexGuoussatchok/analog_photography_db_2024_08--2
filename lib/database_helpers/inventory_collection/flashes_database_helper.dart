import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_flashes.dart';

class FlashesDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertFlashes(InventoryFlashes flashes) async {
    final db = await _initDatabase();
    return await db.insert('flashes', flashes.toMap());
  }

  static Future<InventoryFlashes?> getFlashes(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('flashes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryFlashes.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<InventoryFlashes>> fetchFlashes() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('flashes');
    return maps.map((flashesMap) => InventoryFlashes.fromMap(flashesMap)).toList();
  }

  static Future<void> deleteFlash(int id) async {
    final db = await _initDatabase();
    await db.delete(
      'flashes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
