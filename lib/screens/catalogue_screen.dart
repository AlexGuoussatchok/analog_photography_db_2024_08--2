import 'package:flutter/material.dart';
import 'package:analog_photography_db/screens/catalogue_cameras_screen.dart';
import 'package:analog_photography_db/screens/catalogue_lenses_screen.dart';
import 'package:analog_photography_db/screens/catalogue_flashes_screen.dart';
import 'package:analog_photography_db/screens/catalogue_exposure_meters_screen.dart';
import 'package:analog_photography_db/screens/catalogue_filters_screen.dart';
import 'package:analog_photography_db/screens/catalogue_films_screen.dart';
import 'package:analog_photography_db/screens/catalogue_photo_papers_screen.dart';
import 'package:analog_photography_db/screens/catalogue_enlargers_screen.dart';
import 'package:analog_photography_db/screens/catalogue_color_analyzers_screen.dart';
import 'package:analog_photography_db/screens/catalogue_processors_screen.dart';
import 'package:analog_photography_db/screens/catalogue_paper_dryers_screen.dart';
import 'package:analog_photography_db/screens/catalogue_print_washers_screen.dart';
import 'package:analog_photography_db/screens/catalogue_film_scanners_screen.dart';
import 'package:analog_photography_db/screens/catalogue_photochemistry_screen.dart';

class CatalogueScreen extends StatelessWidget {
  const CatalogueScreen({Key? key}) : super(key: key);

  Widget _catalogueButton(String label, IconData icon, VoidCallback onPressed) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Catalogue',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: catalogueItems.length,
            itemBuilder: (context, index) {
              return _catalogueButton(
                catalogueItems[index]['label']!,
                catalogueItems[index]['icon']!,
                    () {  // Corrected onPressed to use the context
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => catalogueItems[index]['screen']!,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> catalogueItems = [
  {
    'label': 'Cameras',
    'icon': Icons.camera,
    'screen': const CatalogueCamerasScreen(),
  },
  {
    'label': 'Lenses',
    'icon': Icons.camera_alt,
    'screen': const CatalogueLensesScreen(),
  },
  {
    'label': 'Flashes',
    'icon': Icons.flash_on,
    'screen': const CatalogueFlashesScreen(),
  },
  {
    'label': 'Exposure / Flash Meters',
    'icon': Icons.speed,
    'screen': const CatalogueMetersScreen(),
  },
  {
    'label': 'Filters',
    'icon': Icons.filter,
    'screen': const CatalogueFiltersScreen(),
  },
  {
    'label': 'Films',
    'icon': Icons.movie,
    'screen': const CatalogueFilmsScreen(),
  },
  {
    'label': 'Photo Papers',
    'icon': Icons.photo,
    'screen': const CataloguePhotoPapersScreen(),
  },
  {
    'label': 'Enlargers',
    'icon': Icons.crop,
    'screen': const CatalogueEnlargersScreen(),
  },
  {
    'label': 'Color Analyzers',
    'icon': Icons.color_lens,
    'screen': const CatalogueColorAnalyzersScreen(),
  },
  {
    'label': 'Film Processors',
    'icon': Icons.science,
    'screen': const CatalogueProcessorsScreen(),
  },
  {
    'label': 'Paper Dryers',
    'icon': Icons.dry,
    'screen': const CatalogueDryersScreen(),
  },
  {
    'label': 'Print Washers',
    'icon': Icons.wash,
    'screen': const CataloguePrintWashersScreen(),
  },
  {
    'label': 'Film Scanners',
    'icon': Icons.scanner,
    'screen': const CatalogueScannersScreen(),
  },
  {
    'label': 'Photochemistry',
    'icon': Icons.science,
    'screen': const CatalogueChemicalsScreen(),
  },
];
