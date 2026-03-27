import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../utils/mood_colors.dart';
import 'detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Entry? _selectedEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: Hive.box<Entry>('entries').listenable(),
            builder: (context, Box<Entry> box, _) {
              final entriesWithLocation = box.values
                  .where((e) => e.latitude != null && e.longitude != null)
                  .toList();
              
              // Tarihe göre sıralayalım (En yeni en sonda kalsın ki markerlar üst üste ise en yeni üstte görünsün)
              entriesWithLocation.sort((a, b) => a.date.compareTo(b.date));

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: entriesWithLocation.isNotEmpty
                      ? LatLng(entriesWithLocation.last.latitude!, entriesWithLocation.last.longitude!)
                      : LatLng(39.1, 35.4), // Ankara fallback/Turkey center
                  initialZoom: 5.0,
                  onTap: (_, __) => setState(() => _selectedEntry = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    tileBuilder: (context, tileWidget, tile) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      if (!isDark) return tileWidget;
                      
                      // v4.3 Asil Gece (Deep Night) Matrisi
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -0.1, -0.6, -0.1, 0, 255, // Kanalları daha asil tonlarla dengeler
                          -0.1, -0.6, -0.1, 0, 255,
                          -0.1, -0.4, -0.1, 0, 255,
                          0, 0, 0, 1, 0,
                        ]),
                        child: ColorFiltered(
                          // Derin Gece Mavisi Katmanı
                          colorFilter: ColorFilter.mode(
                            const Color(0xFF0F172A).withOpacity(0.6), 
                            BlendMode.screen
                          ),
                          child: tileWidget,
                        ),
                      );
                    },
                  ),
                  MarkerLayer(
                    markers: entriesWithLocation.map((entry) {
                      return Marker(
                        point: LatLng(entry.latitude!, entry.longitude!),
                        width: 70, // Biraz genişletildi
                        height: 70,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedEntry = entry),
                          child: _buildMarker(entry),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),

          // Üst Panel (v4.3 Karanlık Mod İyileştirmesi)
          Positioned(
            top: 64, left: 24,
            child: Row(
              children: [
                _buildRoundButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                    ]
                  ),
                  child: Text('Anı Haritası',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Theme.of(context).colorScheme.onSurface)),
                ),
              ],
            ),
          ),

          // Seçili Anı Kartı (v4.3 Karanlık Mod İyileştirmesi)
          if (_selectedEntry != null)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DetailScreen(entry: _selectedEntry!),
                  ));
                },
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))
                    ]
                  ),
                  child: Row(
                    children: [
                      if (_selectedEntry!.imagePath != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                          child: Container(
                            width: 120,
                            height: 120,
                            child: kIsWeb
                                ? Image.network(_selectedEntry!.imagePath!, fit: BoxFit.cover)
                                : Image.file(File(_selectedEntry!.imagePath!), fit: BoxFit.cover),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_selectedEntry!.locationName ?? 'Bilinmeyen Konum',
                                style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                              Text(DateFormat('dd MMMM yyyy', 'tr').format(_selectedEntry!.date),
                                style: GoogleFonts.outfit(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                              const SizedBox(height: 4),
                              Text(_selectedEntry!.text,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9))),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarker(Entry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final moodColor = MoodColors.getColor(entry.mood);

    return Stack(
      alignment: Alignment.center,
      children: [
        // v4.3 Güçlendirilmiş Glow Etkisi
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                moodColor.withOpacity(isDark ? 0.6 : 0.4),
                moodColor.withOpacity(0.0),
              ],
            ),
          ),
        ),
        // Ana Pin (v4.3 Contrast Fix)
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: moodColor,
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.9) : Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.2), 
                blurRadius: 8, 
                offset: const Offset(0, 2)
              )
            ]
          ),
          child: Center(
            child: Icon(
              entry.audioPath != null ? Icons.mic_rounded : Icons.camera_alt_rounded,
              size: 12, color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), 
              blurRadius: 15, 
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
      ),
    );
  }
}
