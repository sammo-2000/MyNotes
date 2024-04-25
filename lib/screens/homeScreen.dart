import 'package:flutter/material.dart';
import 'package:notes/screens/createEditNoteScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openCreateEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditNoteScreen(
          createPage: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M Y   N O T E S'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCreateEditScreen(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
