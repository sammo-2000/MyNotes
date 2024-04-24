import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/viewNoteScreen.dart';
import 'package:notes/services/dbConnect.dart';
import 'package:notes/widget/note/cardNote.dart';

class ListNotes extends StatefulWidget {
  const ListNotes({super.key});

  @override
  State<ListNotes> createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>?>(
      future: MyDatabase.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Note>? noteList = snapshot.data;
          if (noteList == null || noteList.isEmpty) {
            return const Center(
              child: Text(
                'N O   N O T E S   F O U N D',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: noteList.length,
            itemBuilder: (context, index) {
              Note note = noteList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewNoteScreen(myNote: note),
                    ),
                  );
                },
                child: NoteCard(note: note),
              );
            },
          );
        }
      },
    );
  }
}
