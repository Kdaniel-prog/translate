import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class TextToSpeechService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String _apiKey = '926599962cmshbb172c914798985p18e32cjsnd4d242e24fe7';
  final String _apiHost = 'text-to-speach-api.p.rapidapi.com';

  Future<void> speak(String text, String lang) async {
    final url = Uri.parse('https://text-to-speach-api.p.rapidapi.com/text-to-speech');

    final headers = {
      'x-rapidapi-key': _apiKey,
      'x-rapidapi-host': _apiHost,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'text': text,
      'lang': lang,
      'speed': 'slow',
    });

    final response = await http.post(url, headers: headers, body: body);

    final contentType = response.headers['content-type'];

    if (response.statusCode == 200 &&
        contentType != null &&
        contentType.startsWith('audio')) {
      try {
        await _audioPlayer.play(BytesSource(response.bodyBytes));
      } catch (e) {
        throw Exception('Playback failed: $e');
      }
    } else {
      throw Exception('TTS failed: ${response.body}');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
