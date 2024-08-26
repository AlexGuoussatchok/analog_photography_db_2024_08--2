import 'package:flutter/material.dart';

class HistoryNotesScreen extends StatelessWidget {
  const HistoryNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Notes'),
      ),
      body: const Center(
        child: Text('Content for History Notes'),
      ),
    );
  }
}
