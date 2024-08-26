import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/dryers_database_helper.dart';
import 'package:analog_photography_db/models/inventory_dryers.dart';
import 'package:analog_photography_db/widgets/collection/dryers_list_item.dart';
import 'package:analog_photography_db/database_helpers/dryers_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/dryers_conditions_list.dart';


class InventoryCollectionDryersScreen extends StatefulWidget {
  const InventoryCollectionDryersScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionDryersScreenState createState() => _InventoryCollectionDryersScreenState();
}

class _InventoryCollectionDryersScreenState extends State<InventoryCollectionDryersScreen> {
  List<InventoryDryers> _dryers = [];
  final List<String> _dryersModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogDryersModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadDryers();
  }

  _loadDryers() async {
    var dryers = await DryersDatabaseHelper.fetchDryers();

    if (mounted) {
      setState(() {
        _dryers = dryers;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDryersModels() async {
    if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
      final modelsData = await DryersCatalogueDatabaseHelper().getDryersModelsByBrand(_dialogSelectedBrand!);

      setState(() {
        _dialogDryersModels = modelsData.map((item) => item['model'] as String).toList();
      });
    } else {
      setState(() {
        _dialogDryersModels = [];
      });
    }
  }

  void _showAddDryersDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await DryersCatalogueDatabaseHelper().getDryersBrands();
    final List<String> brandNames = brandList.map((e) => e['brand'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogDryersModels = [];

    final modelController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateDryersModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final dryersCatalogueDbHelper = DryersCatalogueDatabaseHelper();
        final modelsData = await dryersCatalogueDbHelper.getDryersModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogDryersModels = modelsData.map((item) => item['model'] as String).toList();
          modelController.text = ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogDryersModels = [];
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
          title: const Text('Add New Dryers'),
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
                        updateDryersModels(dialogSetState);  // Passing the StateSetter to updateDryersModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController.text : null,  // Use the value of modelController for the dropdown value.
                      items: dialogDryersModels.map((String model) {
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
                      items: dryersConditions.map((String condition) {
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

                final newDryers = InventoryDryers(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await DryersDatabaseHelper.insertDryers(newDryers);
                _loadDryers();

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
        title: const Text("Dryers Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _dryers.length,
        itemBuilder: (context, index) {
          return DryersListItem(dryers: _dryers[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDryersDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
