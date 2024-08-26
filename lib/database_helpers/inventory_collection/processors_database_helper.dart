import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_processors.dart';

class ProcessorsDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertProcessors(InventoryProcessors processors) async {
    final db = await _initDatabase();
    return await db.insert('film_processors', processors.toMap());
  }

  static Future<InventoryProcessors?> getProcessors(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('film_processors', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryProcessors.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<InventoryProcessors>> fetchProcessors() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('film_processors');
    return maps.map((processorsMap) => InventoryProcessors.fromMap(processorsMap)).toList();
  }
}
