import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/editNoteScreen.dart';

class ViewNoteScreen extends StatelessWidget {
  final Note myNote;
  const ViewNoteScreen({super.key, required this.myNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('V I E W   N O T E S')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(myNote.title),
          ],
        ),
      ),
    );
  }
}
