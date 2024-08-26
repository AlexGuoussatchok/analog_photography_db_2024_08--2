import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/lenses_database_helper.dart';
import 'package:analog_photography_db/models/inventory_lenses.dart';
import 'package:analog_photography_db/widgets/collection/lenses_list_item.dart';
import 'package:analog_photography_db/database_helpers/lenses_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/lenses_condition_list.dart';
import 'package:intl/intl.dart';


class InventoryCollectionLensesScreen extends StatefulWidget {
  const InventoryCollectionLensesScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionLensesScreenState createState() => _InventoryCollectionLensesScreenState();
}

class _InventoryCollectionLensesScreenState extends State<InventoryCollectionLensesScreen> {
  List<InventoryLenses> _lenses = [];
  final List<String> _lensesModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogLensesModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadLenses();
  }

  _loadLenses() async {
    var lenses = await LensesDatabaseHelper.fetchLenses();

    if (mounted) {
      setState(() {
        _lenses = lenses;
        _isLoading = false;
      });
    }
  }


  Future<void> _updateLensesModels() async {
    if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
      final modelsData = await LensesCatalogueDatabaseHelper().getLensesModelsByBrand(_dialogSelectedBrand!);

      setState(() {
        _dialogLensesModels = modelsData.map((item) => item['model'] as String).toList();
      });
    } else {
      setState(() {
        _dialogLensesModels = [];
      });
    }
  }

  void _showLensDetailsDialog(BuildContext context, InventoryLenses lens) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lens Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Brand: ${lens.brand}'),
                Text('Model: ${lens.model}'),
                Text('Serial Number: ${lens.serialNumber ?? "N/A"}'),
                Text('Purchase Date: ${lens.purchaseDate != null ? DateFormat('yyyy-MM-dd').format(lens.purchaseDate!) : "N/A"}'),
                Text('Price Paid: ${lens.pricePaid != null ? "${lens.pricePaid} €" : "N/A"}'),
                Text('Condition: ${lens.condition}'),
                Text('Average Price: ${lens.averagePrice != null ? "${lens.averagePrice} €" : "N/A"}'),
                Text('Comments: ${lens.comments ?? "N/A"}'),
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


  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this lens?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;  // Returning false if the dialog is dismissed
  }

  void _showAddLensesDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await LensesCatalogueDatabaseHelper().getLensesBrands();
    final List<String> brandNames = brandList.map((e) => e['brand'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogLensesModels = [];

    final modelController = TextEditingController();
    final serialNumberController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateLensesModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final lensesCatalogueDbHelper = LensesCatalogueDatabaseHelper();
        final modelsData = await lensesCatalogueDbHelper.getLensesModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogLensesModels = modelsData.map((item) => item['model'] as String).toList();
          modelController.text = ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogLensesModels = [];
        });
      }
    }

    Future<void> selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2222),
      );
      if (pickedDate != null && pickedDate != selectedDate) {
        setState(() {
          selectedDate = pickedDate;
          purchaseDateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // formats it to yyyy-mm-dd
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Lenses'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: dialogSelectedBrand,
                      items: brandNames.map((String brand) {
                        return DropdownMenuItem<String>(
                          value: brand,
                          child: Text(brand.replaceAll('_', ' ')),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        dialogSetState(() {
                          dialogSelectedBrand = newValue;
                          modelController.text = '';  // Clear the model when brand changes.
                        });
                        updateLensesModels(dialogSetState);  // Passing the StateSetter to updateLensesModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController.text : null,  // Use the value of modelController for the dropdown value.
                      items: dialogLensesModels.map((String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        dialogSetState(() {
                          modelController.text = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),

                    TextField(
                      controller: serialNumberController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Serial Number'),
                    ),

                    TextField(
                      controller: purchaseDateController,
                      readOnly: true,  // Makes the text field read-only, so it's not editable
                      decoration: const InputDecoration(labelText: 'Purchase Date'),
                      onTap: () {
                        selectDate(context);
                      },
                    ),

                    TextField(
                      controller: pricePaidController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),  // Ensures numeric keyboard layout
                      decoration: const InputDecoration(
                        labelText: 'Price Paid',
                        suffixText: '€',  // Display Euro sign at the end
                      ),
                    ),


                    DropdownButtonFormField<String>(
                      value: conditionController.text.isEmpty ? null : conditionController.text,
                      items: lensesConditions.map((String condition) {
                        return DropdownMenuItem<String>(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          conditionController.text = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Condition'),
                    ),

                    TextField(
                      controller: averagePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),  // Ensures numeric keyboard layout
                      decoration: const InputDecoration(
                        labelText: 'Average Price',
                        suffixText: '€',  // Display Euro sign at the end
                      ),
                    ),

                    TextField(
                      controller: commentsController,
                      decoration: const InputDecoration(labelText: 'Comments'),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                double? pricePaid = double.tryParse(pricePaidController.text);
                double? averagePrice = double.tryParse(averagePriceController.text);

                final newLenses = InventoryLenses(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  serialNumber: serialNumberController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await LensesDatabaseHelper.insertLenses(newLenses);
                _loadLenses();

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
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
        automaticallyImplyLeading: false,
        title: const Text("Lenses Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _lenses.length,
        itemBuilder: (context, index) {
          final lens = _lenses[index];
          return ListTile(
            title: Text('${lens.brand} ${lens.model}'), // Customize with your lens details
            subtitle: Text('Serial: ${lens.serialNumber ?? "N/A"}'), // Optional
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () async {
                bool confirmDelete = await _showDeleteConfirmationDialog(context);
                if (confirmDelete) {
                  await LensesDatabaseHelper.deleteLens(lens.id!);
                  setState(() {
                    _lenses.removeAt(index);
                  });
                }
              },
            ),
            onTap: () {
              // Code to show lens details - Add your existing detail view logic here
              _showLensDetailsDialog(context, lens);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLensesDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
