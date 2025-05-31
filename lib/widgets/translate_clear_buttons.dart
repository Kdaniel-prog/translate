import 'package:flutter/material.dart';

class TranslateClearButtons extends StatelessWidget {
  final VoidCallback onTranslate;
  final VoidCallback onClear;

  const TranslateClearButtons({
    super.key,
    required this.onTranslate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onTranslate,
          icon: const Icon(Icons.play_arrow),
          label: const Text("Translate & Speak"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onClear,
          child: const Text("Clear"),
        ),
      ],
    );
  }
}
