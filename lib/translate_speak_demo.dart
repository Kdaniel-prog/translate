import 'package:flutter/material.dart';
import 'services/translate_service.dart';
import 'services/text_to_speech_service.dart';
import 'services/speech_to_text.dart';

class TranslateSpeakDemo extends StatefulWidget {
  const TranslateSpeakDemo({super.key});
  @override
  State<TranslateSpeakDemo> createState() => _TranslateSpeakDemoState();
}

class _TranslateSpeakDemoState extends State<TranslateSpeakDemo> {
  final _translateService = TranslateService();
  final _ttsService = TextToSpeechService();
  final _textController = TextEditingController();

  late TranslateSpeakService _speechService;

  String status = "Type something and press the mic.";
  String translatedText = "";
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _speechService = TranslateSpeakService(
      onStatus: (newStatus) => setState(() => status = newStatus),
      onResult: (newText) => setState(() {
        isListening = false;
        _textController.text = newText;
        _textController.selection =
            TextSelection.collapsed(offset: newText.length);
      }),
    );
    _speechService.initialize();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translateAndSpeak() async {
    final inputText = _textController.text.trim();
    if (inputText.isEmpty) return;

    try {
      setState(() => status = "Translating...");
      final translated = await _translateService.translate(inputText, 'tl');

      setState(() {
        translatedText = translated;
        status = "Speaking...";
      });

      await _ttsService.speak(translated, 'tl');

      setState(() => status = "Done.");
    } catch (e) {
      setState(() => status = "Error: $e");
    }
  }

  void _toggleListening() {
    if (isListening) {
      _speechService.stopListening();
      setState(() {
        isListening = false;
      });
    } else {
      _speechService.startListening();
      setState(() {
        isListening = true;
        status = "Listening...";
      });
    }
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
                  onPressed: _translateAndSpeak,
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
                  onPressed: _toggleListening,
                  icon: Icon(isListening ? Icons.stop : Icons.mic),
                  label: Text(isListening ? "Stop" : "Speak"),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _speechService.selectedLocaleId,
                    isExpanded: true,
                    onChanged: (newLocale) {
                      setState(() {
                        _speechService.selectedLocaleId = newLocale ?? '';
                      });
                    },
                    items: _speechService.localeNames
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
            Text(
              status,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
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
