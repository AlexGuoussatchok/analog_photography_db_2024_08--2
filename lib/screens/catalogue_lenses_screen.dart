import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:analog_photography_db/database_helpers/lenses_catalogue_database_helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CatalogueLensesScreen extends StatefulWidget {
  const CatalogueLensesScreen({Key? key}) : super(key: key);

  @override
  _CatalogueLensesScreenState createState() => _CatalogueLensesScreenState();
}

class _CatalogueLensesScreenState extends State<CatalogueLensesScreen> {
  List<String> lensesBrands = [];
  List<String> filteredBrands = [];
  List<String> lensesModels = [];
  List<String> filteredModels = [];
  String? selectedBrand;
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  bool isLoading = false;
  int totalBrands = 0; // To store total number of brands
  int distinctModelCount = 0; // To store distinct model count
  int totalModelCount = 0; // To store total model count including variants

  @override
  void initState() {
    super.initState();
    _loadLensesBrands();
    brandController.addListener(_filterBrands);
    modelController.addListener(_filterModels);
  }

  @override
  void dispose() {
    brandController.removeListener(_filterBrands);
    brandController.dispose();
    modelController.removeListener(_filterModels);
    modelController.dispose();
    super.dispose();
  }

  Future<void> _loadLensesBrands() async {
    try {
      setState(() {
        isLoading = true;
      });
      var brands = await LensesCatalogueDatabaseHelper().getLensesBrands();
      setState(() {
        lensesBrands = brands.map((e) => e['brand'].toString()).toList();
        filteredBrands = lensesBrands;
        totalBrands = lensesBrands.length; // Set total number of brands
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
      filteredBrands = lensesBrands
          .where((brand) =>
          brand.toLowerCase().contains(brandController.text.toLowerCase()))
          .toList();
    });
  }

  void _filterModels() {
    setState(() {
      filteredModels = lensesModels
          .where((model) =>
          model.toLowerCase().contains(modelController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadLensesModels(String brand) async {
    try {
      var models = await LensesCatalogueDatabaseHelper().getLensesModels(brand);

      // Create a set to keep track of distinct models
      Set<String> distinctModels = {};
      int totalModels = 0;

      for (var model in models) {
        distinctModels.add(model['model'].toString().split('(')[0].trim()); // Get distinct models
        totalModels++;
      }

      setState(() {
        lensesModels = models.map((e) => e['model'].toString()).toList();
        filteredModels = lensesModels;
        distinctModelCount = distinctModels.length; // Number of distinct models
        totalModelCount = totalModels; // Total number of models including variants
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lens models: $e')),
      );
    }
  }

  void _showLensesDetails(BuildContext context, Map<String, dynamic> details) async {
    List<String> excludedColumns = ['id', 'model'];
    String brand = selectedBrand!.toLowerCase();
    String modelId = details['id'].toString();
    String imageFolderPath = 'assets/lenses_catalogue/$brand/$modelId/images/';
    String textFolderPath = 'assets/lenses_catalogue/$brand/$modelId/texts/';

    List<String> imagePaths = await _loadImagesFromFolder(imageFolderPath);
    List<String> textFiles = await _loadTextFilesFromFolder(textFolderPath);

    List<Widget> thumbnailWidgets = imagePaths.map((path) {
      return GestureDetector(
        onTap: () => _showEnlargedImage(context, imagePaths, path),
        child: Image.asset(path, width: 80, height: 80), // Thumbnail size
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
      String fileName = filePath.split('/').last; // Extract the file name
      return FutureBuilder<String>(
        future: _readLensDescription(filePath), // Read the content of the text file
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error loading $fileName');
          }
          return ExpansionTile(
            title: Text(fileName.replaceAll('_', ' ').split('.').first), // Remove extension and replace underscores
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

  Future<String> _readLensDescription(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print("Error reading text file: $e");
      return "Description not available.";
    }
  }

  void _showEnlargedImage(BuildContext context, List<String> imagePaths, String selectedImage) {
    int initialIndex = imagePaths.indexOf(selectedImage);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PhotoViewGallery.builder(
            itemCount: imagePaths.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(imagePaths[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Lenses Catalogue'),
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
                    controller: modelController,
                    decoration: InputDecoration(
                      labelText: 'Search or Select a Model',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          modelController.clear();
                          _filterModels();
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
                        leading: const Icon(Icons.camera_alt, size: 30),
                        onTap: () {
                          setState(() {
                            selectedBrand = filteredBrands[index];
                            brandController.text = selectedBrand!;
                            _loadLensesModels(selectedBrand!);
                            filteredBrands = [];
                          });
                        },
                      );
                    },
                  )
                      : ListView.builder(
                    itemCount: filteredModels.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredModels[index]),
                        leading: const Icon(Icons.camera, size: 30),
                        onTap: () async {
                          Map<String, dynamic> details = await LensesCatalogueDatabaseHelper()
                              .getLensesDetails(selectedBrand!, filteredModels[index]);
                          _showLensesDetails(context, details);
                        },
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
                      : 'Number of models: $distinctModelCount / $totalModelCount',
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
