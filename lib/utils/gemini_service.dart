import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyChaq9qAEbpVawoL2ZLjKdk_75j028El6U';

  static const List<String> _validMoods = [
    'Harika', 'Mutlu', 'Huzurlu', 'Sakin',
    'Odaklanmış', 'Düşünceli', 'Heyecanlı',
    'Stresli', 'Yorgun', 'Hüzünlü',
  ];

  /// Verilen Türkçe metin için en uygun duygu durumunu döndürür.
  /// Hata durumunda [GeminiException] fırlatır.
  static Future<String?> analyzeMood(String text) async {
    if (text.trim().isEmpty) return null;

    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    final prompt = '''
Aşağıdaki Türkçe günlük/anı metnini analiz et ve yazarın genel ruh halini belirle.
Sadece aşağıdaki listeden TAM OLARAK bir kelime döndür, başka hiçbir şey yazma:
${_validMoods.join(', ')}

Metin:
"$text"
''';

    final response = await http.post(
      Uri.parse('$url?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 50,
          'thinkingConfig': {
            'thinkingBudget': 0,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;

      // Thinking modellerinde thought:true olan partları atla
      String result = '';
      if (parts != null) {
        for (final part in parts) {
          if (part['thought'] != true && part['text'] != null) {
            result = part['text'].toString().trim();
            break;
          }
        }
      }

      final matched = _validMoods.firstWhere(
        (m) => result.toLowerCase().contains(m.toLowerCase()),
        orElse: () => '',
      );

      if (matched.isEmpty) {
        // Debug: hangi yanıt geldi göster
        throw GeminiException('Eşleşme yok. Model yanıtı: "${result.length > 80 ? result.substring(0, 80) : result}"');
      }

      return matched;
    } else {
      // Hata detayını fırlat
      String errorMsg = 'HTTP ${response.statusCode}';
      try {
        final errData = jsonDecode(response.body);
        errorMsg = errData['error']?['message'] ?? errorMsg;
      } catch (_) {}
      throw GeminiException(errorMsg);
    }
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}
