import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/widget/button.dart';

class CustomDialog {
  static Future<void> show(
    BuildContext context,
    String title,
    String content,
  ) async {
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
            content,
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
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
