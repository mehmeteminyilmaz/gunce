import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../utils/streak_calculator.dart';
import '../utils/mood_colors.dart';

class ZenGardenScreen extends StatefulWidget {
  const ZenGardenScreen({super.key});

  @override
  State<ZenGardenScreen> createState() => _ZenGardenScreenState();
}

class _ZenGardenScreenState extends State<ZenGardenScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Hafıza Bahçem', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Entry>('entries').listenable(),
        builder: (context, Box<Entry> box, _) {
          final entries = box.values.toList();
          final streak = StreakCalculator.calculate(entries);
          final entryCount = entries.length;
          
          // En baskın mod rengini buluyoruz (Yapraklar için)
          String dominantMood = _getDominantMood(entries);
          Color leafColor = MoodColors.getColor(dominantMood);
          if (dominantMood == 'Bilinmiyor') leafColor = theme.colorScheme.primary;

          // Ağaç Seviyesi Hesaplama
          double growth = (entryCount * 0.1) + (streak * 0.15);
          if (growth > 1.0) growth = 1.0; // Maksimum büyüme sınırı (şimdilik)
          if (entryCount == 0) growth = 0.05; // Hiç anı yoksa sadece küçük bir filiz

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildGardenStats(entryCount, streak, dominantMood),
                const Spacer(),
                
                // Dinamik Ağaç
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(300, 400),
                          painter: TreePainter(
                            growth: growth * _controller.value,
                            primaryColor: theme.colorScheme.primary,
                            leafColor: leafColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    _getGardenMessage(growth, streak),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDominantMood(List<Entry> entries) {
    if (entries.isEmpty) return 'Bilinmiyor';
    Map<String, int> counts = {};
    for (var e in entries) {
      if (e.mood != null) counts[e.mood!] = (counts[e.mood!] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'Bilinmiyor';
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getGardenMessage(double growth, int streak) {
    if (growth < 0.2) return "Her büyük ağaç küçük bir tohumla başlar. İlk anını ekmek için harika bir gün.";
    if (streak > 7) return "Harikasın! Devamlılığın sayesinde fidanın kökleri çok derinlere iniyor.";
    return "Anılarınla suladığın bu ağaç, seninle beraber büyüyor. Yazmaya devam et.";
  }

  Widget _buildGardenStats(int count, int streak, String mood) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Toplam Anı", count.toString(), Icons.book_rounded, theme.colorScheme.primary),
          _statItem("Seri", "$streak Gün", Icons.local_fire_department_rounded, Colors.orange),
          _statItem("Ruhun", mood.split(' ').first, Icons.wb_sunny_rounded, MoodColors.getColor(mood)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class TreePainter extends CustomPainter {
  final double growth;
  final Color primaryColor;
  final Color leafColor;

  TreePainter({required this.growth, required this.primaryColor, required this.leafColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = leafColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Kökleri çiziyoruz
    final start = Offset(size.width / 2, size.height);
    final end = Offset(size.width / 2, size.height - (120 * growth + 30));
    
    // Gövde
    canvas.drawLine(start, end, paint..strokeWidth = 12 * growth + 4);

    if (growth > 0.15) {
      _drawBranch(canvas, end, -pi / 4, 80 * growth, 8.0 * growth, paint, leafPaint);
      _drawBranch(canvas, end, pi / 4, 70 * growth, 7.0 * growth, paint, leafPaint);
    }
  }

  void _drawBranch(Canvas canvas, Offset start, double angle, double length, double width, Paint paint, Paint leafPaint) {
    if (length < 10) {
      // Yaprakları çiziyoruz
      canvas.drawCircle(start, 8 * (growth + 0.5), leafPaint);
      return;
    }

    final end = Offset(
      start.dx + cos(angle - pi / 2) * length,
      start.dy + sin(angle - pi / 2) * length,
    );

    canvas.drawLine(start, end, paint..strokeWidth = width);

    // Yeni dallar
    _drawBranch(canvas, end, angle - 0.4, length * 0.7, width * 0.7, paint, leafPaint);
    _drawBranch(canvas, end, angle + 0.35, length * 0.6, width * 0.7, paint, leafPaint);
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.growth != growth || oldDelegate.leafColor != leafColor;
  }
}
