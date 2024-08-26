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
      var models = await CamerasCatalogueDatabaseHelper().getCameraModels(tableName);
      setState(() {
        cameraModels = models.map((e) => e['model'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void _showCameraDetails(BuildContext context, Map<String, dynamic> details) {
    List<String> excludedColumns = ['id', 'model'];

    String brand = selectedBrand!.toLowerCase();
    String imageId = details['id'].toString();
    String imagePath = 'assets/images/cameras/$brand/$imageId.jpg';
    String textPath = 'assets/texts/cameras/$brand/$imageId.txt';

    List<Widget> detailWidgets = details.entries.where((entry) =>
    // Exclude entries that are null or in the excludedColumns list
    entry.value != null &&
        entry.value.toString().isNotEmpty &&
        !excludedColumns.contains(entry.key)
    ).toList().asMap().entries.map((mapEntry) {
      int index = mapEntry.key;
      MapEntry<String, dynamic> entry = mapEntry.value;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          color: index.isEven ? Colors.grey.shade100 : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              entry.key.replaceAll('_', ' '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ), // The column name
            const SizedBox(height: 4.0),
            Text(entry.value.toString()), // The value for that column
          ],
        ),
      );
    }).toList();

    // Combined list of widgets with image and details
    List<Widget> combinedWidgets = [
      Image.asset(imagePath),
      Text(details['model']?.replaceAll('_', ' ') ?? "Unknown Model"),
      const SizedBox(height: 10.0),
      ...detailWidgets
    ];

    _readCameraDescription(textPath).then((cameraDescription) {
      // Add the description text to combinedWidgets
      combinedWidgets.add(Text(cameraDescription));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: combinedWidgets,
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
    });
  }

  Future<String> _readCameraDescription(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print("Error reading text file: $e");
      return "Description not available.";
    }
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
