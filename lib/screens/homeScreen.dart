import 'package:flutter/material.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/notesProvider.dart';
import 'package:notes/screens/createEditNoteScreen.dart';
import 'package:notes/screens/detailNoteScreen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note>? noteList;
  late NoteProvider notesProvider;

  @override
  void initState() {
    super.initState();
    notesProvider = Provider.of<NoteProvider>(context, listen: false);
    setStateInitial();
  }

  void setStateInitial() {
    MyDatabase.getAllNotes().then((notes) {
      setState(() {
        if (notes != null && notes.isNotEmpty) {
          noteList = notes;
          notesProvider.setNotes(noteList!);
        } else {
          noteList = [];
          notesProvider.setNotes(noteList!);
        }
      });
    });
  }

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
    final noteProvider = Provider.of<NoteProvider>(context);
    List<Note> notes = noteProvider.getMyNotes;
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
      body: notes.isEmpty ? noNotesFounds() : displayNotes(notes),
    );
  }
}

Widget noNotesFounds() {
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

Widget displayNotes(List<Note> notes) {
  return ListView.builder(
    itemCount: notes.length,
    itemBuilder: (context, index) {
      Note note = notes[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditNoteScreen(createPage: false, note: note),
            ),
          );
        },
        child: NoteCard(note),
      );
    },
  );
}

Widget NoteCard(Note note) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 3.0),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.title),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat('MMMM dd, yyyy - hh:mm a')
                  // Show edit date, if the note never been edited show create date
                      .format(note.editAt == null ? note.createAt! : note.editAt!)
                      .toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
