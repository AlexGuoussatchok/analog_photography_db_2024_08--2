import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_flashes.dart';

class FlashesListItem extends StatelessWidget {
  final InventoryFlashes flashes;

  const FlashesListItem({super.key, required this.flashes});

  void _showFlashesDetails(BuildContext context, InventoryFlashes flashes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${flashes.brand} ${flashes.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (flashes.serialNumber != null)
                  Text('Serial Number: ${flashes.serialNumber}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (flashes.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(flashes.purchaseDate!)}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (flashes.pricePaid != null)
                  Text('Price Paid: ${flashes.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (flashes.condition != null)
                  Text('Condition: ${flashes.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (flashes.averagePrice != null)
                  Text('Average Price: \$${flashes.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (flashes.comments != null)
                  Text('Comments: ${flashes.comments}',
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
      title: Text("${flashes.brand} ${flashes.model}"),
      subtitle: Text('Serial: ${flashes.serialNumber}'),
      onTap: () {
        _showFlashesDetails(context, flashes);
      },
    );
  }
}
