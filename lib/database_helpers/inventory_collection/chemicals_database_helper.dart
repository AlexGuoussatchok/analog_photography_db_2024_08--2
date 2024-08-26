import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_chemicals.dart';

class ChemicalsDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertChemicals(InventoryChemicals chemicals) async {
    final db = await _initDatabase();
    return await db.insert('photo_chemistry', chemicals.toMap());
  }

  static Future<InventoryChemicals?> getChemicals(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('photo_chemistry', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryChemicals.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all chemicals for displaying
  static Future<List<InventoryChemicals>> fetchChemicals() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('photo_chemistry');
    return maps.map((chemicalsMap) => InventoryChemicals.fromMap(chemicalsMap)).toList();
  }

  Future<List<Map<String, dynamic>>> getChemicalsForDropdown() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> chemicalsMap = await db.query('photo_chemistry');

    // Create a new list from the query results to make it mutable
    List<Map<String, dynamic>> mutableChemicalsMaps = List<Map<String, dynamic>>.from(chemicalsMap);

    // Sort chemicals alphabetically by brand and name
    mutableChemicalsMaps.sort((a, b) => ('${a['brand']} ${a['name']}').compareTo('${b['brand']} ${b['name']}'));

    return mutableChemicalsMaps.map((chemicals) {
      // Combine brand, name, and serial number with "s/n" prefix
      String displayValue = '${chemicals['brand']} ${chemicals['name']}';


      return {
        'displayValue': displayValue,
        // Other fields can be added here if necessary
      };
    }).toList();
  }

  static Future<int> updateChemical(int id, InventoryChemicals chemicals) async {
    final db = await _initDatabase();
    return await db.update(
      'photo_chemistry',
      chemicals.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteChemical(int id) async {
    final db = await _initDatabase();
    await db.delete(
      'photo_chemistry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<String>> getDevelopers() async {
    final db = await _initDatabase();
    // Query the database and get unique developer names
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT DISTINCT chemical FROM photo_chemistry WHERE type = ?', ['developer']);
    // Extracting the names and converting them to a list of strings
    return result.map((row) => row['chemical'] as String).toList();
  }

}
