import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_dryers.dart';

class DryersListItem extends StatelessWidget {
  final InventoryDryers dryers;

  const DryersListItem({super.key, required this.dryers});

  void _showDryersDetails(BuildContext context, InventoryDryers dryers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${dryers.brand} ${dryers.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                if (dryers.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(dryers.purchaseDate!)}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (dryers.pricePaid != null)
                  Text('Price Paid: ${dryers.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (dryers.condition != null)
                  Text('Condition: ${dryers.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (dryers.averagePrice != null)
                  Text('Average Price: \$${dryers.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (dryers.comments != null)
                  Text('Comments: ${dryers.comments}',
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
      title: Text("${dryers.brand} ${dryers.model}"),
      onTap: () {
        _showDryersDetails(context, dryers);
      },
    );
  }
}
