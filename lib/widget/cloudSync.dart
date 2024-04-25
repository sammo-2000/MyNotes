import 'package:flutter/material.dart';
import 'package:notes/provider/cloudProvider.dart';
import 'package:notes/widget/button.dart';
import 'package:provider/provider.dart';

class SyncToCloud extends StatelessWidget {
  const SyncToCloud({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudProvider = Provider.of<CloudProvider>(context);
    if (cloudProvider.isSync) {
      return Column(
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_done_rounded),
              SizedBox(width: 8.0),
              Text('File Stored Safely On Cloud'),
            ],
          ),
          CustomButton(
            label: 'Keep Local Only',
            icon: Icons.cloud_off,
            onClick: () {
              cloudConfirmButton(
                context,
                'Keep Local Only',
                'Are you sure you would like to stop using cloud? Doing so your data will only be stored locally on single device',
                Colors.red,
                () {
                  cloudProvider.setIsSync(false);
                  Navigator.pop(context);
                },
              );
            },
            color: Colors.red,
          ),
        ],
      );
    }
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.cloud_off),
            SizedBox(width: 8.0),
            Text('File Stored Only On Your Device'),
          ],
        ),
        CustomButton(
          label: 'Sync To Cloud',
          icon: Icons.cloud_done_rounded,
          onClick: () {
            cloudConfirmButton(
              context,
              'Sync To Cloud',
              'Are you sure you would like to start using cloud? Doing so your data will be stored online and accessible on all your devices',
              Colors.green,
              () {
                cloudProvider.setIsSync(true);
                Navigator.pop(context);
              },
            );
          },
          color: Colors.green,
        ),
      ],
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
