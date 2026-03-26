import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gunce/config/api_keys.dart';
import 'package:http/http.dart' as http;
import '../models/entry.dart';

class GeminiService {
  static const String _apiKey = ApiKeys.geminiApiKey;

  static const List<String> _validMoods = [
    'Harika', 'Mutlu', 'Huzurlu', 'Sakin',
    'Odaklanmış', 'Düşünceli', 'Heyecanlı',
    'Stresli', 'Yorgun', 'Hüzünlü',
  ];

  /// Verilen Türkçe metin için en uygun duygu durumunu döndürür.
  /// Metin anlamsız/yetersizse null döndürür.
  static Future<String?> analyzeMood(String text) async {
    final cleaned = text.trim();
    // Minimum 20 karakter ve en az 3 kelime olmalı
    if (cleaned.isEmpty) return null;
    final wordCount = cleaned.split(RegExp(r'\s+')).where((w) => w.length > 1).length;
    if (cleaned.length < 20 || wordCount < 3) return null;

    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    final prompt = '''
Sen bir duygu analisti olarak aşağıdaki Türkçe metni değerlendireceksin.

KURALLAR:
1. Metin, bir günlük/anı yazısı gibi anlamlı ve kişisel bir içerik taşımalı.
2. Eğer metin anlamsız, rastgele kelimeler, sadece test amaçlı şeyler veya kişisel bir duyguyu yansıtmıyorsa SADECE "YOK" yaz.
3. Eğer metin anlamlıysa, yazarın genel ruh halini aşağıdaki listeden TAM OLARAK bir kelimeyle belirle:
   ${_validMoods.join(', ')}
4. Başka hiçbir açıklama veya kelime yazma. Sadece listeden bir kelime veya "YOK".

Metin:
"$cleaned"
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
          'maxOutputTokens': 20,
          'thinkingConfig': {
            'thinkingBudget': 0,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;

      String result = '';
      if (parts != null) {
        for (final part in parts) {
          if (part['thought'] != true && part['text'] != null) {
            result = part['text'].toString().trim();
            break;
          }
        }
      }

      // "YOK" döndürdüyse ruh hali atama
      if (result.toUpperCase().contains('YOK')) return null;

      final matched = _validMoods.firstWhere(
        (m) => result.toLowerCase().contains(m.toLowerCase()),
        orElse: () => '',
      );

      // Eşleşme yoksa da null dön (zorla atama yapma)
      if (matched.isEmpty) return null;

      return matched;
    } else {
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
        "Sen yaratıcı bir yazarlık atölyesi lideri ve günlük koçusun. ";
    if (currentText != null && currentText.trim().isNotEmpty) {
      prompt +=
          "Kullanıcı şunu yazdı: '$currentText'. Bu metni daha da derinleştirmesi için ona yaratıcı bir yazma yönergesi ver. Onu betimleme yapmaya, duygusunu detaylandırmaya veya o andaki bir kokuya/sese odaklanmaya teşvik et. 15 kelime sınırı.";
    } else {
      prompt +=
          "Kullanıcıya bugünkü anısını yazması için yaratıcı ve somut bir yazma yönergesi ver. (Örn: 'Günün en parlak anını bir tablo gibi anlat', 'Bugün duyduğun en garip sesi betimle' gibi). 15 kelime sınırı.";
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
          'generationConfig': {
             'temperature': 0.9, 
             'maxOutputTokens': 150,
             'thinkingConfig': {'thinkingBudget': 0}
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        
        String result = '';
        if (parts != null) {
          for (final part in parts) {
            // Düşünce (thought) olmayan ve metin içeren ilk parçayı al
            if (part['thought'] != true && part['text'] != null) {
              result = part['text'].toString().trim();
              break;
            }
          }
        }

        result = result.replaceAll('"', '');
        
        // Yarım kalmış cümleleri (noktalama işareti yoksa) kontrol et ve temizle
        if (result.length < 8) return "Bugün seni en çok gülümseten an neydi?";
        
        return result;
      }
    } catch (e) {
      debugPrint('Soru sorma hatası: $e');
    }
    return "Bugün kendi dünyana dair ne keşfettin?";
  }

  /// Hafıza Sohbeti için Gemini'den yanıt alır.
  static Future<String?> getChatResponse(String userMessage, List<Entry> entries) async {
    if (_apiKey.isEmpty) return "API Anahtarı bulunamadı.";

    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    // Anıları özetleyip context olarak hazırlıyoruz
    String memoryContext = "Sen kullanıcının kişisel günlük asistanı 'Günce'sin. Senin bir bilincin ve hafızan var. ";
    if (entries.isNotEmpty) {
      memoryContext += "İşte kullanıcının geçmiş anılarından bazı notlar:\n";
      // Son 15 anıyı gönderiyoruz (Limit aşmamak için)
      final recentEntries = entries.take(15).toList();
      for (var e in recentEntries) {
        memoryContext += "- [${e.date.day}/${e.date.month}/${e.date.year}] (Ruh Hali: ${e.mood}): ${e.text}\n";
      }
    }
    
    memoryContext += "\nKullanıcı az önce şunu yazdı: '$userMessage'. ";
    memoryContext += "Onunla empati kur, geçmiş anılarına (eğer ilgiliyse) atıfta bulun ve yapıcı bir dille cevap ver. ";
    memoryContext += "Cevabın 60 kelimeyi geçmemeli. Karakterin: Samimi, bilge ve her şeyi hatırlayan bir dost. Unutma, sen bir yapay zeka değil, kullanıcının geçmişini koruyan bir yoldaşsın.";

    try {
      final response = await http.post(
        Uri.parse('$url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': [{'text': memoryContext}]}
          ],
          'generationConfig': {
             'temperature': 0.7, 
             'maxOutputTokens': 300,
             'thinkingConfig': {'thinkingBudget': 0}
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        
        String result = '';
        if (parts != null) {
          for (final part in parts) {
            if (part['thought'] != true && part['text'] != null) {
              result = part['text'].toString().trim();
              break;
            }
          }
        }
        return result;
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
