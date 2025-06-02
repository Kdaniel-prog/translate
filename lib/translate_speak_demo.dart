import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kd_translater/widgets/UI/language_dropdown.dart';
import 'package:kd_translater/widgets/UI/translate_input_box.dart';
import 'package:kd_translater/widgets/UI/translated_result_box.dart';
import 'services/translate_service.dart';
import 'services/text_to_speech_service.dart';
import 'widgets/speech_to_text.dart';
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
      onStatus: (newStatus) {
        setState(() {
          status = newStatus;
          if (newStatus.contains('done') ||
              newStatus.contains('notListening') ||
              newStatus.contains('error')) {
            isListening = false;
          }
        });
      },
      onResult: (newText) {
        setState(() {
          _textController.text = newText;
          _textController.selection =
              TextSelection.collapsed(offset: newText.length);
        });
      },
      onClearText: () {
        setState(() {
          _textController.clear();
          translatedText = "";
          status = "Text cleared.";
        });
      },
    );
    _speechService.initialize();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _textController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _translateAndSpeak() async {
    final inputText = _textController.text.trim();
    if (inputText.isEmpty) {
      setState(() => status = "No text to translate.");
      return;
    }

    try {
      setState(() => status = "Translating...");
      final translated =
          await _translateService.translate(inputText, targetLanguage);

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
        status = "Stopped listening.";
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          "Translate App",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TranslateInputBox(
              controller: _textController,
              onClear: () {
                setState(() {
                  _textController.clear();
                  translatedText = "";
                  status = "Text cleared.";
                });
              },
              onTranslate: _translateAndSpeak,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LanguageDropdown(
                    selectedLanguage: sourceLanguage,
                    languageList: languageList,
                    onChanged: (val) => setState(() => sourceLanguage = val),
                    backgroundColor: const Color.fromARGB(255, 228, 229, 230),
                    textColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: "Swap languages",
                  onPressed: () {
                    setState(() {
                      final tempLang = sourceLanguage;
                      sourceLanguage = targetLanguage;
                      targetLanguage = tempLang;
                      final tempText = _textController.text;
                      _textController.text = translatedText;
                      translatedText = tempText;
                      status = "Languages and texts swapped.";
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LanguageDropdown(
                    selectedLanguage: targetLanguage,
                    languageList: languageList,
                    onChanged: (val) => setState(() => targetLanguage = val),
                    backgroundColor: const Color.fromARGB(255, 156, 200, 250),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: TranslationResultBox(
                translatedText: translatedText,
                onCopy: () {
                  if (translatedText.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: translatedText));
                    setState(() => status = "Text copied.");
                  }
                },
                onSpeak: () {
                  if (translatedText.isNotEmpty) {
                    _ttsService.speak(translatedText, targetLanguage);
                    setState(() => status = "Speaking...");
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: _toggleListening,
              child: Icon(isListening ? Icons.stop : Icons.mic),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: $status',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}