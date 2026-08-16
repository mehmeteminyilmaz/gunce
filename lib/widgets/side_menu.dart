import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../utils/streak_calculator.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/map_screen.dart';
import '../screens/themes_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/zen_garden_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box('profile').listenable(),
          builder: (context, Box box, child) {
            final name = box.get('name', defaultValue: 'Gezgin');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil başlığı
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) =>
                                  const ProfileScreen(),
                              transitionsBuilder: (context, anim, anim2, child) =>
                                  FadeTransition(opacity: anim, child: child),
                            ),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'G',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder(
                        valueListenable:
                            Hive.box<Entry>('entries').listenable(),
                        builder: (context, Box<Entry> entriesBox, child) {
                          final streak = StreakCalculator.calculate(
                              entriesBox.values.toList());
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                )),
                              if (streak > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('🔥',
                                        style: TextStyle(fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text('$streak günlük seri',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: sub,
                                      )),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Divider(color: theme.dividerColor, height: 1),

                // Menü öğeleri
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.person_outline_rounded,
                          title: 'Profilim',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const ProfileScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Günce ile Sohbet',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const ChatScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.map_outlined,
                          title: 'Anı Haritası',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const MapScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.park_outlined,
                          title: 'Hafıza Bahçem',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const ZenGardenScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.bar_chart_outlined,
                          title: 'İstatistikler',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const StatsScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.palette_outlined,
                          title: 'Temalar',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const ThemesScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          title: 'Ayarlar',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim, anim2) =>
                                    const SettingsScreen(),
                                transitionsBuilder:
                                    (context, anim, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Sürüm numarası
                Divider(color: theme.dividerColor, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
                  child: Text(
                    'günce.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      color: sub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: theme.colorScheme.primary.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: sub, size: 18),
            const SizedBox(width: 18),
            Text(title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              )),
          ],
        ),
      ),
    );
  }
}
