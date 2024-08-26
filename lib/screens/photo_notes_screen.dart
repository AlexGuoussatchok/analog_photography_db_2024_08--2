import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/my_notes_database_helper.dart';
import 'package:analog_photography_db/screens/photo_notes_dev_notes.dart';
import 'package:analog_photography_db/screens/photo_notes_history_notes.dart';

class PhotoNotesScreen extends StatefulWidget {
  const PhotoNotesScreen({Key? key}) : super(key: key);

  @override
  _PhotoNotesScreenState createState() => _PhotoNotesScreenState();
}

class _PhotoNotesScreenState extends State<PhotoNotesScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDb();
  }

  void _initializeDb() async {
    try {
      await MyNotesDatabaseHelper.database;
      print("Database initialized successfully");
    } catch (e) {
      print("Error initializing database: $e");
    }
  }

  void _onDevelopingNotesPressed() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const DevelopingNotesScreen(),
    ));
  }

  void _onHistoryNotesPressed() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const HistoryNotesScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onDevelopingNotesPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('My Film Developing Notes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onHistoryNotesPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('My Films History Notes'),
            ),
          ],
        ),
      ),
    );
  }
}
