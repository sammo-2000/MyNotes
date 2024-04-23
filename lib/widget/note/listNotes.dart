import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/viewNoteScreen.dart';
import 'package:notes/services/dbConnect.dart';
import 'package:notes/widget/note/cardNote.dart';

class ListNotes extends StatelessWidget {
  const ListNotes({super.key});

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
            return const Text(
              'No notes found, add some by click + bottom right',
              textAlign: TextAlign.center,
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
