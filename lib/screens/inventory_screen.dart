import 'package:analog_photography_db/screens/inventory_collection_scanners_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:analog_photography_db/database_helpers/inventory_database_helper.dart';
import 'package:analog_photography_db/screens/inventory_collection_cameras_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_lenses_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_flashes_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_meters_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_processors_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_dryers_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_films_screen.dart';
import 'package:analog_photography_db/screens/inventory_collection_photochemistry_screen.dart';
import 'package:analog_photography_db/extra_function/inventory_backup/backup.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();

}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  Database? collectionDb;
  Database? wishlistDb;
  Database? sellListDb;
  Database? borrowedDb;
  late TabController _firstTabController;
  late TabController _secondTabController;


  @override
  void initState() {
    super.initState();
    _firstTabController = TabController(length: 4, vsync: this);
    _secondTabController = TabController(length: 14, vsync: this);

    _initializeDatabases();
  }

  Future<void> _initializeDatabases() async {
    collectionDb =
    await InventoryDatabaseHelper.initDatabase('inventory_collection.db');
    wishlistDb =
    await InventoryDatabaseHelper.initDatabase('inventory_wishlist.db');
    sellListDb =
    await InventoryDatabaseHelper.initDatabase('inventory_sell_list.db');
    borrowedDb =
    await InventoryDatabaseHelper.initDatabase('inventory_borrowed_stuff.db');
  }

  @override
  void dispose() {
    _firstTabController.dispose();
    _secondTabController.dispose();

    // Close Databases
    collectionDb?.close();
    wishlistDb?.close();
    sellListDb?.close();
    borrowedDb?.close();
    // Close other databases similarly, if needed

    super.dispose();
  }

  void _handleMenuSelection(String value) {
    if (value == 'Backup') {
      // Backup logic
    } else if (value == 'Import DB') {
      BackupUtils.importDatabase(context);
    }
    // Other options...
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const BackupDialog(); // Make sure this is imported correctly
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeDatabases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Inventory'),
              actions: [
                PopupMenuButton<String>(
                  onSelected: _handleMenuSelection,
                  itemBuilder: (BuildContext context) {
                    return {'Backup', 'Import DB'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    const Divider(
                        height: 1.0, thickness: 3.0, color: Colors.white),
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _firstTabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        tabs: const [
                          Tab(text: 'Collection'),
                          Tab(text: 'Wishlist'),
                          Tab(text: 'Sell-list'),
                          Tab(text: 'Borrowed'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Divider(
                        height: 1.0, thickness: 3.0, color: Colors.white),
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _secondTabController,
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        tabs: const [
                          Tab(text: 'Cameras'),
                          Tab(text: 'Lenses'),
                          Tab(text: 'Flashes'),
                          Tab(text: 'Exposure meters'),
                          Tab(text: 'Films'),
                          Tab(text: 'Filters'),
                          Tab(text: 'Photo papers'),
                          Tab(text: 'Enlargers'),
                          Tab(text: 'Color Analysers'),
                          Tab(text: 'Film Processors'),
                          Tab(text: 'Paper Dryers'),
                          Tab(text: 'Print Washers'),
                          Tab(text: 'Film Scanners'),
                          Tab(text: 'Photochemistry'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _firstTabController,
              children: [
                // First tab (Collection)
                TabBarView(
                  controller: _secondTabController,
                  children: [
                    // Cameras Tab
                    const InventoryCollectionCamerasScreen(),
                    // Add other screens for Lenses, Flashes, etc.

                    const InventoryCollectionLensesScreen(),

                    const InventoryCollectionFlashesScreen(),

                    const InventoryCollectionMetersScreen(),

                    const InventoryCollectionFilmsScreen(),
                    ...List.generate(4, (index) => const Center(child: Text('Content for selected tab.'))),

                    const InventoryCollectionProcessorsScreen(),

                    const InventoryCollectionDryersScreen(),
                    ...List.generate(1, (index) => const Center(child: Text('Content for selected tab.'))),

                    const InventoryCollectionScannersScreen(),

                    const InventoryCollectionPhotochemistryScreen(),


                  ],
                ),
                // Content for other tabs (Wishlist, Sell-list, Borrowed)
                const Center(child: Text('Wishlist content here.')),
                const Center(child: Text('Sell-list content here.')),
                const Center(child: Text('Borrowed content here.')),
              ],
            ),

          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error initializing database.')),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
