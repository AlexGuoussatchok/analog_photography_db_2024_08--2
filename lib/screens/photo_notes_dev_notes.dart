import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/database_helpers/my_notes_database_helper.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/films_database_helper.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/cameras_database_helper.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/lenses_database_helper.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/chemicals_database_helper.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;


class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'Lenses'),
      selectedItemBuilder: (BuildContext context) {
        // This builder controls how the selected item is displayed in the dropdown button
        return items.map<Widget>((String item) {
          return Text(
            _truncateWithEllipsis(_replaceUnderscores(item), 30), // Truncate long texts
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: items.map((String item) {
        // This builder controls how items are displayed in the dropdown menu
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            _replaceUnderscores(item),
            softWrap: true,
          ),
        );
      }).toList(),
    );
  }

  String _truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _replaceUnderscores(String text) {
    return text.replaceAll('_', ' ');
  }
}

class DevelopingNotesScreen extends StatefulWidget {
  const DevelopingNotesScreen({super.key});

  @override
  _DevelopingNotesScreenState createState() => _DevelopingNotesScreenState();
}

class _DevelopingNotesScreenState extends State<DevelopingNotesScreen> {
  late Future<List<Map<String, dynamic>>> _notesFuture;
  List<String> filmNames = [];
  List<Map<String, dynamic>> cameraDropdownItems = [];
  String? selectedCamera;
  List<Map<String, dynamic>> lensesDropdownItems = [];
  String? selectedLenses;
  List<String> developers = []; // This list will hold your developers
  String? selectedDeveloper;

  @override
  void initState() {
    super.initState();
    _notesFuture = MyNotesDatabaseHelper().getDevelopingNotes();
    _loadFilmNames();
    _loadCameras();
    _loadLenses();
    _loadDevelopers();
  }

