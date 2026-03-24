import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: entriesWithLocation.isNotEmpty
                      ? LatLng(entriesWithLocation.first.latitude!, entriesWithLocation.first.longitude!)
                      : LatLng(39.9334, 32.8597), // Ankara fallback
                  initialZoom: 5.0,
                  onTap: (_, __) => setState(() => _selectedEntry = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    tileBuilder: (context, tileWidget, tile) {
                      // Koyu mod için haritayı biraz karartalım (Premium hissi)
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return ColorFiltered(
                        colorFilter: ColorFilter.matrix(isDark ? [
                          -0.21, -0.72, -0.07, 0, 255,
                          -0.21, -0.72, -0.07, 0, 255,
                          -0.21, -0.72, -0.07, 0, 255,
                          0, 0, 0, 1, 0,
                        ] : [
                          1, 0, 0, 0, 0,
                          0, 1, 0, 0, 0,
                          0, 0, 1, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: tileWidget,
                      );
                    },
                  ),
                  MarkerLayer(
                    markers: entriesWithLocation.map((entry) {
                      return Marker(
                        point: LatLng(entry.latitude!, entry.longitude!),
                        width: 60,
                        height: 60,
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

          // Üst Panel (Geri Butonu ve Başlık)
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                    ]
                  ),
                  child: Text('Anı Haritası',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                ),
              ],
            ),
          ),

          // Seçili Anı Kartı (Preview)
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
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
                                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF5A67D8), fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_selectedEntry!.text,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF5A67D8)),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow etkisi
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MoodColors.getColor(entry.mood).withOpacity(0.3),
          ),
        ),
        // Ana Pin
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MoodColors.getColor(entry.mood),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)
            ]
          ),
          child: Center(
            child: Icon(
              entry.audioPath != null ? Icons.mic_rounded : Icons.camera_alt_rounded,
              size: 10, color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ]
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
      ),
    );
  }
}
