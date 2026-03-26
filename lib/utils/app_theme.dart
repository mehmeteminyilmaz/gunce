import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ZenThemeType { lavender, nature, evening, blossom, desert }

class AppTheme {
  // --- TEMA PALETLERİ ---
  static final Map<ZenThemeType, Map<String, dynamic>> themes = {
    ZenThemeType.lavender: {
      'primary': const Color(0xFF5A67D8),
      'secondary': const Color(0xFF9F7AEA),
      'surface': const Color(0xFFF7FAFC),
      'name': 'Lavanta Sakinliği',
    },
    ZenThemeType.nature: {
      'primary': const Color(0xFF48BB78),
      'secondary': const Color(0xFF38A169),
      'surface': const Color(0xFFF0FFF4),
      'name': 'Doğa Huzuru',
    },
    ZenThemeType.evening: {
      'primary': const Color(0xFF2C5282),
      'secondary': const Color(0xFF2B6CB0),
      'surface': const Color(0xFFEBF8FF),
      'name': 'Gece Mavisi',
    },
    ZenThemeType.blossom: {
      'primary': const Color(0xFFED64A6),
      'secondary': const Color(0xFFD53F8C),
      'surface': const Color(0xFFFFF5F7),
      'name': 'Gül Yaprağı',
    },
    ZenThemeType.desert: {
      'primary': const Color(0xFFED8936),
      'secondary': const Color(0xFFDD6B20),
      'surface': const Color(0xFFFFFAF0),
      'name': 'Sıcak Kumlar',
    },
  };

  static ThemeData getTheme(ZenThemeType type, bool isDarkMode) {
    final colors = themes[type]!;
    final primary = colors['primary'] as Color;
    final secondary = colors['secondary'] as Color;
    final surface = isDarkMode ? const Color(0xFF171923) : colors['surface'] as Color;
    final scaffoldBg = isDarkMode ? const Color(0xFF0A0B10) : colors['surface'] as Color;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: isDarkMode ? Colors.white : const Color(0xFF2D3748),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF2D3748),
        displayColor: isDarkMode ? Colors.white : const Color(0xFF1A202C),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1A202C)),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : const Color(0xFF1A202C)),
      ),
      dividerColor: isDarkMode ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
    );
  }
}
