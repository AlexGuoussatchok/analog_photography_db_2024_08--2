import 'package:flutter/material.dart';
import 'package:analog_photography_db/models/inventory_chemicals.dart';

class ChemicalsListItem extends StatelessWidget {
  final InventoryChemicals chemicals;

  const ChemicalsListItem({super.key, required this.chemicals});

  void _showChemicalsDetails(BuildContext context, InventoryChemicals chemicals) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(chemicals.chemical.replaceAll('_', ' ')),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (chemicals.pricePaid != null)
                  Text('Price Paid: ${chemicals.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (chemicals.condition != null)
                  Text('Condition: ${chemicals.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (chemicals.averagePrice != null)
                  Text('Average Price: \$${chemicals.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (chemicals.comments != null)
                  Text('Comments: ${chemicals.comments}',
                      style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(chemicals.chemical.replaceAll('_', ' ')),
      onTap: () {
        _showChemicalsDetails(context, chemicals);
      },
    );
  }
}
