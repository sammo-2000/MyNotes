import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/models/note.dart';

class MyFireBase {
  CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  Future<void> add(Note note) async {
    return notes
        .add(note.toMap())
        .then((value) => print(value))
        .catchError((e) => print(e));
  }

  Future<void> update(Note note) async {}

  Future<void> delete(Note note) async {}
}