import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/films_catalogue_database_helper.dart';

class CatalogueFilmsScreen extends StatefulWidget {
  const CatalogueFilmsScreen({Key? key}) : super(key: key);

  @override
  _CatalogueFilmsScreenState createState() => _CatalogueFilmsScreenState();
}

class _CatalogueFilmsScreenState extends State<CatalogueFilmsScreen> {
  List<String> filmBrands = [];
  List<String> filmNames = [];
  String? selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadFilmsBrands();
  }

  _loadFilmsBrands() async {
    try {
      var brands = await FilmsCatalogueDatabaseHelper().getFilmsBrands();
      setState(() {
        filmBrands = brands.map((e) => e['brand'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  _loadFilmsNames(String brand) async {
    try {
      var models = await FilmsCatalogueDatabaseHelper().getFilmsNamesByBrand(brand);
      setState(() {
        filmNames = models.map((e) => e['name'].toString()).toList();
      });
    } catch (e) {
      print(e);
    }
  }


  void _showFilmDetails(BuildContext context, Map<String, dynamic> details) {
    List<String> excludedColumns = ['id', 'name'];

    String brand = selectedBrand!.toLowerCase();
    String imageId = details['id'].toString();
    String imagePath = 'assets/images/films/$brand/$imageId.jpg';

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
      Image.asset(imagePath), // Display the camera image
      Text(details['name']?.replaceAll('_', ' ') ?? "Unknown Film"),
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
        title: const Text('Films Catalogue'),
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
                  items: filmBrands.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value!;
                      _loadFilmsNames(selectedBrand!);
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
                itemCount: filmNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filmNames[index]),
                    onTap: () async {
                      Map<String, dynamic>? details = await FilmsCatalogueDatabaseHelper().getFilmDetailsByBrandAndName(selectedBrand!, filmNames[index]);
                      if(details != null) {
                        _showFilmDetails(context, details);
                      } else {
                        print('Error: Film details not found.');
                      }
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
