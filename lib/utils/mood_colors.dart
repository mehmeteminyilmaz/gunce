import 'package:flutter/material.dart';

class MoodColors {
  static const Map<String, Color> colors = {
    'Harika': Color(0xFF9F7AEA),     // Şeftali Moru
    'Mutlu': Color(0xFFFFD166),      // Sıcak Sarı
    'Huzurlu': Color(0xFF7F9CF5),    // Açık Lavanta
    'Sakin': Color(0xFF5A67D8),      // İndigo
    'Odaklanmış': Color(0xFF8D99AE), // Lacivert Grisi
    'Düşünceli': Color(0xFFB0A8B9),  // Yumuşak Mor Gri
    'Heyecanlı': Color(0xFFEF476F),  // Canlı Kırmızımsı Pembe
    'Stresli': Color(0xFFE07A5F),    // Soluk Mercan
    'Yorgun': Color(0xFF8D99AE),     // Soğuk Gri
    'Hüzünlü': Color(0xFF6B7FD7),   // Yumuşak İndigo
  };

  static Color getColor(String? mood) {
    if (mood == null || mood.isEmpty) return const Color(0xFF8D99AE);
    final cleanMood = mood.split(' ').first;
    return colors[cleanMood] ?? const Color(0xFF5A67D8);
  }
}
