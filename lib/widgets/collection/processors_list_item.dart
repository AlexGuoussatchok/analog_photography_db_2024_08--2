import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_processors.dart';

class ProcessorsListItem extends StatelessWidget {
  final InventoryProcessors processors;

  const ProcessorsListItem({super.key, required this.processors});

  void _showProcessorsDetails(BuildContext context, InventoryProcessors processors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${processors.brand} ${processors.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (processors.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(processors.purchaseDate!)}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (processors.pricePaid != null)
                  Text('Price Paid: ${processors.pricePaid}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (processors.condition != null)
                  Text('Condition: ${processors.condition}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (processors.averagePrice != null)
                  Text('Average Price: \$${processors.averagePrice}',
                      style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (processors.comments != null)
                  Text('Comments: ${processors.comments}',
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
      title: Text("${processors.brand} ${processors.model}"),
      onTap: () {
        _showProcessorsDetails(context, processors);
      },
    );
  }
}
