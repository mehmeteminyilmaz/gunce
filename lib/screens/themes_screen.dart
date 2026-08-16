import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_theme.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final profileBox = Hive.box('profile');

    return Scaffold(
      appBar: AppBar(
        title: Text('Temalar',
          style: theme.appBarTheme.titleTextStyle),
      ),
      body: ValueListenableBuilder(
        valueListenable: profileBox.listenable(keys: ['zenThemeIndex']),
        builder: (context, Box box, _) {
          final currentIndex = box.get('zenThemeIndex', defaultValue: 0);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            itemCount: ZenThemeType.values.length,
            itemBuilder: (context, index) {
              final type = ZenThemeType.values[index];
              final colors = AppTheme.themes[type]!;
              final isSelected = currentIndex == index;
              final primary = colors['primary'] as Color;
              final secondary = colors['secondary'] as Color;
              final name = colors['name'] as String;

              return GestureDetector(
                onTap: () => box.put('zenThemeIndex', index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? primary : theme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Renk önizleme
                      Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: secondary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              )),
                            Text(
                              isSelected ? 'Şu an aktif' : 'Seçmek için dokun',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: sub,
                              )),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, color: primary, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
