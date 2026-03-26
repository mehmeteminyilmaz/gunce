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
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box('profile').listenable(),
          builder: (context, Box box, child) {
            final name = box.get('name', defaultValue: 'Gezgin');
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil Başlığı (sabit kalır)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, anim, anim2) => const ProfileScreen(),
                            transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                          ));
                        },
                        child: Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                blurRadius: 15, offset: const Offset(0, 5),
                              )
                            ]
                          ),
                          child: Center(
                            child: Icon(Icons.person_outline_rounded,
                              color: Theme.of(context).colorScheme.primary, size: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Merhaba,',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        )),
                      
                      ValueListenableBuilder(
                        valueListenable: Hive.box<Entry>('entries').listenable(),
                        builder: (context, Box<Entry> entriesBox, child) {
                          final streak = StreakCalculator.calculate(entriesBox.values.toList());
                          return Row(
                            children: [
                              Text(name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                )),
                              if (streak > 0) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).colorScheme.secondary)
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('🔥', style: TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text('$streak', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFF7B42))),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
                
                Divider(color: Theme.of(context).dividerColor, height: 1, indent: 32, endIndent: 32),
                const SizedBox(height: 8),
                
                // Menü Öğeleri — Scroll edilebilir (overflow'u önler)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: Icons.person_rounded,
                          title: 'Profilim',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const ProfileScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: Icons.auto_awesome_rounded,
                          title: 'Günce ile Sohbet',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const ChatScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),

                        _buildMenuItem(
                          context: context,
                          icon: Icons.map_outlined,
                          title: 'Anı Haritası',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const MapScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: Icons.park_rounded,
                          title: 'Hafıza Bahçem',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const ZenGardenScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),

                        _buildMenuItem(
                          context: context,
                          icon: Icons.bar_chart_rounded,
                          title: 'İstatistikler & Analiz',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const StatsScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: Icons.palette_outlined,
                          title: 'Huzur Temaları',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const ThemesScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          title: 'Ayarlar',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, anim, anim2) => const SettingsScreen(),
                              transitionsBuilder: (context, anim, anim2, child) => FadeTransition(opacity: anim, child: child),
                            ));
                          },
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // Sürüm numarası — altta sabit
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                  child: Text('Günce v3.5',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    )),
                )
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildMenuItem({required BuildContext context, required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 20),
            Text(title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          ],
        ),
      ),
    );
  }
}
