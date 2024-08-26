import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_scanners.dart';

class ScannersListItem extends StatelessWidget {
  final InventoryScanners scanners;

  const ScannersListItem({super.key, required this.scanners});

  void _showScannersDetails(BuildContext context, InventoryScanners scanners) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${scanners.brand} ${scanners.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                if (scanners.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(scanners.purchaseDate!)}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (scanners.pricePaid != null)
                  Text('Price Paid: ${scanners.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (scanners.condition != null)
                  Text('Condition: ${scanners.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (scanners.averagePrice != null)
                  Text('Average Price: \$${scanners.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (scanners.comments != null)
                  Text('Comments: ${scanners.comments}',
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
      title: Text("${scanners.brand} ${scanners.model}"),
      onTap: () {
        _showScannersDetails(context, scanners);
      },
    );
  }
}
