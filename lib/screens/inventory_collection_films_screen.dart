import 'package:flutter/material.dart';
import 'package:analog_photography_db/database_helpers/inventory_collection/films_database_helper.dart';
import 'package:analog_photography_db/models/inventory_films.dart';
import 'package:analog_photography_db/widgets/collection/films_list_item.dart';
import 'package:analog_photography_db/database_helpers/films_catalogue_database_helper.dart';
import 'package:intl/intl.dart';

enum ExpirationOption { unknown, datePicker }

class InventoryCollectionFilmsScreen extends StatefulWidget {
  const InventoryCollectionFilmsScreen({Key? key}) : super(key: key);

  @override
  _InventoryCollectionFilmsScreenState createState() => _InventoryCollectionFilmsScreenState();
}

class _InventoryCollectionFilmsScreenState extends State<InventoryCollectionFilmsScreen> {
  List<InventoryFilms> _films = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _loadFilms() async {
    var films = await FilmsDatabaseHelper.fetchFilms();
    if (mounted) {
      setState(() {
        _films = films;
        _isLoading = false;
      });
    }
  }

  void _showAddFilmsDialog(BuildContext context) async {
    final List<Map<String, dynamic>> brandList = await FilmsCatalogueDatabaseHelper().getFilmsBrands();
    final List<String> brandNames = brandList.map((e) => e['brand'] as String).toList();

    String? dialogSelectedBrand;
    List<String> dialogFilmsNames = [];

    int? selectedYear = DateTime.now().year;
    int? selectedMonth;

    String? isExpiredValue;

    int filmQuantity = 1;

    final brandController = TextEditingController();
    final namesController = TextEditingController();
    final typeController = TextEditingController();
    final sizeTypeController = TextEditingController();
    final isoController = TextEditingController();
    final framesNumberController = TextEditingController(text: '36');
    final expirationDateController = TextEditingController();
    final isExpiredController = TextEditingController();
    final quantityController = TextEditingController();
    final averagePriceController = TextEditingController();
    final commentsController = TextEditingController();

    Future<void> updateFilmsNames(StateSetter setState) async {
      if (dialogSelectedBrand != null && dialogSelectedBrand!.isNotEmpty) {
        final namesData = await FilmsCatalogueDatabaseHelper().getFilmsNamesByBrand(dialogSelectedBrand!);
        setState(() {
          dialogFilmsNames = namesData.map((item) => item['name'] as String).toList();
          namesController.text = ''; // reset the selected film name when changing brands
        });
      } else {
        setState(() {
          dialogFilmsNames = [];
        });
      }
    }


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            Future<void> populateFilmDetails(String brand, String filmName) async {
              final filmDetails = await FilmsCatalogueDatabaseHelper()
                  .getFilmDetailsByBrandAndName(brand, filmName);

              if (filmDetails != null && filmDetails.isNotEmpty) {
                dialogSetState(() {
                  typeController.text = filmDetails['type'] ?? '';       // Corresponds to 'Type of film'
                  sizeTypeController.text = filmDetails['size_type'] ?? ''; // Corresponds to 'Size Type'
                  isoController.text = filmDetails['speed'] ?? '';      // Corresponds to 'ISO'
                  // If there are other fields to populate, add them here.
                });
              }
            }

            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Brand Dropdown
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Select a brand',
                        contentPadding: EdgeInsets.all(0),
                      ),
                      isEmpty: brandController.text.isEmpty,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: brandController.text.isEmpty ? null : brandController.text,
                          items: brandNames.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            dialogSetState(() {
                              brandController.text = newValue!;
                              dialogSelectedBrand = newValue;
                              updateFilmsNames(dialogSetState); // fetch the film names for the selected brand
                            });
                          },
                        ),
                      ),
                    ),

                    // Film Name Dropdown
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Select a film name',
                        contentPadding: EdgeInsets.all(0),
                      ),
                      isEmpty: namesController.text.isEmpty,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: namesController.text.isEmpty ? null : namesController.text,
                          items: dialogFilmsNames.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            dialogSetState(() {
                              namesController.text = newValue!;
                              if (dialogSelectedBrand != null && newValue != null) {
                                populateFilmDetails(dialogSelectedBrand!, newValue);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Type of Film'),
                    ),
                    TextField(
                      controller: sizeTypeController,
                      decoration: const InputDecoration(labelText: 'Size Type'),
                    ),
                    TextField(
                      controller: isoController,
                      decoration: const InputDecoration(labelText: 'ISO'),
                    ),

                    TextField(
                      controller: framesNumberController,
                      decoration: const InputDecoration(labelText: 'Frames Number'),
                      keyboardType: TextInputType.number,
                    ),

                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: selectedYear == null ? 'Expiration Year' : null,
                      ),
                      isEmpty: selectedYear == null,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          onChanged: (int? newValue) {
                            dialogSetState(() {
                              selectedYear = newValue;
                            });
                          },
                          items: List.generate(101, (index) => DateTime.now().year - 50 + index)
                          // List of years from 50 years ago to 50 years in the future
                              .map((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: selectedMonth == null ? 'Expiration Month' : null,
                      ),
                      isEmpty: selectedMonth == null,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          onChanged: (int? newValue) {
                            selectedMonth = newValue;
                            if (selectedYear != null && selectedMonth != null) {
                              DateTime expiration = DateTime(selectedYear!, selectedMonth!);
                              expirationDateController.text = DateFormat('yyyy-MM').format(expiration); // Changed to format as 'YYYY-MM'
                              print("Formatted Expiration Date: ${expirationDateController.text}"); // Debug print
                              if (expiration.isBefore(DateTime.now())) {
                                isExpiredValue = "Film Expired";
                              } else {
                                isExpiredValue = "Not Expired";
                              }
                            }
                            dialogSetState(() {});
                          },
                          items: List.generate(12, (index) => index + 1) // List of months from 1 (January) to 12 (December)
                              .map((int month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(DateFormat('MMMM').format(DateTime(DateTime.now().year, month))), // Display month names
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Is Expired?',
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      child: Text(isExpiredValue ?? ''),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Films quantity",
                          style: TextStyle(fontSize: 16,),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Text(
                              '$filmQuantity',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (filmQuantity > 1) {
                                  dialogSetState(() {
                                    filmQuantity--;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),                               ),
                              child: const Text(
                                "-",
                                style: TextStyle(fontSize: 24), // Increased font size for "-"
                              ),
                            ),
                            const SizedBox(width: 5), // Spacer for a little space between the buttons
                            ElevatedButton(
                              onPressed: () {
                                dialogSetState(() {
                                  filmQuantity++;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.grey, // Text color
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Button size
                              ),
                              child: const Text(
                                "+",
                                style: TextStyle(fontSize: 24), // Increased font size for "+"
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    TextField(
                      controller: averagePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Average Price',
                        suffixText: '€',
                        hintText: 'Enter the price (per piece)',
                      ),
                      onChanged: (value) {
                        // Handle changes to the input, such as updating a variable or model.
                      },
                    ),


                    TextField(
                      controller: commentsController,
                      decoration: const InputDecoration(labelText: 'Comments'),
                    ),
                  ],
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
                    double? parsedPrice = double.tryParse(averagePriceController.text.trim());
                    if (averagePriceController.text.isEmpty) {
                      parsedPrice = null;
                    }
                    if (dialogSelectedBrand == null || dialogSelectedBrand!.isEmpty) {
                      // Handle error
                      return;
                    }
                    print("2. Expiration Date to Save: ${expirationDateController.text}"); // Debug print
                    final newFilms = InventoryFilms(
                      brand: dialogSelectedBrand!,
                      name: namesController.text,
                      type: typeController.text,
                      sizeType: sizeTypeController.text,
                      iso: isoController.text.isEmpty ? null : isoController.text,
                      framesNumber: framesNumberController.text,
                      expirationDate: expirationDateController.text,
                      isExpired: isExpiredValue,
                      quantity: filmQuantity, // Use filmQuantity directly
                      averagePrice: parsedPrice,
                      comments: commentsController.text,
                    );
                    print('3. Inserting film with expiration date: ${newFilms.expirationDate}');
                    await FilmsDatabaseHelper.insertFilms(newFilms);

                    _loadFilms();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Films Collection"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _films.length,
        itemBuilder: (context, index) {
          return FilmsListItem(
            films: _films[index],
            onDelete: () {
              _loadFilms(); // reload the films after one is deleted
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFilmsDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
