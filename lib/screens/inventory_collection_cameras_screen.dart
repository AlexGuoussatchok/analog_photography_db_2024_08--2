import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/cameras_database_helper.dart';
import 'package:analog_photography_db/models/inventory_camera.dart';
import 'package:analog_photography_db/widgets/collection/cameras_list_item.dart';
import 'package:analog_photography_db/database_helpers/cameras_catalogue_database_helper.dart';
import 'package:analog_photography_db/lists/cameras_condition_list.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';




class InventoryCollectionCamerasScreen extends StatefulWidget {
  const InventoryCollectionCamerasScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionCamerasScreenState createState() => _InventoryCollectionCamerasScreenState();
}

class _InventoryCollectionCamerasScreenState extends State<InventoryCollectionCamerasScreen> {
  List<InventoryCamera> _cameras = [];
  final List<String> _cameraModels = [];
  String? _dialogSelectedBrand;
  List<String> _dialogCameraModels = [];
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();
  late TextEditingController purchaseDateController;
  late TextEditingController filmLoadDateController;


  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  _loadCameras() async {
    var cameras = await CamerasDatabaseHelper.fetchCameras();

    if (mounted) {
      setState(() {
        _cameras = cameras;
        _isLoading = false;
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
        purchaseDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate); // Ensure correct format
      });
    }
  }

  Future<void> selectFilmLoadedDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        filmLoadDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Ensure correct format
      });
    }
  }

  void _confirmDeleteCamera(int? cameraId, int index) {
    if (cameraId == null) return;

    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this camera?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  await CamerasDatabaseHelper.deleteCamera(cameraId);
                  setState(() {
                    _cameras.removeAt(index);
                  });
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  void _showCameraDetails(InventoryCamera camera) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Camera Details'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Brand: ${camera.brand}'),
                  Text('Model: ${camera.model}'),
                  Text('Serial Number: ${camera.serialNumber ?? 'N/A'}'),
                  Text('Purchase date: ${camera.purchaseDate != null ? DateFormat('yyyy-MM-dd').format(camera.purchaseDate!) : 'N/A'}'),
                  Text('Price paid: ${camera.pricePaid}'),
                  Text('Condition: ${camera.condition}'),
                  Text('Average price (Euro): ${camera.averagePrice}'),
                  Text('Comments: ${camera.comments}'),
                  // Add other camera details here
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
    );
  }

  void _sortCamerasByBrand() {
    setState(() {
      _cameras.sort((a, b) => a.brand.compareTo(b.brand));
    });
  }

  void _saveAsPdf() async {
    final pdf = pw.Document();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateFormat titleDateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final String titleDate = titleDateFormat.format(DateTime.now());

    final landscapeFormat = PdfPageFormat.a4.landscape;

    pdf.addPage(
        pw.MultiPage(
          pageFormat: landscapeFormat,
          header: (pw.Context context) {
            if (context.pageNumber == 1) {
              return pw.Column(
                  children: [
                    pw.Text('Cameras Collection - $titleDate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10), // Add some spacing after the title
                  ]
              );
            }
            return pw.Container();
          },
          build: (pw.Context context) => [
          pw.Table.fromTextArray(
          context: context,
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
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
          },
          headerStyle: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(
            color: PdfColors.black,
          ),
          data: <List<String>>[
            <String>[
              'Brand',
              'Model',
              'Serial Number',
              'Purchase Date',
              'Price Paid',
              'Condition',
              'Average Price',
              'Comments'
            ],
            ..._cameras.map((camera) => [
              camera.brand,
              camera.model,
              camera.serialNumber ?? 'N/A',
              camera.purchaseDate != null ? dateFormat.format(camera.purchaseDate!) : 'N/A',
              camera.pricePaid != null ? camera.pricePaid.toString() : 'N/A',
              camera.condition ?? 'N/A',
              camera.averagePrice != null ? camera.averagePrice.toString() : 'N/A',
              camera.comments ?? 'N/A',
            ]).toList(),
          ],
          ),
            // ... other content for the page ...
          ],
        ),
    );

    // Saving and printing the PDF file path...
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final String path = '$selectedDirectory/camera_collection.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      print('Saved PDF at: $path');
    } else {
      // User canceled the picker
      print('No directory selected');
    }
  }

  void _showCameraOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.of(context).pop(); // Close the options menu
                _showEditCameraDialog(context, index);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.of(context).pop(); // Close the options menu
                _confirmDeleteCamera(_cameras[index].id, index);
              },
            ),
            // Add more options as needed
          ],
        );
      },
    );
  }

  void _showEditCameraDialog(BuildContext context, int index) {
    // Retrieve the camera data for editing
    InventoryCamera cameraToEdit = _cameras[index];

    // Create text controllers for editing fields
    TextEditingController serialNumberController = TextEditingController(text: cameraToEdit.serialNumber);
    TextEditingController purchaseDateController = TextEditingController(text: cameraToEdit.purchaseDate != null ? cameraToEdit.purchaseDate.toString() : "");
    TextEditingController pricePaidController = TextEditingController(text: cameraToEdit.pricePaid != null ? cameraToEdit.pricePaid.toString() : "");
    TextEditingController conditionController = TextEditingController(text: cameraToEdit.condition);
    TextEditingController filmLoadDateController = TextEditingController(text: cameraToEdit.filmLoadDate != null ? cameraToEdit.filmLoadDate.toString() : "");
    TextEditingController filmLoadedController = TextEditingController(text: cameraToEdit.filmLoaded);
    TextEditingController averagePriceController = TextEditingController(text: cameraToEdit.averagePrice != null ? cameraToEdit.averagePrice.toString() : "");
    TextEditingController commentsController = TextEditingController(text: cameraToEdit.comments);

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
          purchaseDateController.text =
          "${selectedDate.toLocal()}".split(' ')[0]; // formats it to yyyy-mm-dd
        });
      }
    }

    Future<void> selectFilmLoadedDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        setState(() {
          filmLoadDateController.text = '${pickedDate.toLocal()}'.split(' ')[0];
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${cameraToEdit.brand} ${cameraToEdit.model}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add input fields for editing camera properties

                TextField(
                  controller: serialNumberController,
                  decoration: InputDecoration(labelText: 'Serial Number'),
                ),

                TextField(
                  controller: purchaseDateController,
                  readOnly: true,
                  // Makes the text field read-only, so it's not editable
                  decoration: const InputDecoration(
                      labelText: 'Purchase Date'),
                  onTap: () {
                    selectDate(context);
                  },
                ),

                TextField(
                  controller: pricePaidController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true), // Ensures numeric keyboard layout
                  decoration: const InputDecoration(
                    labelText: 'Price Paid',
                    suffixText: '€', // Display Euro sign at the end
                  ),
                ),

                DropdownButtonFormField<String>(
                  value: conditionController.text.isEmpty
                      ? null
                      : conditionController.text,
                  items: cameraConditions.map((String condition) {
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
                  controller: filmLoadDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Film Load Date'),
                  onTap: () {
                    selectFilmLoadedDate(context);
                  },
                ),

                TextField(
                  controller: filmLoadedController,
                  decoration: InputDecoration(labelText: 'Film Loaded'),
                ),


                TextField(
                  controller: averagePriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true), // Ensures numeric keyboard layout
                  decoration: const InputDecoration(
                    labelText: 'Average Price',
                    suffixText: '€', // Display Euro sign at the end
                  ),
                ),

                TextField(
                  controller: commentsController,
                  decoration: InputDecoration(labelText: 'Comments'),
                ),

                // Add a "Save" button to save changes
                ElevatedButton(
                  onPressed: () async {
                    // Update the camera record with the edited data
                    setState(() {
                      cameraToEdit.serialNumber = serialNumberController.text;
                      cameraToEdit.purchaseDate = DateTime.tryParse(purchaseDateController.text);
                      cameraToEdit.pricePaid = double.tryParse(pricePaidController.text);
                      cameraToEdit.condition = conditionController.text;
                      cameraToEdit.filmLoadDate = DateTime.tryParse(filmLoadDateController.text);
                      cameraToEdit.filmLoaded = filmLoadedController.text;
                      cameraToEdit.averagePrice = double.tryParse(averagePriceController.text);
                      cameraToEdit.comments = commentsController.text;
                      // Update other properties as needed...
                    });
                    await CamerasDatabaseHelper.updateCamera(cameraToEdit);
                    _loadCameras();

                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  // Future<void> _updateCameraModels() async {
  //   if (_dialogSelectedBrand != null && _dialogSelectedBrand!.isNotEmpty) {
  //     final modelsData = await CamerasCatalogueDatabaseHelper()
  //         .getCameraModelsByBrand(_dialogSelectedBrand!);
  //
  //     setState(() {
  //       _dialogCameraModels =
  //           modelsData.map((item) => item['model'] as String).toList();
  //     });
  //   } else {
  //     setState(() {
  //       _dialogCameraModels = [];
  //     });
  //   }
  // }


  void _showAddCameraDialog(BuildContext context) async {
    final List<
        Map<String, dynamic>> brandList = await CamerasCatalogueDatabaseHelper()
        .getCameraBrands();
    final List<String> brandNames = brandList.map((e) => e['brand'] as String)
        .toList();

    String? dialogSelectedBrand;
    List<String> dialogCameraModels = [];

    final modelController = TextEditingController();
    final serialNumberController = TextEditingController();
    final purchaseDateController = TextEditingController();
    final pricePaidController = TextEditingController();
    final conditionController = TextEditingController();
    final filmLoadDateController = TextEditingController();
    final filmLoadedController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateCameraModels(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final camerasCatalogueDbHelper = CamerasCatalogueDatabaseHelper();
        final modelsData = await camerasCatalogueDbHelper
            .getCameraModelsByBrand(dialogSelectedBrand!.toLowerCase());

        setState(() {
          dialogCameraModels =
              modelsData.map((item) => item['model'] as String).toList();
          modelController.text =
          ''; // or set it to null or an initial value if required
        });
      } else {
        setState(() {
          dialogCameraModels = [];
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
          purchaseDateController.text =
          "${selectedDate.toLocal()}".split(' ')[0]; // formats it to yyyy-mm-dd
        });
      }
    }

    Future<void> selectFilmLoadedDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        setState(() {
          filmLoadDateController.text = '${pickedDate.toLocal()}'.split(' ')[0];
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Camera'),
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
                          modelController.text =
                          ''; // Clear the model when brand changes.
                        });
                        updateCameraModels(
                            dialogSetState); // Passing the StateSetter to updateCameraModels function
                      },
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: modelController.text.isNotEmpty ? modelController
                          .text : null,
                      // Use the value of modelController for the dropdown value.
                      items: dialogCameraModels.map((String model) {
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
                      decoration: const InputDecoration(
                          labelText: 'Serial Number'),
                    ),

                    TextField(
                      controller: purchaseDateController,
                      readOnly: true,
                      // Makes the text field read-only, so it's not editable
                      decoration: const InputDecoration(
                          labelText: 'Purchase Date'),
                      onTap: () {
                        selectDate(context);
                      },
                    ),

                    TextField(
                      controller: pricePaidController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true), // Ensures numeric keyboard layout
                      decoration: const InputDecoration(
                        labelText: 'Price Paid',
                        suffixText: '€', // Display Euro sign at the end
                      ),
                    ),


                    DropdownButtonFormField<String>(
                      value: conditionController.text.isEmpty
                          ? null
                          : conditionController.text,
                      items: cameraConditions.map((String condition) {
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
                      controller: filmLoadDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: 'Film Load Date'),
                      onTap: () {
                        selectFilmLoadedDate(context);
                      },
                    ),

                    TextField(
                      controller: filmLoadedController,
                      decoration: const InputDecoration(
                          labelText: 'Film Loaded'),
                    ),

                    TextField(
                      controller: averagePriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true), // Ensures numeric keyboard layout
                      decoration: const InputDecoration(
                        labelText: 'Average Price',
                        suffixText: '€', // Display Euro sign at the end
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
                double? averagePrice = double.tryParse(
                    averagePriceController.text);

                final newCamera = InventoryCamera(
                  brand: dialogSelectedBrand!,
                  model: modelController.text,
                  serialNumber: serialNumberController.text,
                  purchaseDate: DateTime.tryParse(purchaseDateController.text),
                  pricePaid: pricePaid,
                  condition: conditionController.text,
                  filmLoadDate: DateTime.tryParse(filmLoadDateController.text),
                  filmLoaded: filmLoadedController.text,
                  averagePrice: averagePrice,
                  comments: commentsController.text,
                );

                await CamerasDatabaseHelper.insertCamera(newCamera);
                _loadCameras();

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
        title: const Text("Camera Collection"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String choice) {
              switch (choice) {
                case 'Add Camera': // New case for adding a camera
                  _showAddCameraDialog(context);
                  break;
                case 'Save as PDF':
                  _saveAsPdf();
                  break;
                case 'Sort by Brand':
                  _sortCamerasByBrand();
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Add Camera', 'Save as PDF', 'Sort by Brand'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _cameras.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${_cameras[index].brand} ${_cameras[index].model}"),
            subtitle: Text("Serial Number: ${_cameras[index].serialNumber ?? 'N/A'}"),
            trailing: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showCameraOptionsMenu(context, index),
            ),
            onTap: () => _showCameraDetails(_cameras[index]),
          );
        },
      ),
    );
  }
}