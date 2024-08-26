import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/exposure_meters_database_helper.dart';
import 'package:analog_photography_db/models/inventory_meters.dart';
import 'package:analog_photography_db/widgets/collection/meters_list_item.dart';
import 'package:analog_photography_db/database_helpers/meters_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/meters_condition_list.dart';


class InventoryCollectionMetersScreen extends StatefulWidget {
  const InventoryCollectionMetersScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionMetersScreenState createState() => _InventoryCollectionMetersScreenState();
}

class _InventoryCollectionMetersScreenState extends State<InventoryCollectionMetersScreen> {
  List<InventoryMeters> _meters = [];
  final List<String> _metersModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogMetersModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadMeters();
  }

  _loadMeters() async {
    var meters = await MetersDatabaseHelper.fetchMeters();

    if (mounted) {
      setState(() {
        _meters = meters;
        _isLoading = false;
      });
    }
  }


  Future<void> _updateMetersModels() async {
    if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
      final modelsData = await MetersCatalogueDatabaseHelper().getMetersModelsByBrand(_dialogSelectedBrand!);

      setState(() {
        _dialogMetersModels = modelsData.map((item) => item['model'] as String).toList();
      });
    } else {
      setState(() {
        _dialogMetersModels = [];
      });
    }
  }

  void _showAddMetersDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await MetersCatalogueDatabaseHelper().getMetersBrands();
    final List<String> brandNames = brandList.map((e) => e['brands'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogMetersModels = [];

    final modelController = TextEditingController();
    final serialNumberController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateMetersModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final metersCatalogueDbHelper = MetersCatalogueDatabaseHelper();
        final modelsData = await metersCatalogueDbHelper.getMetersModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogMetersModels = modelsData.map((item) => item['model'] as String).toList();
          modelController.text = ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogMetersModels = [];
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
          title: const Text('Add New Exposure Meter'),
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
                        updateMetersModels(dialogSetState);  // Passing the StateSetter to updateMetersModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController.text : null,  // Use the value of modelController for the dropdown value.
                      items: dialogMetersModels.map((String model) {
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
                      items: metersConditions.map((String condition) {
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

                final newMeters = InventoryMeters(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  serialNumber: serialNumberController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await MetersDatabaseHelper.insertMeters(newMeters);
                _loadMeters();

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
        title: const Text("Exposure Meters Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _meters.length,
        itemBuilder: (context, index) {
          return MetersListItem(meters: _meters[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMetersDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
