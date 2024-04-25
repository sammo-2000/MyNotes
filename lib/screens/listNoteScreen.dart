import 'package:flutter/material.dart';
import 'package:notes/provider/cloudProvider.dart';
import 'package:notes/provider/notesProvider.dart';
import 'package:notes/screens/addNoteScreen.dart';
import 'package:notes/screens/settingsScreen.dart';
import 'package:notes/widget/button.dart';
import 'package:notes/widget/note/listNotesFireBase.dart';
import 'package:notes/widget/note/listNotesLocal.dart';
import 'package:provider/provider.dart';

class ListNoteScreen extends StatelessWidget {
  const ListNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudProvider = Provider.of<CloudProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('M Y   N O T E S'),
          automaticallyImplyLeading: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNoteScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomButton(
              label: 'Settings',
              icon: Icons.settings,
              color: Colors.black,
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
            ),
            cloudProvider.isSync == false
                ? const Expanded(child: ListNotes())
                : const Expanded(child: ListNoteFireBase()),
          ],
        ),
      ),
    );
  }
}
