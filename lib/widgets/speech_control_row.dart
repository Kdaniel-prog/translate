import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechControlRow extends StatelessWidget {
  final bool isListening;
  final VoidCallback onMicPressed;
  final String selectedLocaleId;
  final List<stt.LocaleName> localeNames;
  final ValueChanged<String?> onLocaleChanged;

  const SpeechControlRow({
    super.key,
    required this.isListening,
    required this.onMicPressed,
    required this.selectedLocaleId,
    required this.localeNames,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onMicPressed,
          icon: Icon(isListening ? Icons.stop : Icons.mic),
          label: Text(isListening ? "Stop" : "Speak"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButton<String>(
            value: selectedLocaleId,
            isExpanded: true,
            onChanged: onLocaleChanged,
            items: localeNames.map((locale) {
              return DropdownMenuItem(
                value: locale.localeId,
                child: Text(locale.name),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
