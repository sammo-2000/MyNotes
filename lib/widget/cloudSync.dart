import 'package:flutter/material.dart';
import 'package:notes/widget/button.dart';

class SyncToCloud extends StatelessWidget {
  const SyncToCloud({super.key});

  @override
  Widget build(BuildContext context) {
    bool syncIsActive = true;

    if (syncIsActive) {
      return CustomButton(
        label: 'Keep Local Only',
        icon: Icons.file_copy,
        onClick: () {},
        color: Colors.red,
      );
    }
    return CustomButton(
      label: 'Sync To Cloud',
      icon: Icons.cloud,
      onClick: () {},
      color: Colors.green,
    );
  }
}


