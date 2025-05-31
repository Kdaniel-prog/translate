import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translate/widgets/language_dropdown.dart';
import 'package:translate/widgets/translate_input_box.dart';
import 'package:translate/widgets/translated_result_box.dart';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3), // or your gradient if needed
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              "Translate App",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TranslateInputBox(
              controller: _textController,
              onClear: () {
                _textController.clear();
                setState(() {
                  translatedText = "";
                  status = "Cleared.";
                });
              },
              onTranslate: _translateAndSpeak,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                LanguageDropdown(
                  selectedLanguage: sourceLanguage,
                  languageList: languageList,
                  onChanged: (val) => setState(() => sourceLanguage = val),
                  backgroundColor: Color.fromARGB(255, 228, 229, 230), // Material Blue 500
                ),
                const SizedBox(width: 12),                
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
                const SizedBox(width: 12),                
                LanguageDropdown(
                  selectedLanguage: targetLanguage,
                  languageList: languageList,
                  onChanged: (val) => setState(() => targetLanguage = val),
                  backgroundColor: Color.fromARGB(255, 156, 200, 250), // Material Blue 500
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  TranslationResultBox(
                    translatedText: translatedText,
                    onCopy: () => Clipboard.setData(ClipboardData(text: translatedText)),
                    onSpeak: () => _ttsService.speak(translatedText, targetLanguage),
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
