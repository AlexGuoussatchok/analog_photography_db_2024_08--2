import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:analog_photography_db/database_helpers/cameras_catalogue_database_helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  bool isLoading = false; // Initialize loading state

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
      setState(() {
        isLoading = true; // Show loading indicator
      });
      var brands = await CamerasCatalogueDatabaseHelper().getCameraBrands();
      setState(() {
        cameraBrands = brands.map((e) => e['brand'].toString()).toList();
        filteredBrands = cameraBrands;
        isLoading = false; // Hide loading indicator
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading brands: $e')),
      );
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

  Future<void> _loadCameraModels(String brand) async {
    try {
      String tableName = '${brand.toLowerCase()}_cameras_catalogue';
      var models = await CamerasCatalogueDatabaseHelper().getCameraModels(tableName);
      setState(() {
        cameraModels = models.map((e) => e['model'].toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading camera models: $e')),
      );
    }
  }

  void _showCameraDetails(BuildContext context, Map<String, dynamic> details) async {
    List<String> excludedColumns = ['id', 'model'];
    String brand = selectedBrand!.toLowerCase();
    String modelId = details['id'].toString();
    String imageFolderPath = 'assets/cameras_catalogue/$brand/$modelId/images/';
    String textFolderPath = 'assets/cameras_catalogue/$brand/$modelId/texts/';

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
        future: _readCameraDescription(filePath),
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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cameras Catalogue',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator when loading
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
                      _filterBrands(); // Reset filtered brands
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
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                            _loadCameraModels(selectedBrand!);
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
                            const Icon(Icons.camera_alt, size: 50, color: Colors.black),
                            const SizedBox(height: 10),
                            Text(filteredBrands[index], style: const TextStyle(fontSize: 18, color: Colors.black)),
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
                    itemCount: cameraModels.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: () async {
                          String tableName = '${selectedBrand!.toLowerCase()}_cameras_catalogue';
                          Map<String, dynamic> details = await CamerasCatalogueDatabaseHelper().getCameraDetails(tableName, cameraModels[index]);
                          _showCameraDetails(context, details);
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
                            const Icon(Icons.camera, size: 50, color: Colors.black),
                            const SizedBox(height: 10),
                            Text(cameraModels[index], style: const TextStyle(fontSize: 18, color: Colors.black)),
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
