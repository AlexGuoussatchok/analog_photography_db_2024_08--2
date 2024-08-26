import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:analog_photography_db/database_helpers/chemicals_catalogue_database_helper.dart';

class CatalogueChemicalsScreen extends StatefulWidget {
  const CatalogueChemicalsScreen({Key? key}) : super(key: key);

  @override
  _CatalogueChemicalsScreenState createState() => _CatalogueChemicalsScreenState();
}

class _CatalogueChemicalsScreenState extends State<CatalogueChemicalsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> developers = [];
  List<Map<String, dynamic>> fixers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChemicals();
  }

  _loadChemicals() async {
    try {
      developers = await ChemicalsCatalogueDatabaseHelper().getChemicals('developers', 'developer');
      fixers = await ChemicalsCatalogueDatabaseHelper().getChemicals('fixers', 'fixer');
      setState(() {});
    } catch (e) {
      print("Error loading chemicals: $e");
    }
  }

  Future<String> loadChemicalText(String type, int id) async {
    try {
      final path = 'assets/texts/$type/$id.txt';
      return await rootBundle.loadString(path);
    } catch (e) {
      print("Error loading text file: $e");
      return "Description not available.";
    }
  }

  void _showChemicalDetails(BuildContext context, Map<String, dynamic> chemical, String type) async {
    String folder = type == 'developer' ? 'developers' : 'fixers';
    String imagePath = 'assets/images/$folder/${chemical['id'].toString()}.jpg'; // Adjust file extension as needed
    String chemicalText = await loadChemicalText(type, chemical['id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(imagePath, errorBuilder: (context, error, stackTrace) {
                  return const Text('Image not available');
                }),
                Text(chemical[type]), // Display the chemical name
                const SizedBox(height: 10),
                Text(chemicalText), // Display the text from the file
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
        title: const Text('Chemicals Catalogue'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Developers'),
            Tab(text: 'Fixers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChemicalList(developers, 'developer'),
          _buildChemicalList(fixers, 'fixer'),
        ],
      ),
    );
  }

  Widget _buildChemicalList(List<Map<String, dynamic>> chemicals, String type) {
    return ListView.builder(
      itemCount: chemicals.length,
      itemBuilder: (context, index) {
        var chemical = chemicals[index];
        return ListTile(
          title: Text(chemical[type]),
          onTap: () => _showChemicalDetails(context, chemical, type), // Pass the correct type
        );
      },
    );
  }


  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
