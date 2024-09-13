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
  List<String> filteredFilmNames = [];
  String? selectedBrand;
  TextEditingController brandController = TextEditingController();
  TextEditingController filmController = TextEditingController();
  bool isLoading = false;
  int totalBrands = 0; // To store total number of brands
  int distinctFilmCount = 0; // To store distinct film count
  int totalFilmCount = 0; // To store total film count including variants

  @override
  void initState() {
    super.initState();
    _loadFilmsBrands();
    brandController.addListener(_filterBrands);
    filmController.addListener(_filterFilmNames);
  }

  @override
  void dispose() {
    brandController.removeListener(_filterBrands);
    brandController.dispose();
    filmController.removeListener(_filterFilmNames);
    filmController.dispose();
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
        totalBrands = filmBrands.length; // Set total number of brands
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

  void _filterFilmNames() {
    setState(() {
      filteredFilmNames = filmNames
          .where((name) =>
          name.toLowerCase().contains(filmController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadFilmNames(String brand) async {
    try {
      var models = await FilmsCatalogueDatabaseHelper().getFilmsNamesByBrand(brand);

      // Create a set to keep track of distinct films
      Set<String> distinctFilms = {};
      int totalFilms = 0;

      for (var model in models) {
        distinctFilms.add(model['name'].toString().split('(')[0].trim()); // Get distinct films
        totalFilms++;
      }

      setState(() {
        filmNames = models.map((e) => e['name'].toString()).toList();
        filteredFilmNames = filmNames;
        distinctFilmCount = distinctFilms.length; // Number of distinct films
        totalFilmCount = totalFilms; // Total number of films including variants
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading film names: $e')),
      );
    }
  }

  void _showFilmDetails(BuildContext context, Map<String, dynamic> details) async {
    List<String> excludedColumns = ['id', 'name'];
    String brand = selectedBrand!.toLowerCase();
    String filmId = details['id'].toString();
    String imageFolderPath = 'assets/films_catalogue/$brand/$filmId/images/';
    String textFolderPath = 'assets/films_catalogue/$brand/$filmId/texts/';

    List<String> imagePaths = await _loadImagesFromFolder(imageFolderPath);
    List<String> textFiles = await _loadTextFilesFromFolder(textFolderPath);

    List<Widget> thumbnailWidgets = imagePaths.map((path) {
      return GestureDetector(
        onTap: () => _showEnlargedImage(context, imagePaths, path),
        child: Image.asset(path, width: 80, height: 80),
      );
    }).toList();

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

    List<Widget> textDropdownWidgets = textFiles.map((filePath) {
      String fileName = filePath.split('/').last;
      return FutureBuilder<String>(
        future: _readFilmDescription(filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error loading $fileName');
          }
          return ExpansionTile(
            title: Text(fileName.replaceAll('_', ' ').split('.').first),
            children: [Text(snapshot.data ?? '')],
          );
        },
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
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: thumbnailWidgets,
                ),
                const SizedBox(height: 10.0),
                ...detailWidgets,
                const SizedBox(height: 10.0),
                ...textDropdownWidgets,
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

  void _showEnlargedImage(BuildContext context, List<String> imagePaths, String currentImagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: imagePaths.length,
                  controller: PageController(initialPage: imagePaths.indexOf(currentImagePath)),
                  itemBuilder: (context, index) {
                    return Image.asset(imagePaths[index]);
                  },
                ),
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> _loadImagesFromFolder(String folderPath) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys
        .where((String key) => key.startsWith(folderPath))
        .toList();
    return imagePaths;
  }

  Future<List<String>> _loadTextFilesFromFolder(String folderPath) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final textFiles = manifestMap.keys
        .where((String key) => key.startsWith(folderPath) && key.endsWith('.txt'))
        .toList();
    return textFiles;
  }

  Future<String> _readFilmDescription(String filePath) async {
    return await rootBundle.loadString(filePath);
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
          : Stack( // Use Stack to keep the status bar at the bottom
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                if (selectedBrand != null)
                  TextField(
                    controller: filmController,
                    decoration: InputDecoration(
                      labelText: 'Search or Select a Film Name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          filmController.clear();
                          _filterFilmNames();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: filteredBrands.isNotEmpty
                      ? ListView.builder(
                    itemCount: filteredBrands.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredBrands[index]),
                        leading: const Icon(Icons.movie, size: 30),
                        onTap: () {
                          setState(() {
                            selectedBrand = filteredBrands[index];
                            brandController.text = selectedBrand!;
                            _loadFilmNames(selectedBrand!);
                            filteredBrands = [];
                          });
                        },
                      );
                    },
                  )
                      : GridView.builder(
                    primary: false,
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemCount: filteredFilmNames.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic>? details =
                          await FilmsCatalogueDatabaseHelper()
                              .getFilmDetailsByBrandAndName(
                              selectedBrand!, filteredFilmNames[index]);
                          if (details != null) {
                            _showFilmDetails(context, details);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error: Film details not found.')),
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
                            Text(filteredFilmNames[index],
                                style: const TextStyle(fontSize: 18, color: Colors.black)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Status Bar with minimal height fixed at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 40, // Minimal height for the status bar
              width: double.infinity,
              child: Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  selectedBrand == null
                      ? 'Total brands in catalogue: $totalBrands'
                      : 'Number of films: $distinctFilmCount / $totalFilmCount',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
