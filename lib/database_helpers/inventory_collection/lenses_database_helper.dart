import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_lenses.dart';

class LensesDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertLenses(InventoryLenses lenses) async {
    final db = await _initDatabase();
    return await db.insert('lenses', lenses.toMap());
  }

  static Future<InventoryLenses?> getLenses(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('lenses', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryLenses.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all lenses for displaying
  static Future<List<InventoryLenses>> fetchLenses() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('lenses');
    return maps.map((lensesMap) => InventoryLenses.fromMap(lensesMap)).toList();
  }

  Future<List<Map<String, dynamic>>> getLensesForDropdown() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> lensMaps = await db.query('lenses');

    // Create a new list from the query results to make it mutable
    List<Map<String, dynamic>> mutableLensMaps = List<Map<String, dynamic>>.from(lensMaps);

    // Sort lenses alphabetically by brand and model
    mutableLensMaps.sort((a, b) => ('${a['brand']} ${a['model']}').compareTo('${b['brand']} ${b['model']}'));

    return mutableLensMaps.map((lens) {
      // Combine brand, model, and serial number with "s/n" prefix
      String displayValue = '${lens['brand']} ${lens['model']}';
      if (lens['serial_number'] != null && lens['serial_number'].toString().isNotEmpty) {
        displayValue += ' (s/n ${lens['serial_number']})';
      }

      return {
        'displayValue': displayValue,
        // Other fields can be added here if necessary
      };
    }).toList();
  }

  static Future<void> deleteLens(int id) async {
    final db = await _initDatabase();
    await db.delete('lenses', where: 'id = ?', whereArgs: [id]);
  }
}

