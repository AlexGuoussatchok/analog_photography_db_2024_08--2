import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:analog_photography_db/models/inventory_camera.dart';

class CameraListItem extends StatelessWidget {
  final InventoryCamera camera;

  const CameraListItem({super.key, required this.camera});

  void _showCameraDetails(BuildContext context, InventoryCamera camera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${camera.brand} ${camera.model}"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (camera.serialNumber != null)
                  Text('Serial Number: ${camera.serialNumber}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.purchaseDate != null)
                  Text('Purchase Date: ${DateFormat('yyyy-MM-dd').format(camera.purchaseDate!)}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.pricePaid != null)
                  Text('Price Paid: ${camera.pricePaid}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.condition != null)
                  Text('Condition: ${camera.condition}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.filmLoadDate != null)
                  Text('Film Load Date: ${DateFormat('yyyy-MM-dd').format(camera.filmLoadDate!)}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.filmLoaded != null)
                  Text('Film Loaded: ${camera.filmLoaded}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.averagePrice != null)
                  Text('Average Price: \$${camera.averagePrice}',
                  style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 10),
                if (camera.comments != null)
                  Text('Comments: ${camera.comments}',
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
      title: Text("${camera.brand} ${camera.model}"),
      subtitle: Text('Serial: ${camera.serialNumber}'),
      onTap: () {
        _showCameraDetails(context, camera);
      },
    );
  }
}
