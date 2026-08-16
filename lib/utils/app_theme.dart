import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ZenThemeType { lavender, nature, evening, blossom, desert }

class AppTheme {
  // --- RENK TOKENLARI ---
  // Açık mod: kağıt & mürekkep
  static const Color _lightBg     = Color(0xFFF5F0E8);
  static const Color _lightSurface = Color(0xFFEFEBE0);
  static const Color _lightText   = Color(0xFF1C1C1E);
  static const Color _lightSub    = Color(0xFF8C7A62);
  static const Color _lightDiv    = Color(0xFFD4C5A9);

  // Koyu mod: gece mürekkebi
  static const Color _darkBg      = Color(0xFF151210);
  static const Color _darkSurface = Color(0xFF1F1A16);
  static const Color _darkText    = Color(0xFFF0E6D3);
  static const Color _darkDiv     = Color(0xFF2E2820);

  static final Map<ZenThemeType, Map<String, dynamic>> themes = {
    ZenThemeType.lavender: {
      'primary'  : const Color(0xFF3D3580),
      'secondary': const Color(0xFF8B4513),
      'accent'   : const Color(0xFF6B5B95),
      'name'     : 'Mürekkep & Kağıt',
    },
    ZenThemeType.nature: {
      'primary'  : const Color(0xFF2D5016),
      'secondary': const Color(0xFF5C7A3E),
      'accent'   : const Color(0xFF4A7C59),
      'name'     : 'Orman Sayfası',
    },
    ZenThemeType.evening: {
      'primary'  : const Color(0xFF1B3A5C),
      'secondary': const Color(0xFF2E6DA4),
      'accent'   : const Color(0xFF34568B),
      'name'     : 'Deniz Mavisi',
    },
    ZenThemeType.blossom: {
      'primary'  : const Color(0xFF7B2D4E),
      'secondary': const Color(0xFFA0415A),
      'accent'   : const Color(0xFF8B4560),
      'name'     : 'Gül Kırmızısı',
    },
    ZenThemeType.desert: {
      'primary'  : const Color(0xFF7A3B1E),
      'secondary': const Color(0xFFA0522D),
      'accent'   : const Color(0xFFC8956C),
      'name'     : 'Toprak Tonu',
    },
  };

  static ThemeData getTheme(ZenThemeType type, bool isDarkMode) {
    final colors = themes[type]!;
    final primary   = colors['primary'] as Color;
    final secondary = colors['secondary'] as Color;

    final bg      = isDarkMode ? _darkBg : _lightBg;
    final surface = isDarkMode ? _darkSurface : _lightSurface;
    final onSurf  = isDarkMode ? _darkText : _lightText;
    final divider = isDarkMode ? _darkDiv : _lightDiv;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness:  isDarkMode ? Brightness.dark : Brightness.light,
        primary:     primary,
        onPrimary:   isDarkMode ? _darkText : Colors.white,
        secondary:   secondary,
        onSecondary: Colors.white,
        surface:     surface,
        onSurface:   onSurf,
        error:       const Color(0xFFB00020),
        onError:     Colors.white,
      ),
      scaffoldBackgroundColor: bg,

      // AppBar — tamamen şeffaf, düz
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurf,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurf, size: 22),
      ),

      // Text Theme
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(color: onSurf),
        displayMedium: GoogleFonts.playfairDisplay(color: onSurf),
        headlineLarge: GoogleFonts.playfairDisplay(color: onSurf, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.playfairDisplay(color: onSurf, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.outfit(color: onSurf, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: onSurf, fontSize: 14),
        bodySmall: GoogleFonts.outfit(color: isDarkMode ? _darkText.withAlpha(153) : _lightSub, fontSize: 12),
      ),

      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),

      // Drawer
      drawerTheme: DrawerThemeData(backgroundColor: bg),

      // Elevated Button — düz, gradient yok
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDarkMode ? _darkText : Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.3),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        hintStyle: GoogleFonts.outfit(
          color: isDarkMode ? _darkText.withAlpha(102) : _lightSub,
          fontSize: 15,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
