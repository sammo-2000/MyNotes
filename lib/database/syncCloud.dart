import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/database/firebase.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/models/noteModel.dart';

Future<void> syncBetweenCloud(var notesProvider) async {
  MyFireBase fireBase = MyFireBase();

  List<Note> localNotes = await getLocalData();
  List<Note> cloudNotes = await getCloudData();

  // LOOP CLOUD NOTE
  for (Note cloudNote in cloudNotes) {
    bool isOnLocal = false;
    // LOOP LOCAL NOTE
    for (final localNote in localNotes) {
      // CHECK IF CLOUD NOTE EXIST LOCALLY
      if (cloudNote.id == localNote.id) {
        // NOTE EXISTS LOCALLY
        isOnLocal = true;
        // CHECK IF THERE IS AN UPDATE IN CLOUD
        if (cloudNote.editAt == null && localNote.editAt == null) {
          // NOTE HAVE NO EDIT, EXIST
          break;
        } else {
          // NOTE HAVE AN EDIT
          // IF ONE HAS NO EDIT & OTHER DO UPDATE IT
          if (cloudNote.editAt != null && localNote.editAt == null) {
            // CLOUD NOTE HAD EDIT
            // LOCAL NOTE HAD NO EDIT
            // UPDATE LOCAL NOTE
            MyDatabase.updateNote(cloudNote);
            break;
          } else if (cloudNote.editAt == null && localNote.editAt != null) {
            // CLOUD NOTE HAD NO EDIT
            // LOCAL NOTE HAD EDIT
            // UPDATE CLOUD NOTE
            fireBase.update(localNote);
            break;
          } else {
            // BOTH HAD EDIT, CHECK ONE IS LATEST
            if (cloudNote.editAt!.isAfter(localNote.editAt!)) {
              // CLOUD NOTE HAS LATEST EDIT
              MyDatabase.updateNote(cloudNote);
              break;
            } else {
              // LOCAL HAS LATEST EDIT
              fireBase.update(localNote);
              break;
            }
          }
        }
      }
    }
    if (isOnLocal == false) {
      // NOTE DOES NOT EXIST LOCALLY
      // ADD CLOUD NOTE TO LOCAL
      await MyDatabase.addNote(cloudNote);
    }
  }

  // CHECK WHICH DATABASE IS ON LOCAL ONLY AND UPLOAD TO REMOTE
  // LOOP LOCAL NOTES
  for (final localNote in localNotes) {
    bool isOnCloud = false;
    // LOOP REMOTE NOTES
    for (final cloudNote in cloudNotes) {
      // CHECK IF IT EXISTS ON CLOUD
      if (localNote.id == cloudNote.id) {
        // NOTE EXISTS ON CLOUD
        isOnCloud = true;
        break;
      }
    }
    if (isOnCloud == false) {
      fireBase.add(localNote);
    }
  }
}

Future<List<Note>> getLocalData() async {
  List<Note>? notes = await MyDatabase.getAllNotes();
  if (notes!.isEmpty) return [];
  return notes;
}

Future<List<Note>> getCloudData() async {
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  String email = user.email!;
  if (email.isEmpty) return [];

  QuerySnapshot querySnapshot =
      await notes.where('email', isEqualTo: email).get();
  if (querySnapshot.docs.isNotEmpty) {
    List<Note> listOfNotes = querySnapshot.docs
        .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>? ?? {}))
        .toList();
    return listOfNotes;
  } else {
    return [];
  }
}
