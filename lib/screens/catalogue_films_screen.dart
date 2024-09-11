import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:analog_photography_db/database_helpers/films_catalogue_database_helper.dart';

class CatalogueFilmsScreen extends StatefulWidget {
  const CatalogueFilmsScreen({Key? key}) : super(key: key);

  @override
  _CatalogueFilmsScreenState createState() => _CatalogueFilmsScreenState();
}

class _CatalogueFilmsScreenState extends State<CatalogueFilmsScreen> {
  List<String> filmBrands = [];
  List<String> filteredBrands = [];
  List<String> filmNames = [];
  String? selectedBrand;
  TextEditingController brandController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilmsBrands();
    brandController.addListener(_filterBrands);
  }

  @override
  void dispose() {
    brandController.removeListener(_filterBrands);
    brandController.dispose();
    super.dispose();
  }

  Future<void> _loadFilmsBrands() async {
    try {
      setState(() {
        isLoading = true;
      });
      var brands = await FilmsCatalogueDatabaseHelper().getFilmsBrands();
      setState(() {
        filmBrands = brands.map((e) => e['brand'].toString()).toList();
        filteredBrands = filmBrands;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading brands: $e')),
      );
    }
  }

  void _filterBrands() {
    setState(() {
      filteredBrands = filmBrands
          .where((brand) =>
          brand.toLowerCase().contains(brandController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadFilmNames(String brand) async {
    try {
      var models = await FilmsCatalogueDatabaseHelper().getFilmsNamesByBrand(brand);
      setState(() {
        filmNames = models.map((e) => e['name'].toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading film names: $e')),
      );
    }
  }

  void _showFilmDetails(BuildContext context, Map<String, dynamic> details) {
    List<String> excludedColumns = ['id', 'name'];
    String brand = selectedBrand!.toLowerCase();
    String imageId = details['id'].toString();
    String imagePath = 'assets/images/films/$brand/$imageId.jpg';

    List<Widget> detailWidgets = details.entries
        .where((entry) =>
    entry.value != null &&
        entry.value.toString().isNotEmpty &&
        !excludedColumns.contains(entry.key))
        .map((entry) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(entry.key.replaceAll('_', ' '),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(entry.value.toString()),
          ],
        ),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(imagePath),
                const SizedBox(height: 10.0),
                Text(details['name']?.replaceAll('_', ' ') ?? "Unknown Film"),
                const SizedBox(height: 10.0),
                ...detailWidgets,
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
          'Films Catalogue',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: brandController,
                decoration: InputDecoration(
                  labelText: 'Search or Select a Brand',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      brandController.clear();
                      _filterBrands();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              if (filteredBrands.isNotEmpty)
                Flexible(
                  child: GridView.builder(
                    primary: false,
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemCount: filteredBrands.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedBrand = filteredBrands[index];
                            brandController.text = selectedBrand!;
                            _loadFilmNames(selectedBrand!);
                            filteredBrands = [];
                          });
                        },
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
                            const Icon(Icons.movie, size: 50, color: Colors.black),
                            const SizedBox(height: 10),
                            Text(filteredBrands[index],
                                style: const TextStyle(fontSize: 18, color: Colors.black)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (filteredBrands.isEmpty && selectedBrand != null)
                Flexible(
                  child: GridView.builder(
                    primary: false,
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemCount: filmNames.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic>? details = await FilmsCatalogueDatabaseHelper().getFilmDetailsByBrandAndName(
                              selectedBrand!, filmNames[index]);
                          if (details != null) {
                            _showFilmDetails(context, details);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: Film details not found.')),
                            );
                          }
                        },
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
                            const Icon(Icons.movie_filter, size: 50, color: Colors.black),
                            const SizedBox(height: 10),
                            Text(filmNames[index], style: const TextStyle(fontSize: 18, color: Colors.black)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
