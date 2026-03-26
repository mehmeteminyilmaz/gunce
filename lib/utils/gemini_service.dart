import 'dart:convert';
import 'package:gunce/config/api_keys.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = ApiKeys.geminiApiKey;

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

  /// Kullanıcıyı derin düşünmeye sevk edecek tek bir soru üretir.
  static Future<String?> getReflectiveQuestion([String? currentText]) async {
    if (_apiKey.isEmpty) return null;

    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    String prompt =
        "Sen derinlikli, felsefi ve empatik bir günlük asistanısın. ";
    if (currentText != null && currentText.trim().isNotEmpty) {
      prompt +=
          "Kullanıcı şu an günlüğüne şunu yazıyor: '$currentText'. Bu metinden yola çıkarak onu derin bir içsel yolculuğa çıkaracak, ucu açık ve 15 kelimeyi geçmeyen bir soru sor.";
    } else {
      prompt +=
          "Kullanıcıya bugünle ilgili derin bir farkındalık kazandıracak, 15 kelimeyi geçmeyen tek bir soru sor.";
    }

    try {
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
          'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 100}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        return text.trim().replaceAll('"', '');
      }
    } catch (e) {
      print('Soru sorma hatası: $e');
    }
    return null;
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}
