import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../utils/streak_calculator.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Krem Zemin
      appBar: AppBar(
        title: Text('Analiz',
          style: GoogleFonts.outfit(
            fontSize: 18, color: const Color(0xFF2D3142), fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Entry>('entries').listenable(),
        builder: (context, Box<Entry> box, _) {
          final entries = box.values.toList();
          final totalEntries = entries.length;
          final photosCount = entries.where((e) => e.imagePath != null).length;
          final locationsCount = entries.where((e) => e.locationName != null && e.locationName!.isNotEmpty).length;
          
          final Map<String, int> moodCounts = {};
          for (var e in entries) {
            final m = e.mood ?? 'Belirsiz';
            moodCounts[m] = (moodCounts[m] ?? 0) + 1;
          }
          String topMood = 'Yok';
          if (moodCounts.isNotEmpty) {
            topMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
          }

          final currentStreak = StreakCalculator.calculate(entries);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Günce Serüvenin',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3142),
                  )),
                const SizedBox(height: 8),
                Text('Bugüne dek tuttuğun tüm kayıtlar.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF8E8E93),
                  )),
                const SizedBox(height: 32),
                
                // Streak (Alev) Kartı
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3142),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2D3142).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Devam Serisi',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currentStreak.toString(),
                                style: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                              const SizedBox(width: 6),
                              Text('gün',
                                style: GoogleFonts.outfit(fontSize: 16, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stat Cards (Ferah)
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Toplam\nKayıt', totalEntries.toString(), Icons.book_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Fotoğraflı\nAnı', photosCount.toString(), Icons.photo_camera_rounded)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Konum Kartı
                _buildHorizontalStatCard('Gezilen\nKonumlar', locationsCount.toString(), Icons.location_on_rounded, const Color(0xFFFFB38E)),
                
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                    border: Border.all(color: const Color(0xFFE8E4D9)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mood_rounded, color: Color(0xFF7D9B76), size: 40),
                      const SizedBox(height: 20),
                      Text('Genel Ruh Hali',
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF8E8E93))),
                      const SizedBox(height: 8),
                      Text(topMood.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142))),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                Center(
                  child: Text('Anılar eklendikçe gelişecektir.',
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFB0B0B0))),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4D9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8E8E93), size: 24),
          const SizedBox(height: 24),
          Text(value,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2D3142),
              height: 1,
            )),
          const SizedBox(height: 8),
          Text(title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF8E8E93),
              height: 1.3,
            )),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4D9)),
        boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFDFBF7), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE8E4D9))),
                child: Icon(icon, color: iconColor, size: 20)
              ),
              const SizedBox(width: 16),
              Text(title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8E8E93),
                  height: 1.2,
                )),
            ],
          ),
          Text(value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2D3142),
            )),
        ],
      ),
    );
  }
}
