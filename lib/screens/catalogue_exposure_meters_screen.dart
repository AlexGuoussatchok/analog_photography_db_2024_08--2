import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/meters_catalogue_database_helper.dart';

class CatalogueMetersScreen extends StatefulWidget {
  const CatalogueMetersScreen({Key? key}) : super(key: key);

  @override
  _CatalogueMetersScreenState createState() => _CatalogueMetersScreenState();
}

class _CatalogueMetersScreenState extends State<CatalogueMetersScreen> {
  List<String> metersBrands = [];
  List<String> metersModels = [];
  String? selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadMetersBrands();
  }

  _loadMetersBrands() async {
    try {
      var brands = await MetersCatalogueDatabaseHelper().getMetersBrands();
      setState(() {
        metersBrands = brands.map((e) => e['brands'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  _loadMetersModels(String brands) async {
    try {
      String tableName = '${brands.toLowerCase()}_meters_catalogue';
      var models = await MetersCatalogueDatabaseHelper().getMetersModels(tableName);

      setState(() {
        metersModels = models.map((e) => e['model'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }


  void _showItemDetails(BuildContext context, Map<String, dynamic> details) {
    List<String> excludedColumns = ['id', 'model'];

    String brand = selectedBrand!.toLowerCase();
    String imageId = details['id'].toString();

    // Modify the imagePath for lenses
    String imagePath = 'assets/images/meters/$brand/$imageId.jpg';

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
      Image.asset(imagePath), // Display the lens image
      Text(details['model']?.replaceAll('_', ' ') ?? "Unknown Model"),
      const SizedBox(height: 10.0), // Optional: To add some spacing
      ...detailWidgets
    ];

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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meters Catalogue'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: metersBrands.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value!;
                      metersModels.clear();
                      _loadMetersModels(value);
                    });
                  },
                  hint: const Text('Select a Brand'),
                  value: selectedBrand,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: metersModels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(metersModels[index]),
                    onTap: () async {
                      String tableName = '${selectedBrand!.toLowerCase()}_meters_catalogue';
                      var lensDetails = await MetersCatalogueDatabaseHelper().getMetersDetails(tableName, metersModels[index]);
                      _showItemDetails(context, lensDetails);
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
