import 'package:cloud_firestore/cloud_firestore.dart';
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
}