import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/darkroom_database_helper.dart';


class DarkroomScreen extends StatefulWidget {
  const DarkroomScreen({Key? key}) : super(key: key);

  @override
  _DarkroomScreenState createState() => _DarkroomScreenState();
}

class _DarkroomScreenState extends State<DarkroomScreen> {

  String formatDeveloperName(String developerName) {
    // Replace underscores with spaces and capitalize each word
    return developerName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _initializeDb();
  }

  void _initializeDb() async {
    try {
      // Access the database to ensure it is initialized
      var db = await DarkroomDatabaseHelper.database;
      // Database initialized successfully
      print("Database initialized successfully");
    } catch (e) {
      // Handle any errors here
      print("Error initializing database: $e");
    }
  }

  void _showDevChartDialog() async {
    List<String> developers = await DarkroomDatabaseHelper().getDevelopers();
    print("Developers loaded: $developers");
    String? selectedDeveloper;
    List<String> films = [];
    String? selectedFilm;
    Map<String, dynamic>? filmData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Official Devchart'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedDeveloper,
                      onChanged: (value) async {
                        print("Selected Developer: $value");
                        selectedDeveloper = value;
                        films = await DarkroomDatabaseHelper().getFilmsForDeveloper(value!);
                        print("Films for $value: $films");
                        selectedFilm = null; // Reset film selection
                        filmData = null; // Reset film data
                        setState(() {}); // Update state of dialog
                      },
                      items: developers.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(formatDeveloperName(value)),
                        );
                      }).toList(),
                      hint: const Text('Select Developer'),
                    ),
                    if (films.isNotEmpty) ...[
                      DropdownButton<String>(
                        value: selectedFilm,
                        onChanged: (value) async {
                          print("Selected Film: $value");
                          selectedFilm = value;
                          filmData = await DarkroomDatabaseHelper().getFilmData(selectedDeveloper!, value!);
                          setState(() {}); // Update state of dialog
                        },
                        items: films.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: const Text('Select Film'),
                      ),
                      // Display film data if available
                      if (filmData != null) ...[
                        for (var entry in filmData!.entries) // '!' added for null safety
                          ListTile(
                            title: Text(entry.key),
                            subtitle: Text(entry.value.toString()),
                          ),
                      ],
                    ],
                  ],
                ),
              );
            },
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
        title: const Text('Darkroom'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showDevChartDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32), // Increased padding
                textStyle: const TextStyle(fontSize: 20), // Increased font size
              ),
              child: const Text('Official Devchart'),
            ),
          ],
        ),
      ),
    );
  }
}
