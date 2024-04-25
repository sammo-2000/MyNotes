import 'package:flutter/material.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/notesProvider.dart';
import 'package:notes/screens/createEditNoteScreen.dart';
import 'package:notes/screens/detailNoteScreen.dart';
import 'package:notes/screens/settingsScreen.dart';
import 'package:notes/widgets/button.dart';
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
    // TODO
    // IF USER HAS SYNC ON, GET ALL NOTES FROM DB
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
      body: notes.isEmpty ? noNotesFounds(context) : displayNotes(notes, context),
    );
  }
}

Widget noNotesFounds(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        settingsBTN(context),
        const Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'N O   N O T E S   F O U N D',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget displayNotes(List<Note> notes, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        settingsBTN(context),
        Expanded(
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              Note note = notes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailNoteScreen(note: note),
                    ),
                  );
                },
                child: noteCard(note),
              );
            },
          ),
        )
      ],
    ),
  );
}

Widget noteCard(Note note) {
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
                      .format(
                          note.editAt == null ? note.createAt! : note.editAt!)
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

Widget settingsBTN(BuildContext context) {
  return CustomButton(
    label: 'Settings',
    icon: Icons.settings,
    onClick: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingScreen(),
        ),
      );
    },
    color: Colors.black,
  );
}
