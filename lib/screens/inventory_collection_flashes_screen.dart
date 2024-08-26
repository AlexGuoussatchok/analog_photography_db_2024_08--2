import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/flashes_database_helper.dart';
import 'package:analog_photography_db/models/inventory_flashes.dart';
import 'package:analog_photography_db/widgets/collection/flashes_list_item.dart';
import 'package:analog_photography_db/database_helpers/flashes_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/flashes_condition_list.dart';


class InventoryCollectionFlashesScreen extends StatefulWidget {
  const InventoryCollectionFlashesScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionFlashesScreenState createState() => _InventoryCollectionFlashesScreenState();
}

class _InventoryCollectionFlashesScreenState extends State<InventoryCollectionFlashesScreen> {
  List<InventoryFlashes> _flashes = [];
  final List<String> _flashesModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogFlashesModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadFlashes();
  }

  _loadFlashes() async {
    var flashes = await FlashesDatabaseHelper.fetchFlashes();

    if (mounted) {
      setState(() {
        _flashes = flashes;
        _isLoading = false;
      });
    }
  }


  Future<void> _updateFlashesModels() async {
    if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
      final modelsData = await FlashesCatalogueDatabaseHelper().getFlashesModelsByBrand(_dialogSelectedBrand!);

      setState(() {
        _dialogFlashesModels = modelsData.map((item) => item['model'] as String).toList();
      });
    } else {
      setState(() {
        _dialogFlashesModels = [];
      });
    }
  }

  Future<void> _deleteFlash(int id) async {
    await FlashesDatabaseHelper.deleteFlash(id);
    _loadFlashes();  // Reload the list to reflect the change
  }

  Future<void> _confirmDelete(int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Flash"),
          content: Text("Are you sure you want to delete this flash?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                _deleteFlash(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddFlashesDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await FlashesCatalogueDatabaseHelper().getFlashesBrands();
    final List<String> brandNames = brandList.map((e) => e['brands'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogFlashesModels = [];

    final modelController = TextEditingController();
    final serialNumberController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateFlashesModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final flashesCatalogueDbHelper = FlashesCatalogueDatabaseHelper();
        final modelsData = await flashesCatalogueDbHelper.getFlashesModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogFlashesModels = modelsData.map((item) => item['model'] as String).toList();
          modelController.text = ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogFlashesModels = [];
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
      if (pickedDate != null && pickedDate != selectedDate)
        setState(() {
          selectedDate = pickedDate;
          purchaseDateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // formats it to yyyy-mm-dd
        });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Flash'),
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
                          child: Text(brand),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        dialogSetState(() {
                          dialogSelectedBrand = newValue;
                          modelController.text = '';  // Clear the model when brand changes.
                        });
                        updateFlashesModels(dialogSetState);  // Passing the StateSetter to updateFlashesModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController.text : null,  // Use the value of modelController for the dropdown value.
                      items: dialogFlashesModels.map((String model) {
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
                      items: flashesConditions.map((String condition) {
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

                final newFlashes = InventoryFlashes(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  serialNumber: serialNumberController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await FlashesDatabaseHelper.insertFlashes(newFlashes);
                _loadFlashes();

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
        title: const Text("Flashes Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _flashes.length,
        itemBuilder: (context, index) {
          final flash = _flashes[index];
          return ListTile(
            title: FlashesListItem(flashes: flash),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDelete(flash.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFlashesDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
