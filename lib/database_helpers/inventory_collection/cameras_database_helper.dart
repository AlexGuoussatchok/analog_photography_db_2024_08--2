import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:analog_photography_db/models/inventory_camera.dart';

class CamerasDatabaseHelper {
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'inventory_collection.db');
    return openDatabase(path);
  }

  static Future<int> insertCamera(InventoryCamera camera) async {
    final db = await _initDatabase();
    return await db.insert('cameras', camera.toMap());
  }

  static Future<InventoryCamera?> getCamera(int id) async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('cameras', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryCamera.fromMap(maps.first);
    }
    return null;
  }

  // This is a helper method to fetch all cameras for displaying
  static Future<List<InventoryCamera>> fetchCameras() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        'cameras',
        orderBy: 'brand ASC, model ASC' // Order by brand first, then model, both in ascending order
    );
    return maps.map((cameraMap) => InventoryCamera.fromMap(cameraMap)).toList();
  }

  Future<List<Map<String, dynamic>>> getCamerasForDropdown() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> cameraMaps = await db.query('cameras');

    // Create a new list from the query results to make it mutable
    List<Map<String, dynamic>> mutableCameraMaps = List<Map<String, dynamic>>.from(cameraMaps);

    // Sort cameras alphabetically by brand and model
    mutableCameraMaps.sort((a, b) => ('${a['brand']} ${a['model']}').compareTo('${b['brand']} ${b['model']}'));

    return mutableCameraMaps.map((camera) {
      // Combine brand, model, and serial number with "s/n" prefix
      String displayValue = '${camera['brand']} ${camera['model']}';
      if (camera['serial_number'] != null && camera['serial_number'].toString().isNotEmpty) {
        displayValue += ' (s/n ${camera['serial_number']})';
      }

      return {
        'displayValue': displayValue,
        // Remove the 'subtitle' field if it's no longer needed
      };
    }).toList();
  }

  static Future<void> deleteCamera(int id) async {
    final db = await _initDatabase();
    await db.delete(
      'cameras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateCamera(InventoryCamera camera) async {
    final db = await _initDatabase(); // Use _initDatabase() instead of database
    await db.update(
      'cameras', // The table name
      camera.toMap(), // Convert the camera object to a map
      where: 'id = ?', // Use a where clause to find the correct camera
      whereArgs: [camera.id], // Pass the camera's ID as a where argument
    );
  }



}
