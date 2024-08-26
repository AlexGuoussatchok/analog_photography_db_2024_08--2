import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/processors_database_helper.dart';
import 'package:analog_photography_db/models/inventory_processors.dart';
import 'package:analog_photography_db/widgets/collection/processors_list_item.dart';
import 'package:analog_photography_db/database_helpers/processors_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/processors_condition_list.dart';


class InventoryCollectionProcessorsScreen extends StatefulWidget {
  const InventoryCollectionProcessorsScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionProcessorsScreenState createState() => _InventoryCollectionProcessorsScreenState();
}

class _InventoryCollectionProcessorsScreenState extends State<InventoryCollectionProcessorsScreen> {
  List<InventoryProcessors> _processors = [];
  final List<String> _processorsModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogProcessorsModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadProcessors();
  }

  _loadProcessors() async {
    var processors = await ProcessorsDatabaseHelper.fetchProcessors();

    if (mounted) {
      setState(() {
        _processors = processors;
        _isLoading = false;
      });
    }
  }


  Future<void> _updateProcessorsModels() async {
    if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
      final modelsData = await ProcessorsCatalogueDatabaseHelper().getProcessorsModelsByBrand(_dialogSelectedBrand!);

      setState(() {
        _dialogProcessorsModels = modelsData.map((item) => item['model'] as String).toList();
      });
    } else {
      setState(() {
        _dialogProcessorsModels = [];
      });
    }
  }

  void _showAddProcessorsDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await ProcessorsCatalogueDatabaseHelper().getProcessorsBrands();
    final List<String> brandNames = brandList.map((e) => e['brand'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogProcessorsModels = [];

    final modelController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateProcessorsModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final processorsCatalogueDbHelper = ProcessorsCatalogueDatabaseHelper();
        final modelsData = await processorsCatalogueDbHelper.getProcessorsModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogProcessorsModels = modelsData.map((item) => item['model'] as String).toList();
          modelController.text = ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogProcessorsModels = [];
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
          title: const Text('Add New Film Processor'),
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
                        updateProcessorsModels(dialogSetState);  // Passing the StateSetter to updateProcessorsModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController.text : null,  // Use the value of modelController for the dropdown value.
                      items: dialogProcessorsModels.map((String model) {
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
                      items: processorsConditions.map((String condition) {
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

                final newProcessors = InventoryProcessors(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await ProcessorsDatabaseHelper.insertProcessors(newProcessors);
                _loadProcessors();

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
        title: const Text("Film Processors Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _processors.length,
        itemBuilder: (context, index) {
          return ProcessorsListItem(processors: _processors[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProcessorsDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
