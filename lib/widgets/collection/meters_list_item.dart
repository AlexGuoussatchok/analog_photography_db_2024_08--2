import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_meters.dart';

class MetersListItem extends StatelessWidget {
  final InventoryMeters meters;

  const MetersListItem({super.key, required this.meters});

  void _showMetersDetails(BuildContext context, InventoryMeters meters) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${meters.brand} ${meters.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (meters.serialNumber != null)
                  Text('Serial Number: ${meters.serialNumber}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (meters.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(meters.purchaseDate!)}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (meters.pricePaid != null)
                  Text('Price Paid: ${meters.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (meters.condition != null)
                  Text('Condition: ${meters.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (meters.averagePrice != null)
                  Text('Average Price: \$${meters.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (meters.comments != null)
                  Text('Comments: ${meters.comments}',
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
      title: Text("${meters.brand} ${meters.model}"),
      subtitle: Text('Serial: ${meters.serialNumber}'),
      onTap: () {
        _showMetersDetails(context, meters);
      },
    );
  }
}
