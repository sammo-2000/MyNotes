import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/addNoteScreen.dart';
import 'package:notes/services/dbConnect.dart';
import 'package:notes/widget/note/listNotes.dart';

class ListNoteScreen extends StatelessWidget {
  const ListNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M Y   N O T E S')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: ListNotes(),
      ),
    );
  }
}
