import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef StatusCallback = void Function(String status);
typedef ResultCallback = void Function(String text);

class SpeechToText {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool isListening = false;
  bool speechAvailable = false;

  List<stt.LocaleName> localeNames = [];
  String selectedLocaleId = '';

  final StatusCallback onStatus;
  final ResultCallback onResult;
  final VoidCallback? onClearText; // optional callback

  SpeechToText({
    required this.onStatus,
    required this.onResult,
    this.onClearText,
  });

  Future<void> initialize() async {
    speechAvailable = await _speech.initialize(
      onStatus: (val) => onStatus(val),
      onError: (val) {
        onStatus("Error! ${val.errorMsg}");
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

  void clearText() {
    onClearText?.call();
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
 
}
