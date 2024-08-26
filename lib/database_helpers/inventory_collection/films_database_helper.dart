import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_films.dart';

class FilmsDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertFilms(InventoryFilms films) async {
    final db = await _initDatabase();
    return await db.insert('films', films.toMap());
  }

  static Future<InventoryFilms?> getFilms(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('films', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryFilms.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all films for displaying
  static Future<List<InventoryFilms>> fetchFilms() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('films');
    return maps.map((filmsMap) => InventoryFilms.fromMap(filmsMap)).toList();
  }

  static Future<void> deleteFilms(int id) async {
    // Get a reference to the database
    final db = await _initDatabase();

    // Remove the film from the database
    await db.delete(
      'films', // table name
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<List<String>> getFilmNamesForDropdown() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('films');
    return maps.map((filmMap) => "${filmMap['brand']} ${filmMap['name']}").toList();
  }

  static Future<Map<String, String>> getFilmDetails(String brand, String name) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'films',
      where: 'brand = ? AND name = ?',
      whereArgs: [brand, name],
    );
    if (maps.isNotEmpty) {
      var film = maps.first;
      // Map the database columns to the input fields
      return {
        'filmType': film['type'] ?? '',
        'filmSize': film['size_type'] ?? '',
        'iso': film['ISO'] ?? '',
        'filmExpired': film['is_expired'] ?? '',
        'filmExpDate': film['expiration_date'] ?? '',
        // Add other fields as needed
      };
    }
    return {}; // Return an empty map if no film is found
  }
}
