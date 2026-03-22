import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../utils/streak_calculator.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box('profile').listenable(),
          builder: (context, Box box, _) {
            final name = box.get('name', defaultValue: 'Gezgin');
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ProfileScreen(),
                            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                          ));
                        },
                        child: Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: const Color(0xFF5A67D8), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5A67D8).withOpacity(0.15),
                                blurRadius: 15, offset: const Offset(0, 5),
                              )
                            ]
                          ),
                          child: const Center(
                            child: Icon(Icons.person_outline_rounded,
                              color: Color(0xFF5A67D8), size: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Merhaba,',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: const Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        )),
                      
                      // İsim ve Streak Rozeti
                      ValueListenableBuilder(
                        valueListenable: Hive.box<Entry>('entries').listenable(),
                        builder: (context, Box<Entry> entriesBox, _) {
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
                                    color: const Color(0xFFFFEFE9), // Uçuk turuncu
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF9F7AEA))
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
                
                const Divider(color: Theme.of(context).dividerColor, height: 1, indent: 32, endIndent: 32),
                const SizedBox(height: 24),
                
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: 'Profilim',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ProfileScreen(),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                    ));
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.auto_awesome_rounded,
                  title: 'İstatistikler & Analiz',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const StatsScreen(),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                    ));
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Ayarlar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const SettingsScreen(),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                    ));
                  },
                ),
                
                const Spacer(),
                
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('Günce v3.0 Soft',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFFB0B0B0),
                    )),
                )
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF5A67D8).withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5A67D8), size: 22),
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
