import 'package:flutter/material.dart';

class TranslatedTextDisplay extends StatelessWidget {
  final String text;

  const TranslatedTextDisplay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
