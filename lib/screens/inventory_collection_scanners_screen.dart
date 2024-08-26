import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/scanners_database_helper.dart';
import 'package:analog_photography_db/models/inventory_scanners.dart';
import 'package:analog_photography_db/widgets/collection/scanners_list_item.dart';
import 'package:analog_photography_db/database_helpers/film_scanners_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/scanners_conditions_list.dart';


class InventoryCollectionScannersScreen extends StatefulWidget {
  const InventoryCollectionScannersScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionScannersScreenState createState() => _InventoryCollectionScannersScreenState();
}

class _InventoryCollectionScannersScreenState extends State<InventoryCollectionScannersScreen> {
  List<InventoryScanners> _scanners = [];
  final List<String> _scannersModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogScannersModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadScanners();
  }

  _loadScanners() async {
    var scanners = await ScannersDatabaseHelper.fetchScanners();

    if (mounted) {
      setState(() {
        _scanners = scanners;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateScannersModels() async {
    if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
      final modelsData = await ScannersCatalogueDatabaseHelper().getScannersModelsByBrand(_dialogSelectedBrand!);

      setState(() {
        _dialogScannersModels = modelsData.map((item) => item['model'] as String).toList();
      });
    } else {
      setState(() {
        _dialogScannersModels = [];
      });
    }
  }

  void _showAddScannersDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await ScannersCatalogueDatabaseHelper().getScannersBrands();
    final List<String> brandNames = brandList.map((e) => e['brand'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogScannersModels = [];

    final modelController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateScannersModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final scannersCatalogueDbHelper = ScannersCatalogueDatabaseHelper();
        final modelsData = await scannersCatalogueDbHelper.getScannersModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogScannersModels = modelsData.map((item) => item['model'] as String).toList();
          modelController.text = ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogScannersModels = [];
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
          title: const Text('Add New Scanner'),
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
                        updateScannersModels(dialogSetState);  // Passing the StateSetter to updateScannersModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController.text : null,  // Use the value of modelController for the dropdown value.
                      items: dialogScannersModels.map((String model) {
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
                      items: scannersConditions.map((String condition) {
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

                final newScanners = InventoryScanners(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await ScannersDatabaseHelper.insertScanners(newScanners);
                _loadScanners();

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
        title: const Text("Scanners Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _scanners.length,
        itemBuilder: (context, index) {
          return ScannersListItem(scanners: _scanners[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScannersDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
