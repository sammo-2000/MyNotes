import 'package:flutter/material.dart';
import 'package:notes/widgets/logout.dart';
import 'package:notes/widgets/syncToCloud.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S E T T I N G S')),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            SyncToCloud(),
            LogOutButton(),
          ],
        ),
      ),
    );
  }
}
