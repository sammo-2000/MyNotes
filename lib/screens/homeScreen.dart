import 'package:flutter/material.dart';
import 'package:notes/database/firebase.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/database/syncCloud.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/notesProvider.dart';
import 'package:notes/providers/cloudProvider.dart';
import 'package:notes/screens/createEditNoteScreen.dart';
import 'package:notes/screens/detailNoteScreen.dart';
import 'package:notes/screens/settingsScreen.dart';
import 'package:notes/widgets/button.dart';
import 'package:notes/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note>? noteList;
  late NoteProvider notesProvider;
  late CloudProvider cloudProvider;

  @override
  void initState() {
    super.initState();
    notesProvider = Provider.of<NoteProvider>(context, listen: false);
    cloudProvider = Provider.of<CloudProvider>(context, listen: false);
    setStateInitial(notesProvider, cloudProvider);
  }

  void setStateInitial(var notesProvider, var cloudProvider) {
    MyDatabase.getAllNotes().then((notes) async {
      MyFireBase fireBase = MyFireBase();
      bool isSync = await fireBase.getCloudSettings();
      await cloudProvider.setIsSync(isSync);
      if (isSync == true) {
        await syncBetweenCloud(notesProvider);
      }
      setState(() async {
        if (notes != null && notes.isNotEmpty) {
          noteList = await MyDatabase.getAllNotes();
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
    // ADDED THIS AS CURRENTLY THERE IS BUG IF THERE ARE 0 NOTES, THIS WILL PREVENT IT FROM HAPPENING
    List<Note> notes = noteProvider.getMyNotes.where((note) => note.title != 'Dummy').toList();
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
      body:
          notes.isEmpty ? noNotesFounds(context) : displayNotes(notes, context),
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

void deleteNote(BuildContext context, Note note, bool isSync) async {
  try {
    if (note.filePath != null) {
      deleteImage(note.filePath!);
    }
    await MyDatabase.deleteNote(note);
    if (isSync) {
      MyFireBase firebase = MyFireBase();
      await firebase.delete(note);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  } catch (e) {
    CustomDialog.show(
      context,
      'Error Deleting Note',
      'Sorry, note was not deleted please try again',
    );
    debugPrint('ERROR DELETING NOTE');
    debugPrint(e.toString());
  }
}

Future<void> deleteImage(String imagePath) async {
  if (imagePath.isNotEmpty) {
    File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
  }
}

Widget displayNotes(List<Note> notes, BuildContext context) {
  final cloudProvider = Provider.of<CloudProvider>(context);
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
              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        deleteNote(context, note, cloudProvider.isSync);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailNoteScreen(note: note),
                      ),
                    );
                  },
                  child: noteCard(note),
                ),
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
