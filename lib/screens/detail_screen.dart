import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

class DetailScreen extends StatefulWidget {
  final Entry entry;
  const DetailScreen({super.key, required this.entry});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (widget.entry.audioPath != null) {
        // Web'de veya blob URL geliyorsa UrlSource kullanılır
        final source = (kIsWeb || widget.entry.audioPath!.startsWith('blob:'))
            ? UrlSource(widget.entry.audioPath!)
            : DeviceFileSource(widget.entry.audioPath!);
        await _audioPlayer.play(source);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy', 'tr').format(widget.entry.date);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            expandedHeight: widget.entry.imagePath != null ? 400.0 : 100.0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ]
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Theme.of(context).colorScheme.onSurface, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.entry.imagePath != null
                ? Hero(
                    tag: 'image_${widget.entry.id}',
                    child: kIsWeb
                        ? Image.network(widget.entry.imagePath!, fit: BoxFit.cover)
                        : Image.file(File(widget.entry.imagePath!), fit: BoxFit.cover),
                  )
                : const SizedBox(),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr,
                        style: GoogleFonts.outfit(
                          fontSize: 14, letterSpacing: 2, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      if (widget.entry.mood != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Text(widget.entry.mood!.toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1, color: const Color(0xFF5A67D8), fontWeight: FontWeight.w600)),
                        )
                    ],
                  ),
                  
                  if (widget.entry.locationName != null && widget.entry.locationName!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF9F7AEA), size: 16),
                        const SizedBox(width: 8),
                        Text(widget.entry.locationName!,
                          style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  Text('"${widget.entry.text}"',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      height: 1.8,
                    )),

                  if (widget.entry.audioPath != null) ...[
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).dividerColor),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF5A67D8).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                        ]
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _togglePlayback,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5A67D8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sesli Anı',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: _duration.inMilliseconds > 0 
                                      ? _position.inMilliseconds / _duration.inMilliseconds 
                                      : 0.0,
                                  backgroundColor: const Color(0xFF5A67D8).withOpacity(0.1),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5A67D8)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                    
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}