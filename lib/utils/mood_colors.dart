import 'package:flutter/material.dart';

class MoodColors {
  static const Map<String, Color> colors = {
    'Harika': Color(0xFFFFB38E), // Şeftali
    'Mutlu': Color(0xFFFFD166), // Sıcak Sarı
    'Huzurlu': Color(0xFFA5C29F), // Açık Adaçayı
    'Sakin': Color(0xFF7D9B76), // Adaçayı
    'Odaklanmış': Color(0xFF4F5D75), // Lacivert Grisi
    'Düşünceli': Color(0xFFB0A8B9), // Yumuşak Mor Gri
    'Heyecanlı': Color(0xFFEF476F), // Parlak Canlı Kırmızımsı Pembe
    'Stresli': Color(0xFFE07A5F), // Soluk Mercan Kırmızısı
    'Yorgun': Color(0xFF8D99AE), // Soğuk Gri
    'Hüzünlü': Color(0xFF6B7FD7), // Yumuşak İndigo
  };

  static Color getColor(String? mood) {
    if (mood == null || mood.isEmpty) return const Color(0xFFE8E4D9);
    
    // Geçmişteki (eski) emoji kalıntılarını temizle 
    final cleanMood = mood.split(' ').first;
    return colors[cleanMood] ?? const Color(0xFF7D9B76);
  }
}
