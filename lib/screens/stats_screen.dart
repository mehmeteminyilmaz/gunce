import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../utils/mood_colors.dart';
import '../utils/streak_calculator.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Krem Zemin
      appBar: AppBar(
        title: Text('Analiz',
          style: GoogleFonts.outfit(
            fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 18),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                const SizedBox(height: 8),
                Text('Bugüne dek tuttuğun tüm kayıtlar.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  )),
                const SizedBox(height: 32),
                
                // Streak (Alev) Kartı
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A67D8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF5A67D8).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
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
                    Expanded(child: _buildStatCard(context, 'Toplam\nKayıt', totalEntries.toString(), Icons.book_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, 'Fotoğraflı\nAnı', photosCount.toString(), Icons.photo_camera_rounded)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Konum Kartı
                _buildHorizontalStatCard(context, 'Gezilen\nKonumlar', locationsCount.toString(), Icons.location_on_rounded, const Color(0xFF9F7AEA)),
                
                const SizedBox(height: 16),
                _buildMoodChart(context, moodCounts),
                
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 24),
          const SizedBox(height: 24),
          Text(value,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1,
            )),
          const SizedBox(height: 8),
          Text(title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              height: 1.3,
            )),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).dividerColor)),
                child: Icon(icon, color: iconColor, size: 20)
              ),
              const SizedBox(width: 16),
              Text(title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  height: 1.2,
                )),
            ],
          ),
          Text(value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            )),
        ],
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, Map<String, int> moodCounts) {
    if (moodCounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(Icons.auto_graph_rounded, color: Theme.of(context).dividerColor, size: 40),
            const SizedBox(height: 16),
            Text('Henüz yeterli veri yok', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      );
    }

    int maxCount = moodCounts.values.reduce((a, b) => a > b ? a : b);
    final sortedMoods = moodCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final displayMoods = sortedMoods.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).dividerColor)),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF5A67D8), size: 20)
              ),
              const SizedBox(width: 12),
              Text('Duygu Analizi',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1600),
              curve: Curves.elasticOut,
              builder: (context, value, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: displayMoods.map((e) {
                    final percentage = maxCount == 0 ? 0.0 : e.value / maxCount;
                    final barHeight = 90.0 * percentage * value;
                    final moodText = e.key;
                    
                    String textPart = moodText.split(' ').first;
                    final Color moodColor = MoodColors.getColor(moodText);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${e.value}', style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Container(
                          width: 32,
                          height: barHeight > 0 ? barHeight : 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [moodColor, moodColor.withOpacity(0.6)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: moodColor),
                        ),
                        const SizedBox(height: 8),
                        Text(textPart, style: GoogleFonts.outfit(fontSize: 10, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
