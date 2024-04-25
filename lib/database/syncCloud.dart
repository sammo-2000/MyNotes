import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/database/firebase.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/cloudProvider.dart';
import 'package:provider/provider.dart';

Future<void> syncBetweenCloud(BuildContext context) async {
  final cloudProvider = Provider.of<CloudProvider>(context, listen: false);
  if (cloudProvider.isSync == false) return;

  MyFireBase fireBase = MyFireBase();

  List<Note> localNotes = await getLocalData();
  List<Note> cloudNotes = await getCloudData();

  for (Note localNote in localNotes) {
    bool found = false;
    for (Note cloudNote in cloudNotes) {
      if (localNote.id == cloudNote.id) {
        found = true;
        if (localNote.editAt!.isAfter(cloudNote.editAt!)) {
          // Update cloudNote with localNote
          await fireBase.update(localNote);
        } else if (localNote.editAt!.isBefore(cloudNote.editAt!)) {
          // Update localNote with cloudNote
          await MyDatabase.updateNote(cloudNote);
        }
        break;
      }
    }
    if (!found) {
      // Add localNote to cloud
      for (Note localNote in localNotes) {
        await fireBase.add(localNote);
      }
    }
  }

  for (Note cloudNote in cloudNotes) {
    bool found = false;
    for (Note localNote in localNotes) {
      if (cloudNote.id == localNote.id) {
        found = true;
        break;
      }
    }
    if (!found) {
      // Add cloudNote to local
      for (Note cloudNote in cloudNotes) {
        await MyDatabase.addNote(cloudNote);
      }
    }
  }
}

Future<void> deleteFromCloud() async {}

Future<List<Note>> getLocalData() async {
  List<Note>? notes = await MyDatabase.getAllNotes();
  if (notes!.isEmpty) return [];
  return notes;
}

Future<List<Note>> getCloudData() async {
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  User? user = FirebaseAuth.instance.currentUser;
  String? email = user?.email;
  if (email == null || email.isEmpty) return [];
  DocumentSnapshot<Map<String, dynamic>> docSnapshot =
      await notes.doc(email).get() as DocumentSnapshot<Map<String, dynamic>>;
  if (docSnapshot.exists) {
    List<Note> listOfNotes = (docSnapshot.data() as List<dynamic>)
        .map((note) => Note.fromMap(note))
        .toList();
    return listOfNotes;
  } else {
    return [];
  }
}

// CollectionReference cloud = FirebaseFirestore.instance.collection('cloud');
// User? user = FirebaseAuth.instance.currentUser;
// String? email = user?.email;
//
// if (email == null || email.isEmpty) return false;
//
// DocumentSnapshot<Map<String, dynamic>> docSnapshot = await cloud.doc(email).get() as DocumentSnapshot<Map<String, dynamic>>;
//
// if (docSnapshot.exists) {
// return docSnapshot.data()?['cloud'] ?? false;
// } else {
// return false;
// }
// }
