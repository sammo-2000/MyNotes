import 'package:flutter/material.dart';
import 'package:notes/database/firebase.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/cloudProvider.dart';
import 'package:notes/screens/createEditNoteScreen.dart';
import 'package:notes/screens/homeScreen.dart';
import 'package:notes/widgets/button.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:notes/widgets/dialog.dart';
import 'package:provider/provider.dart';

class DetailNoteScreen extends StatelessWidget {
  final Note note;
  const DetailNoteScreen({
    super.key,
    required this.note,
  });

  void openCreateEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditNoteScreen(
          createPage: false,
          note: note,
        ),
      ),
    );
  }

  Future<dynamic> deleteNoteConfirm(BuildContext context, bool isSync) {
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
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteNote(context, isSync);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteNote(BuildContext context, bool isSync) async {
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

  @override
  Widget build(BuildContext context) {
    final cloudProvider = Provider.of<CloudProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('V I E W   N O T E')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCreateEditScreen(context);
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
              onClick: () => deleteNoteConfirm(context, cloudProvider.isSync),
              color: Colors.red,
            ),
            showTitle(note.title),
            Text(note.note),
            const SizedBox(height: 10.0),
            showDateTime(
                note.reminderDateTime, Icons.timer, 'No reminder set'),
            showDateTime(note.createAt, Icons.create, ''),
            showDateTime(note.editAt, Icons.create, 'No edits'),
            showImage(note.filePath),
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

