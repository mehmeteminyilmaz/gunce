import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:gunce/config/api_keys.dart';
import 'package:http/http.dart' as http;
import '../models/entry.dart';

class GeminiService {
  static String get _apiKey {
    try {
      final customKey = Hive.box('profile').get('gemini_api_key', defaultValue: '') as String;
      if (customKey.trim().isNotEmpty) return customKey.trim();
    } catch (_) {}
    return ApiKeys.geminiApiKey;
  }

  static const List<String> _validMoods = [
    'Harika', 'Mutlu', 'Huzurlu', 'Sakin',
    'Odaklanmış', 'Düşünceli', 'Heyecanlı',
    'Stresli', 'Yorgun', 'Hüzünlü',
  ];

  static const List<String> _fallbackQuestions = [
    "Bugün seni en çok gülümseten küçük an neydi?",
    "Bugün zihnini en çok meşgul eden düşünce neydi?",
    "Bugün kendine verdiğin hangi sözü tuttun?",
    "Bugün duyduğun ve seni etkileyen bir ses veya kelime var mıydı?",
    "Bugün yaşadıklarının içinden süzülen, seni en çok sen yapan öz neydi?",
    "Bugün minnettar hissettiğin tek bir ayrıntı söyleyecek olsan ne olurdu?",
    "Bugün farkında olmadan üstlendiğin bir duygu var mıydı?",
    "Bugün seni şaşırtan ya da beklenmedik bir an yaşadın mı?",
    "Bugünü tek bir renk veya koku ile tanımlasan hangisi olurdu?",
    "Bugün içinden geçen ama dışarıya söyleyemediğin bir cümle neydi?",
  ];

  /// Verilen Türkçe metin için en uygun duygu durumunu döndürür.
  static Future<String?> analyzeMood(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return null;
    final wordCount = cleaned.split(RegExp(r'\s+')).where((w) => w.length > 1).length;
    if (cleaned.length < 20 || wordCount < 3) return null;

    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    final systemInstruction = '''
Sen uzman bir duygu analistisin. Sana verilen günlük yazısını değerlendireceksin.
KURALLAR:
1. Metin anlamsızsa veya kişisel bir duygu yansıtmıyorsa SADECE "YOK" yaz.
2. Metin anlamlıysa yazarın ruh halini listeden TAM OLARAK bir kelime seçerek yaz:
   ${_validMoods.join(', ')}
3. Başka hiçbir açıklama yazma.
''';

    try {
      final response = await http.post(
        Uri.parse('$url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [{'text': systemInstruction}]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': cleaned}]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 300,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;

        String result = '';
        if (parts != null && parts.isNotEmpty) {
          result = parts[0]['text'].toString().trim();
        }

        if (result.toUpperCase().contains('YOK')) return null;

        final matched = _validMoods.firstWhere(
          (m) => result.toLowerCase().contains(m.toLowerCase()),
          orElse: () => '',
        );

        return matched.isNotEmpty ? matched : null;
      }
    } catch (e) {
      debugPrint('Mood analiz hatası: $e');
    }
    return null;
  }

  /// Kullanıcıya günün ilham verici sorusunu üretir.
  static Future<String?> getReflectiveQuestion([String? currentText]) async {
    final randomFallback = _fallbackQuestions[Random().nextInt(_fallbackQuestions.length)];
    if (_apiKey.isEmpty) return randomFallback;

    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    const systemInstruction = '''
Sen bilge bir günlük koçu ve edebiyatçısın. Görevin kullanıcıya günün anısını yazması için İLHAM VERİCİ, ZARİF ve MÜKEMMEL TÜRKÇE ile tek bir soru sormaktır.
KURALLAR:
1. Sadece TEK BİR soru cümlesi yaz.
2. Tırnak işareti, başlık, yıldız ya da açıklama metni EKLEME.
3. Soru cümlesi mutlaka soru işareti (?) ile bitmeli.
4. İmla, noktalama ve dilbilgisi kusursuz olmalıdır.
''';

    String prompt = currentText != null && currentText.trim().isNotEmpty
        ? "Kullanıcı şunu yazdı: '$currentText'. Bu metni derinleştirmesi için ona kısa ve ilham verici tek bir soru sor."
        : "Bugün üzerine düşünebileceği yaratıcı, derin ve tek bir soru sor.";

    try {
      final response = await http.post(
        Uri.parse('$url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [{'text': systemInstruction}]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.6,
            'maxOutputTokens': 1200,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          String result = parts[0]['text'].toString().trim()
              .replaceAll('"', '')
              .replaceAll("'", '')
              .replaceAll('*', '')
              .replaceAll('_', '')
              .trim();
          
          if (result.length > 10 && result.endsWith('?')) {
            return result;
          } else if (result.length > 10) {
            return '$result?';
          }
        }
      }
    } catch (e) {
      debugPrint('Soru sorma hatası: $e');
    }
    return randomFallback;
  }

  /// Hafıza Sohbeti için eksiksiz ve akıcı yanıt üretir.
  static Future<String?> getChatResponse(String userMessage, List<Entry> entries) async {
    if (_apiKey.isEmpty) return "API Anahtarı bulunamadı.";

    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    String systemInstruction = '''
Sen kullanıcının kişisel günlük arkadaşı ve yoldaşı 'Günce'sin.
GÖREVLERİN:
1. Kullanıcıyla çok samimi, sıcak, empatik ve dostane bir dille Türkçe konuş.
2. Sana verilen geçmiş anılardan ilgili olanlar varsa onlara doğal bir şekilde değin.
3. Cümlelerini asla yarım bırakma. Tam, anlaşılır, akıcı ve eksiksiz yanıtlar ver.
4. Bir yapay zeka gibi soğuk değil, her şeyi hatırlayan gerçek bir dost gibi hissettir.
''';

    String userPrompt = "";
    if (entries.isNotEmpty) {
      userPrompt += "Kullanıcının geçmiş anılarından bazıları:\n";
      final recentEntries = entries.take(15).toList();
      for (var e in recentEntries) {
        userPrompt += "- [${e.date.day}/${e.date.month}/${e.date.year}] (Ruh hali: ${e.mood ?? 'Belirtilmemiş'}): ${e.text}\n";
      }
      userPrompt += "\n";
    }

    userPrompt += "Kullanıcının sana mesajı: '$userMessage'";

    try {
      final response = await http.post(
        Uri.parse('$url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [{'text': systemInstruction}]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': userPrompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1500,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          String result = parts[0]['text'].toString().trim();
          if (result.isNotEmpty) return result;
        }
      } else {
        debugPrint('Gemini Chat API Hata (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Chat hatası: $e');
    }
    return "Şu an bağlantı kuramıyorum, ama anılarını korumaya devam ediyorum.";
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}
