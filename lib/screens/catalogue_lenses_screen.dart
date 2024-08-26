import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/lenses_catalogue_database_helper.dart';

class CatalogueLensesScreen extends StatefulWidget {
  const CatalogueLensesScreen({Key? key}) : super(key: key);

  @override
  _CatalogueLensesScreenState createState() => _CatalogueLensesScreenState();
}

class _CatalogueLensesScreenState extends State<CatalogueLensesScreen> {
  List<String> lensesBrands = [];
  List<String> lensesModels = [];
  String? selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadLensesBrands();
  }

  _loadLensesBrands() async {
    try {
      var brands = await LensesCatalogueDatabaseHelper().getLensesBrands();
      setState(() {
        lensesBrands = brands.map((e) => e['brand'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  _loadLensesModels(String brand) async {
    try {
      String tableName = LensesCatalogueDatabaseHelper().generateTableName(brand);
      var models = await LensesCatalogueDatabaseHelper().getLensesModels(brand);
      setState(() {
        lensesModels = models.map((e) => e['model'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void _showLensesDetails(BuildContext context, Map<String, dynamic> details) {
    List<String> excludedColumns = ['id', 'model'];

    String brand = selectedBrand!.toLowerCase();
    String imageId = details['id'].toString();
    String imagePath = 'assets/images/lenses/$brand/$imageId.jpg';

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
      Image.asset(imagePath), // Display the lenses image
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
        backgroundColor: Colors.grey,
        title: const Text('Lenses Catalogue'),
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
                  items: lensesBrands.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand.replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value!;
                      _loadLensesModels(selectedBrand!);
                    });
                  },
                  hint: const Text('Select a brand'),
                  value: selectedBrand,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: lensesModels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(lensesModels[index]),
                    onTap: () async {
                      Map<String, dynamic> details = await LensesCatalogueDatabaseHelper().getLensesDetails(selectedBrand!, lensesModels[index]);
                      _showLensesDetails(context, details);
                    },

                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
