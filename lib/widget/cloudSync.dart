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
      return CustomButton(
        label: 'Keep Local Only',
        icon: Icons.file_copy,
        onClick: () {
          cloudProvider.setIsSync(false);
        },
        color: Colors.red,
      );
    }
    return CustomButton(
      label: 'Sync To Cloud',
      icon: Icons.cloud,
      onClick: () {
        cloudProvider.setIsSync(true);
      },
      color: Colors.green,
    );
  }
}


