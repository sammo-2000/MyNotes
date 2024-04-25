import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/authGate.dart';
import 'package:notes/widgets/button.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Log Out',
      icon: Icons.logout,
      color: Colors.red,
      onClick: () {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthGate(),
          ),
        );
      },
    );
  }
}
