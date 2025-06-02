import 'package:flutter/material.dart';

class TranslationResultBox extends StatelessWidget {
  final String translatedText;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;

  const TranslationResultBox({
    super.key,
    required this.translatedText,
    required this.onCopy,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 300, // Adjust as needed
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                translatedText,
                style: const TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, color: Colors.white),
                label: const Text(
                  "Copy Text",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton.icon(
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: const Text(
                  "Speak",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
