import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/models/noteModel.dart';

class MyFireBase {
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  Future<void> add(Note note) async {
    return notes
        .doc(note!.id.toString())
        .set(note.toMap())
        .catchError((e) => print(e));
  }

  Future<void> update(Note note) async {
    String id = note.id.toString();
    return notes
        .doc(id)
        .update(note.toMap())
        .catchError((error) => print("Failed to update note: $error"));
  }

  Future<void> delete(Note note) async {
    String id = note.id.toString();
    return notes
        .doc(id)
        .delete()
        .catchError((error) => print("Failed to delete note: $error"));
  }

  Future<void> setCloudSettings(bool cloudValue) async {
    CollectionReference cloud = FirebaseFirestore.instance.collection('cloud');
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;

    if (email == null || email.isEmpty) return;

    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await cloud.doc(email).get() as DocumentSnapshot<Map<String, dynamic>>;

    if (docSnapshot.exists) {
      await cloud.doc(email).update({'cloud': cloudValue});
    } else {
      await cloud.doc(email).set({'cloud': cloudValue});
    }
  }

  Future<bool> getCloudSettings() async {
    CollectionReference cloud = FirebaseFirestore.instance.collection('cloud');
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;

    if (email == null || email.isEmpty) return false;

    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await cloud.doc(email).get() as DocumentSnapshot<Map<String, dynamic>>;

    if (docSnapshot.exists) {
      return docSnapshot.data()?['cloud'] ?? false;
    } else {
      return false;
    }
  }
}
