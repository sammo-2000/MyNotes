import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool center;
  final bool obscureText;
  const CustomInput({
    super.key,
    required this.controller,
    this.label,
    this.center = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlign: center == true ? TextAlign.center : TextAlign.start,
        decoration: label != null
            ? InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
          labelText: label,
        )
            : const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}
