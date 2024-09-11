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
      var models =
      await FilmsCatalogueDatabaseHelper().getFilmsNamesByBrand(brand);
      setState(() {
        filmNames = models.map((e) => e['name'].toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading film names: $e')),
      );
    }
  }

  void _showFilmDetails(BuildContext context, Map<String, dynamic> details) async {
    // Define columns to exclude from displaying
    List<String> excludedColumns = ['id', 'name'];
    String brand = selectedBrand!.toLowerCase();
    String filmId = details['id'].toString();
    String imageFolderPath = 'assets/films_catalogue/$brand/$filmId/images/';
    String textFolderPath = 'assets/films_catalogue/$brand/$filmId/texts/';

    // Dynamically load all images in the folder
    List<String> imagePaths = await _loadImagesFromFolder(imageFolderPath);

    // Dynamically load all text files in the folder
    List<String> textFiles = await _loadTextFilesFromFolder(textFolderPath);

    // Widgets for image thumbnails
    List<Widget> thumbnailWidgets = imagePaths.map((path) {
      return GestureDetector(
        onTap: () => _showEnlargedImage(context, imagePaths, path),
        child: Image.asset(path, width: 80, height: 80), // Thumbnail size
      );
    }).toList();

    // Widgets for displaying film details
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

    // Widgets for displaying text files in collapsible format
    List<Widget> textDropdownWidgets = textFiles.map((filePath) {
      String fileName = filePath.split('/').last; // Extract the file name
      return FutureBuilder<String>(
        future: _readFilmDescription(filePath), // Read the content of the text file
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator
          }
          if (snapshot.hasError) {
            return Text('Error loading $fileName'); // Error message
          }
          return ExpansionTile(
            title: Text(fileName.replaceAll('_', ' ').split('.').first), // Remove extension and replace underscores
            children: [Text(snapshot.data ?? '')], // Show the content of the text file
          );
        },
      );
    }).toList();

    // Show dialog with film details, images, and text files
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
                ...textDropdownWidgets, // Dynamically generated dropdowns
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

  // Method to show enlarged image
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

    // Filter for files that are in the desired folder path
    final imagePaths = manifestMap.keys
        .where((String key) => key.startsWith(folderPath))
        .toList();

    return imagePaths;
  }

  Future<List<String>> _loadTextFilesFromFolder(String folderPath) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filter for text files that are in the desired folder path
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
                    gridDelegate:
                    SliverGridDelegateWithMaxCrossAxisExtent(
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
                            const Icon(Icons.movie,
                                size: 50, color: Colors.black),
                            const SizedBox(height: 10),
                            Text(filteredBrands[index],
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black)),
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
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                              selectedBrand!, filmNames[index]);
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
                            const Icon(Icons.movie_filter,
                                size: 50, color: Colors.black),
                            const SizedBox(height: 10),
                            Text(filmNames[index],
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black)),
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
