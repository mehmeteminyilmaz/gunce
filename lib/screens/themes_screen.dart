import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_theme.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box('profile');

    return Scaffold(
      appBar: AppBar(
        title: Text('Huzur Temaları', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder(
        valueListenable: profileBox.listenable(keys: ['zenThemeIndex']),
        builder: (context, Box box, _) {
          final currentIndex = box.get('zenThemeIndex', defaultValue: 0);

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: ZenThemeType.values.length,
            itemBuilder: (context, index) {
              final type = ZenThemeType.values[index];
              final colors = AppTheme.themes[type]!;
              final isSelected = currentIndex == index;

              return _buildThemeCard(
                context,
                title: colors['name'],
                primary: colors['primary'],
                secondary: colors['secondary'],
                surface: colors['surface'],
                isSelected: isSelected,
                onTap: () {
                  box.put('zenThemeIndex', index);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required Color primary,
    required Color secondary,
    required Color surface,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primary : Theme.of(context).dividerColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))
          ] : null,
        ),
        child: Row(
          children: [
            // Renk Önizleme Daireleri
            Stack(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    width: 25, height: 25, 
                    decoration: BoxDecoration(color: secondary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  Text(isSelected ? 'Şu an aktif' : 'Seçmek için dokun', 
                    style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primary, size: 28),
          ],
        ),
      ),
    );
  }
}
