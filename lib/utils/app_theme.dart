import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulamanın gündüz (Açık) ve gece (Karanlık) temalarını tanımlar.
class AppTheme {
  // ─── ORTAK RENKLER ───────────────────────────────────────────────
  static const Color indigoPrimary = Color(0xFF5A67D8);
  static const Color lavenderAccent = Color(0xFF9F7AEA);

  // ─── GÜNDÜZ TEMASI ───────────────────────────────────────────────
  static ThemeData get light => ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF7FAFC),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    colorScheme: const ColorScheme.light().copyWith(
      primary: indigoPrimary,
      secondary: lavenderAccent,
      surface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFF4F1EA),
      onSurface: Color(0xFF1A202C),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A202C)),
      titleTextStyle: TextStyle(color: Color(0xFF1A202C), fontSize: 18),
    ),
  );

  // ─── GECE TEMASI (Gece Mavisi & Lavanta Premium Dark) ────────────
  static ThemeData get dark => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0F1117),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: indigoPrimary,
      secondary: lavenderAccent,
      surface: Color(0xFF1A1D2E),
      surfaceContainerHighest: Color(0xFF242840),
      onSurface: Color(0xFFE8EAF6),
    ),
    cardColor: const Color(0xFF1A1D2E),
    dividerColor: const Color(0xFF2D3257),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFE8EAF6)),
      titleTextStyle: TextStyle(color: Color(0xFFE8EAF6), fontSize: 18),
    ),
  );

  // ─── ZAMAN TABANLI OTO-SEÇICI ────────────────────────────────────
  /// 06:00 – 20:59 → Gündüz (Açık)  |  21:00 – 05:59 → Gece (Karanlık)
  static ThemeData get autoByTime {
    final hour = DateTime.now().hour;
    final isNight = hour >= 21 || hour < 6;
    return isNight ? dark : light;
  }

  static bool get isNightNow {
    final hour = DateTime.now().hour;
    return hour >= 21 || hour < 6;
  }
}
