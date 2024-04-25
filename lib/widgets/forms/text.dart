import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const CustomText({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 5,
        decoration: InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
          label: Text(label),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
