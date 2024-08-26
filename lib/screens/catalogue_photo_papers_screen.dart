import 'package:flutter/material.dart';

class CataloguePhotoPapersScreen extends StatelessWidget {
  const CataloguePhotoPapersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Photo Papers'),
      ),
      body: const Center(
        child: Text('Content of Photo papers goes here.'),
      ),
    );
  }
}
