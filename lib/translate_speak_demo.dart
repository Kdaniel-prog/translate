import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/translate_service.dart';
import 'services/text_to_speech_service.dart';
import 'services/speech_to_text.dart';
import 'data/languages.dart';

class TranslateSpeakDemo extends StatefulWidget {
  const TranslateSpeakDemo({super.key});

  @override
  State<TranslateSpeakDemo> createState() => _TranslateSpeakDemoState();
}

class _TranslateSpeakDemoState extends State<TranslateSpeakDemo> {
  final _translateService = TranslateService();
  final _ttsService = TextToSpeechService();
  final _textController = TextEditingController();

  late SpeechToText _speechService;

  String status = "Type something and press the mic.";
  String translatedText = "";
  bool isListening = false;
  String sourceLanguage = 'en';
  String targetLanguage = 'tl';

  @override
  void initState() {
    super.initState();
    _speechService = SpeechToText(
      onStatus: (newStatus) => setState(() => status = newStatus),
      onResult: (newText) => setState(() {
        isListening = false;
        _textController.text = newText;
        _textController.selection =
            TextSelection.collapsed(offset: newText.length);
      }),
      onClearText: () => setState(() {
        _textController.clear();
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
      final translated = await _translateService.translate(inputText, targetLanguage);

      setState(() {
        translatedText = translated;
        status = "Speaking...";
      });

      await _ttsService.speak(translated, targetLanguage);

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
      appBar: AppBar(title: const Text("Translate & Speak")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Enter text to translate",
                counterText: '${_textController.text.length}/2000',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.text = "";
                    setState(() {
                      translatedText = "";
                      status = "Cleared.";
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              maxLength: 2000,
              maxLines: null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: sourceLanguage,
                    isExpanded: true,
                    onChanged: (val) => setState(() => sourceLanguage = val!),
                    items: languageList.map((lang) => DropdownMenuItem(
                      value: lang['code'],
                      child: Text(lang['name']!),
                    )).toList(),
                  ),
                ),
                // Swap button in the middle
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: "Swap languages",
                  onPressed: () {
                    setState(() {
                      // Swap the languages
                      final tempLang = sourceLanguage;
                      sourceLanguage = targetLanguage;
                      targetLanguage = tempLang;
                      
                      // Swap the texts
                      final tempText = _textController.text;
                      _textController.text = translatedText;
                      translatedText = tempText;

                      status = "Languages and texts swapped.";
                    });
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: targetLanguage,
                    isExpanded: true,
                    onChanged: (val) => setState(() => targetLanguage = val!),
                    items: languageList.map((lang) => DropdownMenuItem(
                      value: lang['code'],
                      child: Text(lang['name']!),
                    )).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _translateAndSpeak,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Translate & Read"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      translatedText = "";
                      status = "Cleared.";
                    });
                  },
                  child: const Text("Clear"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.blueAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          translatedText,
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white),
                              onPressed: () => Clipboard.setData(
                                  ClipboardData(text: translatedText)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up, color: Colors.white),
                              onPressed: () => _ttsService.speak(translatedText, targetLanguage),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: _toggleListening,
                      child: Icon(isListening ? Icons.stop : Icons.mic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              status,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