  void _saveAsPdf() async {
    // Check and request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final pdf = pw.Document();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateFormat titleDateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final String titleDate = titleDateFormat.format(DateTime.now());
    final landscapeFormat = PdfPageFormat.a4.landscape;

    final notes = await MyNotesDatabaseHelper().getDevelopingNotes();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: landscapeFormat,
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.Column(
                children: [
                  pw.Text('Developing Notes - $titleDate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                ]
            );
          }
          return pw.Container();
        },
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerHeight: 25,
            cellHeight: 40,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
              8: pw.Alignment.center,
              9: pw.Alignment.center,
              10: pw.Alignment.center,
              11: pw.Alignment.center,
              12: pw.Alignment.center,
              13: pw.Alignment.center,
              14: pw.Alignment.center,
              15: pw.Alignment.center,
            },
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(color: PdfColors.black),
            data: <List<String>>[
              <String>[
                'Date',
                'Film Number',
                'Film Name',
                'ISO',
                'Film Expired?',
                'Expired date',
                'Camera',
                'Lenses',
                'Developer',
                'Lab',
                'Dilution',
                'Dev Time',
                'Temperature',
                'Comments',
              ],
              ...notes.map((note) => [
                note['date']?.toString() ?? 'N/A',
                note['film_number']?.toString() ?? 'N/A',
                note['film_name']?.toString() ?? 'N/A',
                note['ISO']?.toString() ?? 'N/A',
                note['film_expired']?.toString() ?? 'N/A',
                note['film_exp_date']?.toString() ?? 'N/A',
                note['camera']?.toString() ?? 'N/A',
                note['lenses']?.toString() ?? 'N/A',
                note['developer']?.toString() ?? 'N/A',
                note['lab']?.toString() ?? 'N/A',
                note['dilution']?.toString() ?? 'N/A',
                note['dev_time']?.toString() ?? 'N/A',
                note['temp']?.toString() ?? 'N/A',
                note['comments']?.toString() ?? 'N/A',

              ]).toList(),
            ],
          ),
          // ... other content ...
        ],
      ),
    );

    // Save the PDF
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'DevelopingNotes_${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}.pdf',
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(await pdf.save());
      print('Saved PDF at: $result');
    }
  }


  Future<void> _loadDevelopers() async {
    developers = await ChemicalsDatabaseHelper.getDevelopers();
    setState(() {});
  }


  Future<void> _deleteNote(int id) async {
    // Show a confirmation dialog before deleting
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Dismiss dialog and return 'false'
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Dismiss dialog and return 'true'
              },
            ),
          ],
        );
      },
    );

    // If deletion is confirmed, proceed to delete the note
    if (confirmDelete) {
      await MyNotesDatabaseHelper().deleteDevelopingNote(id);
      setState(() {
        _notesFuture = MyNotesDatabaseHelper().getDevelopingNotes();
      });
    }
  }


  Future<void> _loadFilmNames() async {
    filmNames = await FilmsDatabaseHelper.getFilmNamesForDropdown();
    setState(() {});
  }

  Future<void> _loadCameras() async {
    cameraDropdownItems = await CamerasDatabaseHelper().getCamerasForDropdown();
    setState(() {});
  }

  Future<void> _loadLenses() async {
    lensesDropdownItems = await LensesDatabaseHelper().getLensesForDropdown();
    lensesDropdownItems.sort((a, b) => a['displayValue'].compareTo(b['displayValue']));
    setState(() {});
  }

  Future<void> _showAddNoteDialog(BuildContext context) async {
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final maxFilmNumber = await MyNotesDatabaseHelper().getMaxFilmNumber();
    final filmNumberController = TextEditingController(text: '${maxFilmNumber + 1}');
    final filmNameController = TextEditingController();
    final filmTypeController = TextEditingController();
    final filmSizeController = TextEditingController();
    final filmISOController = TextEditingController();
    final filmExpiredController = TextEditingController();
    final filmExpDateController = TextEditingController();
    final cameraController = TextEditingController();
    final lensesController = TextEditingController();
    final developerController = TextEditingController();
    final labController = TextEditingController();
    final dilutionController = TextEditingController();
    final devTimeController = TextEditingController();
    final temperatureController = TextEditingController();
    final commentsController = TextEditingController();

    String? selectedFilmName;

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1965),
        lastDate: DateTime(2055),
      );
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Developing Note'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () => selectDate(context),
                  child: IgnorePointer(
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                      ),
                    ),
                  ),
                ),

                TextField(
                  controller: filmNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Film Number',
                  ),
                  keyboardType: TextInputType.number, // Set the keyboard type to numeric
                ),

                DropdownButtonFormField<String>(
                  value: selectedFilmName,
                  decoration: const InputDecoration(labelText: 'Select Film Name'),
                  onChanged: (String? newValue) async {
                    setState(() {
                      selectedFilmName = newValue;
                    });
                    if (newValue != null) {
                      var parts = newValue.split(' ');
                      var brand = parts[0];
                      var name = parts.sublist(1).join(' ');

                      // Fetch film details
                      var filmDetails = await FilmsDatabaseHelper.getFilmDetails(brand, name);

                      // Update other fields
                      setState(() {
                        filmTypeController.text = filmDetails['filmType'] ?? '';
                        filmSizeController.text = filmDetails['filmSize'] ?? '';
                        filmISOController.text = filmDetails['iso'] ?? '';
                        filmExpiredController.text = filmDetails['filmExpired'] ?? '';
                        filmExpDateController.text = filmDetails['filmExpDate'] ?? '';
                        // Update other fields as needed
                      });
                    }
                  },

                  items: filmNames.map<DropdownMenuItem<String>>((String name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                ),

                TextField(
                  controller: filmTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Film Type',
                  ),
                ),
                TextField(
                  controller: filmSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Film Size',
                  ),
                ),

                TextField(
                  controller: filmISOController,
                  decoration: const InputDecoration(
                    labelText: 'ISO',
                  ),
                  keyboardType: TextInputType.number,
                ),

                TextField(
                  controller: filmExpiredController,
                  decoration: const InputDecoration(
                    labelText: 'Film Expired?',
                  ),
                ),

                TextField(
                  controller: filmExpDateController,
                  decoration: const InputDecoration(
                    labelText: 'Film Expiration Date',
                  ),
                  keyboardType: TextInputType.number,
                ),

                DropdownButtonFormField<String>(
                  value: selectedCamera,
                  decoration: const InputDecoration(labelText: 'Select Camera'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCamera = newValue;
                      // Handle other field updates based on the selected camera
                    });
                  },
                  items: cameraDropdownItems.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                    return DropdownMenuItem<String>(
                      value: item['displayValue'],
                      child: Text(item['displayValue']),
                    );
                  }).toList(),
                ),

                CustomDropdown(
                  items: lensesDropdownItems.map((e) => e['displayValue'] as String).toList(),
                  value: selectedLenses,
                  onChanged: (newValue) {
                    setState(() {
                      selectedLenses = newValue;
                    });
                  },
                ),

                DropdownButtonFormField<String>(
                  value: selectedDeveloper,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDeveloper = newValue;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Developer'), // Label for the dropdown
                  items: developers.map<DropdownMenuItem<String>>((String developer) {
                    return DropdownMenuItem<String>(
                      value: developer,
                      child: Text(developer),
                    );
                  }).toList(),
                ),

                TextField(
                  controller: labController,
                  decoration: const InputDecoration(
                    labelText: 'Lab',
                  ),
                ),

                TextField(
                  controller: dilutionController,
                  decoration: const InputDecoration(
                    labelText: 'Dilution',
                  ),
                ),

                TextField(
                  controller: devTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Dev Time',
                  ),
                ),

                TextField(
                  controller: temperatureController,
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                  ),
                ),

                TextField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Comments',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                await MyNotesDatabaseHelper().insertDevelopingNote({
                  'date': dateController.text,
                  'film_number': filmNumberController.text,
                  'film_name': selectedFilmName,
                  'film_type': filmTypeController.text,
                  'film_size': filmSizeController.text,
                  'iso': filmISOController.text,
                  'film_expired': filmExpiredController.text,
                  'film_exp_date': filmExpDateController.text,
                  'camera': selectedCamera,
                  'lenses': selectedLenses,
                  'developer': selectedDeveloper,
                  'lab': labController.text,
                  'dilution': dilutionController.text,
                  'dev_time': devTimeController.text,
                  'temp': temperatureController.text,
                  'comments': commentsController.text,
                });
                setState(() {
                  _notesFuture = MyNotesDatabaseHelper().getDevelopingNotes();
                });
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
        title: const Text('Developing Notes'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String choice) {
              if (choice == 'Save as PDF') {
                _saveAsPdf();
              }
              // Handle other menu options if any
            },
            itemBuilder: (BuildContext context) {
              return {'Save as PDF'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var note = snapshot.data![index];
                return ListTile(
                  title: Text('${note['date']} - ${note['film_number']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Film: ${note['film_name']} - ISO: ${note['ISO']}'),
                      Text('Developer: ${note['developer']} - Dev Time: ${note['dev_time']}'),
                    ],
                  ),
                  onTap: () {
                    MyNotesDatabaseHelper.showNoteDetails(context, note);
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (String choice) {
                      if (choice == 'Delete') {
                        _deleteNote(note['id']);
                      } else if (choice == 'Edit') {
                        // Implement edit functionality
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No notes found'));
          }
        },
      ),
    );
  }
}
