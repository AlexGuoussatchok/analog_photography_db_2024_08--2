import 'package:flutter/material.dart';

class CatalogueEnlargersScreen extends StatelessWidget {
  const CatalogueEnlargersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Enlargers'),
      ),
      body: const Center(
        child: Text('Content of Enlargers goes here.'),
      ),
    );
  }
}
