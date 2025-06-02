import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

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

    try {
      final response = await http.post(url, headers: headers, body: body);

      final contentType = response.headers['content-type'];

      if (response.statusCode == 200 &&
          contentType != null &&
          contentType.startsWith('audio')) {
        // Save the audio data to a temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/tts_audio.mp3'); // Adjust extension based on content-type

        // Write the response bytes to the file
        await tempFile.writeAsBytes(response.bodyBytes);

        // Play the audio using DeviceFileSource
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
      } else {
        throw Exception('TTS API failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Playback failed: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}