import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/editNoteScreen.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:notes/screens/listNoteScreen.dart';
import 'package:notes/services/dbConnect.dart';
import 'package:notes/widget/button.dart';
import 'package:notes/widget/dialog.dart';

class ViewNoteScreen extends StatelessWidget {
  // Variables
  final Note myNote;
  const ViewNoteScreen({super.key, required this.myNote});

  // Functions
  Future<dynamic> deleteNoteConfirm(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Note',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: const Text(
            'Are you sure you would like to delete this note? Once delete it cannot be restored',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Colors.blue,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteNote(context);
              },
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteNote(BuildContext context) async {
    try {
      if (myNote.filePath != null) {
        deleteImage(myNote.filePath!);
      }
      await MyDatabase.deleteNote(myNote);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ListNoteScreen(),
        ),
      );
    } catch (e) {
      CustomDialog.show(
        context,
        'Error Deleting Note',
        'Sorry, note was not deleted please try again',
      );
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

  // Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('V I E W   N O T E S')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditNoteScreen(note: myNote)),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              label: 'Delete Note',
              icon: Icons.delete_forever,
              onClick: () => deleteNoteConfirm(context),
              color: Colors.red,
            ),
            showTitle(myNote.title),
            Text(myNote.note),
            const SizedBox(height: 10.0),
            showDateTime(
                myNote.reminderDateTime, Icons.timer, 'No reminder set'),
            showDateTime(myNote.createAt, Icons.create, ''),
            showDateTime(myNote.editAt, Icons.create, 'No edits'),
            showImage(myNote.filePath),
          ],
        ),
      ),
    );
  }
}

Widget showTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
  );
}

Widget showDateTime(DateTime? time, IconData icon, String noTimeText) {
  return Row(
    children: [
      Icon(icon, color: Colors.grey),
      const SizedBox(width: 5.0),
      time == null
          ? Text(
              noTimeText,
              style: const TextStyle(
                color: Colors.grey,
              ),
            )
          : Text(
              DateFormat('MMMM dd, yyyy - hh:mm a').format(time).toString(),
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
    ],
  );
}

Widget showImage(String? filePath) {
  if (filePath == null) {
    return const SizedBox();
  } else {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.file(
                File(filePath!),
                height: 300,
              ),
            ),
          ],
        );
  }
}
