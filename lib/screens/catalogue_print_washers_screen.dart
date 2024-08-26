import 'package:flutter/material.dart';

class CataloguePrintWashersScreen extends StatelessWidget {
  const CataloguePrintWashersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Print Washers'),
      ),
      body: const Center(
        child: Text('Content of Print Washers goes here.'),
      ),
    );
  }
}
