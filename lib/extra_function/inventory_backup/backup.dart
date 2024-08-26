import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';



class BackupDialog extends StatefulWidget {
  const BackupDialog({super.key});

  @override
  _BackupDialogState createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  Map<String, bool> databasesToBackup = {
    'inventory_borrowed_stuff.db': false,
    'inventory_collection.db': false,
    'inventory_sell_list.db': false,
    'inventory_wishlist.db': false,
    'my_notes.db': false,
  };

  Future<String?> selectBackupLocation() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
      return null;
    }
    return selectedDirectory;
  }

  Future<bool> backupDatabases(
      Map<String, bool> databasesToBackup, String backupDirectory) async {
    try {
      for (var entry in databasesToBackup.entries) {
        if (entry.value) {
          String dbPath = await getDatabasesPath() + '/' + entry.key;
          File dbFile = File(dbPath);

          // Check if the file already exists in the backup directory
          String backupFilePath = '$backupDirectory/${entry.key}';
          File backupFile = File(backupFilePath);

          if (await backupFile.exists()) {
            // File exists, append a timestamp to create a unique file name
            String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            String newFileName = '${entry.key}_$timestamp';
            backupFilePath = '$backupDirectory/$newFileName';
          }

          // Perform the actual file copy
          await dbFile.copy(backupFilePath);
        }
      }
      return true; // Backup successful
    } catch (e) {
      print('Backup error: $e');
      return false; // Backup failed
    }
  }


  void _handleBackup() async {
    String? backupLocation = await selectBackupLocation();
    if (backupLocation != null) {
      bool success = await backupDatabases(databasesToBackup, backupLocation);
      if (mounted) { // Check if the widget is still mounted
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup successful')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup failed')),
          );
        }
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> importDatabase(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      // Process the file, rename if necessary, and move/replace it in the app's database directory
    } else {
      // User canceled the picker
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Databases to Backup'),
      content: SingleChildScrollView(
        child: ListBody(
          children: databasesToBackup.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: databasesToBackup[key],
              onChanged: (bool? value) {
                setState(() {
                  databasesToBackup[key] = value!;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Backup'),
          onPressed: () {
            _handleBackup(); // Just call the function without await
            Navigator.of(context).pop();
          },
        ),

      ],
    );
  }
}

class BackupUtils {
  static Future<void> importDatabase(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);

      // Check if the selected file is a .db file
      if (filePath.endsWith('.db')) {
        String dbName = file.path.split('/').last;
        String dbPath = await getDatabasesPath() + '/' + dbName;

        // Replace the existing database
        await file.copy(dbPath);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database imported successfully')),
        );
      } else {
        // If the file is not a .db file, inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid .db file')),
        );
      }
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database import cancelled')),
      );
    }
  }


}