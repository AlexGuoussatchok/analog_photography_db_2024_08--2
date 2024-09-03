import 'dart:convert';  // Import this for JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for rootBundle
import 'package:analog_photography_db/database_helpers/cameras_catalogue_database_helper.dart';

class CatalogueCamerasScreen extends StatefulWidget {
  const CatalogueCamerasScreen({super.key});

  @override
  _CatalogueCamerasScreenState createState() => _CatalogueCamerasScreenState();
}

class _CatalogueCamerasScreenState extends State<CatalogueCamerasScreen> {
  List<String> cameraBrands = [];
  List<String> filteredBrands = [];
  List<String> cameraModels = [];
  String? selectedBrand;
  TextEditingController brandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCameraBrands();
    brandController.addListener(_filterBrands);
  }

  @override
  void dispose() {
    brandController.removeListener(_filterBrands);
    brandController.dispose();
    super.dispose();
  }

  Future<void> _loadCameraBrands() async {
    try {
      var brands = await CamerasCatalogueDatabaseHelper().getCameraBrands();
      setState(() {
        cameraBrands = brands.map((e) => e['brand'].toString()).toList();
        filteredBrands = cameraBrands;
      });
    } catch (e) {
      print(e);
    }
  }

  void _filterBrands() {
    setState(() {
      filteredBrands = cameraBrands
          .where((brand) =>
          brand.toLowerCase().contains(brandController.text.toLowerCase()))
          .toList();
    });
  }

  _loadCameraModels(String brand) async {
    try {
      String tableName = '${brand.toLowerCase()}_cameras_catalogue';
      var models =
      await CamerasCatalogueDatabaseHelper().getCameraModels(tableName);
      setState(() {
        cameraModels = models.map((e) => e['model'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void _showCameraDetails(BuildContext context, Map<String, dynamic> details) async {
    List<String> excludedColumns = ['id', 'model'];
    String brand = selectedBrand!.toLowerCase();
    String modelId = details['id'].toString();
    String imageFolderPath = 'assets/cameras_catalogue/$brand/$modelId/images/';
    String textFolderPath = 'assets/cameras_catalogue/$brand/$modelId/texts/';

    // Dynamically load all images in the folder
    List<String> imagePaths = await _loadImagesFromFolder(imageFolderPath);
    // Dynamically load all text files in the folder
    List<String> textFiles = await _loadTextFilesFromFolder(textFolderPath);

    List<Widget> thumbnailWidgets = imagePaths.map((path) {
      return GestureDetector(
        onTap: () => _showEnlargedImage(context, imagePaths, path),
        child: Image.asset(path, width: 80, height: 80), // Thumbnail size
      );
    }).toList();

    List<Widget> detailWidgets = details.entries
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty && !excludedColumns.contains(entry.key))
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
            Text(entry.key.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(entry.value.toString()),
          ],
        ),
      );
    }).toList();

    List<Widget> textDropdownWidgets = textFiles.map((filePath) {
      String fileName = filePath.split('/').last; // Extract the file name
      return FutureBuilder<String>(
        future: _readCameraDescription(filePath), // Read the content of the text file
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

  Future<String> _readCameraDescription(String path) async {
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
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return PageView.builder(
                itemCount: imagePaths.length,
                controller: PageController(initialPage: initialIndex),
                itemBuilder: (context, index) {
                  return Image.asset(imagePaths[index]);
                },
              );
            },
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
        title: const Text('Cameras Catalogue'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: brandController,
              decoration: InputDecoration(
                labelText: 'Search or Select a Brand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            if (filteredBrands.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredBrands.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredBrands[index]),
                      onTap: () {
                        setState(() {
                          selectedBrand = filteredBrands[index];
                          brandController.text = selectedBrand!;
                          _loadCameraModels(selectedBrand!);
                          filteredBrands = [];
                        });
                      },
                    );
                  },
                ),
              ),

            if (filteredBrands.isEmpty && selectedBrand != null)
              Flexible(
                child: ListView.builder(
                  itemCount: cameraModels.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(cameraModels[index]),
                      onTap: () async {
                        String tableName = '${selectedBrand!.toLowerCase()}_cameras_catalogue';
                        Map<String, dynamic> details = await CamerasCatalogueDatabaseHelper().getCameraDetails(tableName, cameraModels[index]);

                        _showCameraDetails(context, details);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
