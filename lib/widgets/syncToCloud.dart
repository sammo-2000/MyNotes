import 'package:flutter/material.dart';
import 'package:notes/database/firebase.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/database/syncCloud.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/cloudProvider.dart';
import 'package:notes/providers/notesProvider.dart';
import 'package:notes/widgets/button.dart';
import 'package:provider/provider.dart';

class SyncToCloud extends StatefulWidget {
  const SyncToCloud({super.key});

  @override
  State<SyncToCloud> createState() => _SyncToCloudState();
}

class _SyncToCloudState extends State<SyncToCloud> {
  @override
  Widget build(BuildContext context) {
    final cloudProvider = Provider.of<CloudProvider>(context);
    final notesProvider = Provider.of<NoteProvider>(context);
    if (cloudProvider.isSync) {
      return CustomButton(
        label: 'Synced To Cloud',
        icon: Icons.cloud_done_rounded,
        onClick: () {
          cloudConfirmButton(
            context,
            'Keep Local Only',
            'Are you sure you would like to stop using cloud? Doing so your data will only be stored locally on single device',
            Colors.red,
                () {
              cloudProvider.setIsSync(false);
              MyFireBase fireBase = MyFireBase();
              fireBase.setCloudSettings(false);
              Navigator.pop(context);
            },
          );
        },
        color: Colors.green,
      );
    }
    return CustomButton(
      label: 'Local Only',
      icon: Icons.cloud_off,
      onClick: () {
        cloudConfirmButton(
          context,
          'Sync To Cloud',
          'Are you sure you would like to start using cloud? Doing so your data will be stored online and accessible on all your devices',
          Colors.green,
              () async {
            await cloudProvider.setIsSync(true);
            await syncBetweenCloud(notesProvider);
            MyFireBase fireBase = MyFireBase();
            List<Note>? noteList = await MyDatabase.getAllNotes();
            notesProvider.setNotes(noteList!);
            await fireBase.setCloudSettings(true);
            Navigator.pop(context);
          },
        );
      },
      color: Colors.red,
    );
  }
}

Future<dynamic> cloudConfirmButton(
    BuildContext context,
    String title,
    String body,
    Color color,
    void Function()? onConfirm,
    ) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
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
            onPressed: onConfirm,
            child: Text(
              'Confirm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      );
    },
  );
}
