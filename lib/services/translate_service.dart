import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslateService {
  final String _apiKey = '926599962cmshbb172c914798985p18e32cjsnd4d242e24fe7';
  final String _apiHost = 'openl-translate.p.rapidapi.com';

  Future<String> translate(String text, String targetLang) async {
    final url = Uri.parse('https://openl-translate.p.rapidapi.com/translate');

    final headers = {
      'x-rapidapi-key': _apiKey,
      'x-rapidapi-host': _apiHost,
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
}
