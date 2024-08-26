import 'package:flutter/material.dart';

class CatalogueColorAnalyzersScreen extends StatelessWidget {
  const CatalogueColorAnalyzersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Color Analyzers'),
      ),
      body: const Center(
        child: Text('Content of Color Analyzers goes here.'),
      ),
    );
  }
}
