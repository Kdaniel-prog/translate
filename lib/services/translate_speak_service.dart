import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';

typedef StatusCallback = void Function(String status);
typedef ResultCallback = void Function(String text);

class TranslateSpeakService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isListening = false;
  bool speechAvailable = false;

  List<stt.LocaleName> localeNames = [];
  String selectedLocaleId = '';

  final StatusCallback onStatus;
  final ResultCallback onResult;

  TranslateSpeakService({
    required this.onStatus,
    required this.onResult,
  });

  Future<void> initialize() async {
    speechAvailable = await _speech.initialize(
      onStatus: (val) => onStatus("Speech status: $val"),
      onError: (val) {
        onStatus("Speech error: ${val.errorMsg}");
        isListening = false;
      },
    );

    if (speechAvailable) {
      localeNames = await _speech.locales();
      var systemLocale = await _speech.systemLocale();
      selectedLocaleId = systemLocale?.localeId ?? '';
      onStatus("Speech recognition ready.");
    } else {
      onStatus("Speech recognition not available.");
    }
  }

  void startListening() async {
    if (!speechAvailable) {
      onStatus("Speech not initialized.");
      return;
    }

    await _speech.listen(
      onResult: (result) {
        isListening = !result.finalResult;
        onResult(result.recognizedWords);
      },
      localeId: selectedLocaleId,
    );
    isListening = true;
    onStatus("Listening...");
  }

  void stopListening() async {
    await _speech.stop();
    isListening = false;
    onStatus("Stopped listening.");
  }

  Future<String> translateWithRapidAPI(String text, String targetLang) async {
    final url = Uri.parse('https://openl-translate.p.rapidapi.com/translate');

    final headers = {
      'x-rapidapi-key': '926599962cmshbb172c914798985p18e32cjsnd4d242e24fe7',
      'x-rapidapi-host': 'openl-translate.p.rapidapi.com',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'text': text, 'target_lang': targetLang});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final translated = jsonResponse['translatedText'] ??
          jsonResponse['translations']?[0]?['text'];
      if (translated == null) {
        throw Exception('Translation not found in response.');
      }
      return translated;
    } else {
      throw Exception('Failed to translate: ${response.body}');
    }
  }

  Future<void> textToSpeechWithRapidAPI(String text, String lang) async {
    final url =
        Uri.parse('https://text-to-speach-api.p.rapidapi.com/text-to-speech');

    final headers = {
      'x-rapidapi-key': '926599962cmshbb172c914798985p18e32cjsnd4d242e24fe7',
      'x-rapidapi-host': 'text-to-speach-api.p.rapidapi.com',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'text': text,
      'lang': lang,
      'speed': 'slow',
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      await _audioPlayer.play(BytesSource(response.bodyBytes));
    } else {
      throw Exception('TTS failed: ${response.body}');
    }
  }

  Future<void> translateAndSpeak(String text, String targetLang) async {
    onStatus("Translating...");
    try {
      String translated = await translateWithRapidAPI(text, targetLang);
      onResult(translated);
      onStatus("Speaking...");
      await textToSpeechWithRapidAPI(translated, targetLang);
      onStatus("Done speaking.");
    } catch (e) {
      onStatus("Error: $e");
      onResult("");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
