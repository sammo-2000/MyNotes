import 'package:flutter/material.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E D I T   N O T E S')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(),
      ),
    );
  }
}
