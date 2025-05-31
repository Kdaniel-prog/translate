import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  const InputTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Enter text to translate",
        border: OutlineInputBorder(),
      ),
      minLines: 1,
      maxLines: 4,
    );
  }
}
