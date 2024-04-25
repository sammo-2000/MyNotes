import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/viewNoteScreen.dart';
import 'package:notes/widget/note/cardNote.dart';

class ListNoteFireBase extends StatefulWidget {
  const ListNoteFireBase({Key? key}) : super(key: key);

  @override
  State<ListNoteFireBase> createState() => _ListNoteFireBaseState();
}

class _ListNoteFireBaseState extends State<ListNoteFireBase> {
  late User? user;
  late Stream<QuerySnapshot> notesStream;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    notesStream = FirebaseFirestore.instance
        .collection('notes')
        .where('uid', isEqualTo: user!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: notesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            Note note = Note.fromMap(data);
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewNoteScreen(myNote: note),
                    ),
                  );
                },
                child: NoteCard(note: note));
          }).toList(),
        );
      },
    );
  }
}
