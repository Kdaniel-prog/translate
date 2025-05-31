import 'package:flutter/material.dart';
import 'services/translate_speak_service.dart';

class TranslateSpeakDemo extends StatefulWidget {
  const TranslateSpeakDemo({super.key});
  @override
  State<TranslateSpeakDemo> createState() => _TranslateSpeakDemoState();
}

class _TranslateSpeakDemoState extends State<TranslateSpeakDemo> {
  late TranslateSpeakService _service;
  final TextEditingController _textController = TextEditingController();

  String status = "Type something and press the mic.";
  String translatedText = "";
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _service = TranslateSpeakService(
      onStatus: (newStatus) => setState(() => status = newStatus),
      onResult: (newText) => setState(() {
        isListening = false;
        translatedText = newText;
        _textController.text = newText;
        _textController.selection =
            TextSelection.collapsed(offset: newText.length);
      }),
    );
    _service.initialize();
  }

  @override
  void dispose() {
    _service.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Translate & Speak")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Enter text to translate",
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      _service.translateAndSpeak(_textController.text.trim(), 'tl');
                    }
                  },
                  icon: Icon(Icons.play_arrow),
                  label: Text("Translate & Speak"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      translatedText = "";
                      status = "Cleared.";
                    });
                  },
                  child: Text("Clear"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (isListening) {
                      _service.stopListening();
                      setState(() {
                        isListening = false;
                      });
                    } else {
                      _service.startListening();
                      setState(() {
                        isListening = true;
                      });
                    }
                  },
                  icon: Icon(isListening ? Icons.stop : Icons.mic),
                  label: Text(isListening ? "Stop" : "Speak"),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _service.selectedLocaleId,
                    isExpanded: true,
                    onChanged: (newLocale) {
                      setState(() {
                        _service.selectedLocaleId = newLocale ?? '';
                      });
                    },
                    items: _service.localeNames
                        .map((locale) => DropdownMenuItem(
                              value: locale.localeId,
                              child: Text(locale.name),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(status,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text(
              translatedText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
