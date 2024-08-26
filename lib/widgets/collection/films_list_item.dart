import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_films.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/films_database_helper.dart';

class FilmsListItem extends StatelessWidget {
  final InventoryFilms films;
  final Function onDelete;

  const FilmsListItem({Key? key, required this.films, required this.onDelete}) : super(key: key);


  void _showFilmsDetails(BuildContext context, Map<String, dynamic> details) {
    List<String> excludedColumns = ['id'];

    List<Widget> detailWidgets = details.entries.where((entry) =>
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
        child: Row(
          children: [
            Expanded(
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
            ),
          ],
        ),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detailWidgets,
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
    return ListTile(
      title: Text("${films.brand} ${films.name}"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the left
        children: [
          Text('Expiration Date: ${films.expirationDate ?? 'Not set'}'),
          Text('Quantity: ${films.quantity}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit functionality later
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final bool confirmed = await _showDeleteConfirmation(context);
              if (confirmed && films.id != null) {  // Check if films.id is non-nullable
                // Delete the film from the database
                await FilmsDatabaseHelper.deleteFilms(films.id!);
                onDelete();
                // Optionally: Refresh the list or remove the film from the in-memory list
                // This can be done using a callback or a state management solution
              }
            },
          ),
        ],
      ),
      onTap: () {
        _showFilmsDetails(context, films.toMap());
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Film'),
        content: const Text('Are you sure you want to delete this film?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ) ?? false;  // Return false if user taps outside the dialog
  }
}

