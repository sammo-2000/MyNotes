import 'package:flutter/material.dart';
import 'package:notes/widget/button.dart';
import 'package:notes/widget/cloudSync.dart';
import 'package:notes/widget/logout.dart';

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
