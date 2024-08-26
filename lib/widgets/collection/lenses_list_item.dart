import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_lenses.dart';

class LensesListItem extends StatelessWidget {
  final InventoryLenses lenses;

  const LensesListItem({super.key, required this.lenses});

  void _showLensesDetails(BuildContext context, InventoryLenses lenses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${lenses.brand.replaceAll('_', ' ')} ${lenses.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (lenses.serialNumber != null)
                  Text('Serial Number: ${lenses.serialNumber}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (lenses.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(lenses.purchaseDate!)}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (lenses.pricePaid != null)
                  Text('Price Paid: ${lenses.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (lenses.condition != null)
                  Text('Condition: ${lenses.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (lenses.averagePrice != null)
                  Text('Average Price: \$${lenses.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (lenses.comments != null)
                  Text('Comments: ${lenses.comments}',
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
      title: Text("${lenses.brand.replaceAll('_', ' ')} ${lenses.model}"),
      subtitle: Text('Serial: ${lenses.serialNumber}'),
      onTap: () {
        _showLensesDetails(context, lenses);
      },
    );
  }
}
