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

  Widget _customButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        minimumSize: const Size(150, 100),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 20),
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
    // Handle other menu options if any
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Analog Photography DB'),
        actions: <Widget>[
          PopupMenuButton<String>(
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
      body: SafeArea(
        child: Center(
          child: Align(
            alignment: Alignment.center,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _customButton('Catalogue', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CatalogueScreen()));
                }),
                _customButton('Inventory', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InventoryScreen()));
                }),
                _customButton('Darkroom', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DarkroomScreen()));
                }),
                _customButton('Photo Notes', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PhotoNotesScreen()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
