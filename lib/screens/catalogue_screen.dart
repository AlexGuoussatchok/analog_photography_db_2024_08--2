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

  Widget _catalogueButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.grey,
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Catalogue'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _catalogueButton('Cameras', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueCamerasScreen()));
              }),
              _catalogueButton('Lenses', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueLensesScreen()));
              }),
              _catalogueButton('Flashes', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueFlashesScreen()));
              }),
              _catalogueButton('Exposure / Flash Meters', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueMetersScreen()));
              }),
              _catalogueButton('Filters', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueFiltersScreen()));
              }),
              _catalogueButton('Films', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueFilmsScreen()));
              }),
              _catalogueButton('Photo Papers', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CataloguePhotoPapersScreen()));
              }),
              _catalogueButton('Enlargers', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueEnlargersScreen()));
              }),
              _catalogueButton('Color Analyzers', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueColorAnalyzersScreen()));
              }),
              _catalogueButton('Film Processors', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueProcessorsScreen()));
              }),
              _catalogueButton('Paper Dryers', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueDryersScreen()));
              }),
              _catalogueButton('Print Washers', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CataloguePrintWashersScreen()));
              }),
              _catalogueButton('Film Scanners', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueScannersScreen()));
              }),
              _catalogueButton('Photochemistry', () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CatalogueChemicalsScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
