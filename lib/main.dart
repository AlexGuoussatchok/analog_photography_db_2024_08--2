import 'package:flutter/material.dart';
import 'package:analog_photography_db/screens/catalogue_screen.dart';
import 'package:analog_photography_db/screens/inventory_screen.dart';
import 'package:analog_photography_db/screens/darkroom_screen.dart';
import 'package:analog_photography_db/screens/photo_notes_screen.dart';
import 'package:analog_photography_db/database_helpers/cameras_catalogue_database_helper.dart';
import 'package:analog_photography_db/database_helpers/lenses_catalogue_database_helper.dart';
import 'package:analog_photography_db/database_helpers/films_catalogue_database_helper.dart';
import 'package:analog_photography_db/database_helpers/inventory_database_helper.dart';
import 'package:analog_photography_db/database_helpers/flashes_catalogue_database_helper.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CamerasCatalogueDatabaseHelper.initializeDatabase();
  await LensesCatalogueDatabaseHelper.initializeDatabase();
  await FilmsCatalogueDatabaseHelper.initializeDatabase();
  await FlashesCatalogueDatabaseHelper.initializeDatabase();
  await InventoryDatabaseHelper.initDatabase('inventory_collection.db');
  await InventoryDatabaseHelper.initDatabase('inventory_wishlist.db');
  await InventoryDatabaseHelper.initDatabase('inventory_sell_list.db');
  await InventoryDatabaseHelper.initDatabase('inventory_borrowed_stuff.db');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analog Photography DB',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _customButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 50, color: Colors.black),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 18, color: Colors.black)),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) async {
    switch (value) {
      case 'Exit':
      // Close all databases before exiting
        await CamerasCatalogueDatabaseHelper().closeDatabase();
        await LensesCatalogueDatabaseHelper().closeDatabase();
        await FilmsCatalogueDatabaseHelper().closeDatabase();
        await FlashesCatalogueDatabaseHelper().closeDatabase();
        await InventoryDatabaseHelper.closeDatabase();

        // Exits the app
        SystemNavigator.pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Analog Photography DB',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              return {'Exit'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(  // Center the grid in the middle of the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            shrinkWrap: true,  // Adjust the grid size to its content
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: <Widget>[
              _customButton('Catalogue', Icons.camera, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CatalogueScreen()));
              }),
              _customButton('Inventory', Icons.inventory, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InventoryScreen()));
              }),
              _customButton('Darkroom', Icons.dark_mode, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DarkroomScreen()));
              }),
              _customButton('Photo Notes', Icons.note, () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PhotoNotesScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
