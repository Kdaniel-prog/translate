import 'dart:async';
import 'dart:html' as html show window; // Only available in Flutter Web
import 'package:flutter/foundation.dart' show kIsWeb;
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
  final VoidCallback? onClearText;

  Timer? _silenceTimer;

  SpeechToText({
    required this.onStatus,
    required this.onResult,
    this.onClearText,
  });

  /// Detect if running on iOS Web (Safari/Chrome/Firefox all use WebKit)
  bool get _isIOSWeb {
    if (!kIsWeb) return false;
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains("iphone") || userAgent.contains("ipad");
  }

  Future<void> initialize() async {
    if (_isIOSWeb) {
      // Speech recognition not supported in iOS browsers
      onStatus("Speech recognition not supported on iOS browsers.");
      speechAvailable = false;
      return;
    }

    speechAvailable = await _speech.initialize(
      onStatus: (val) {
        onStatus('Speech status: $val');
        if (val == 'done' || val == 'notListening' || val == 'error') {
          isListening = false;
          _silenceTimer?.cancel();
          _speech.stop();
        }
      },
      onError: (val) {
        onStatus("Error: ${val.errorMsg}");
        isListening = false;
        _silenceTimer?.cancel();
        _speech.stop();
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
      onStatus("Speech not initialized or not supported.");
      return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          isListening = false;
          _silenceTimer?.cancel();
          _speech.stop();
          onStatus("Stopped listening (final result).");
        } else {
          _silenceTimer?.cancel();
          _silenceTimer = Timer(const Duration(seconds: 5), () {
            if (isListening) {
              stopListening();
              onStatus("Stopped listening (silence timeout).");
            }
          });
        }
      },
      localeId: selectedLocaleId,
      partialResults: true,
    );
    isListening = true;
    onStatus("Listening...");
  }

  void stopListening() async {
    if (!speechAvailable) return;
    await _speech.stop();
    isListening = false;
    _silenceTimer?.cancel();
    onStatus("Stopped listening.");
  }

  void dispose() {
    _speech.stop();
    _silenceTimer?.cancel();
    onStatus("Speech recognition disposed.");
  }
}
