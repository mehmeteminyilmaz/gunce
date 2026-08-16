import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../utils/mood_colors.dart';
import 'add_screen.dart';

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

  Future<void> _deleteEntry() async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        backgroundColor: theme.colorScheme.surface,
        title: Text('Anıyı Sil',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text('Bu anıyı silmek istediğinizden emin misiniz?',
          style: GoogleFonts.outfit(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Vazgeç',
              style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sil',
              style: GoogleFonts.outfit(
                color: Colors.red.shade700, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.entry.delete();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _editEntry() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScreen(entryToEdit: widget.entry),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (widget.entry.audioPath != null) {
        final source = (kIsWeb || widget.entry.audioPath!.startsWith('blob:'))
            ? UrlSource(widget.entry.audioPath!)
            : DeviceFileSource(widget.entry.audioPath!);
        await _audioPlayer.play(source);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            expandedHeight: widget.entry.imagePath != null ? 320.0 : 0.0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: widget.entry.imagePath != null
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  size: 16),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    color: widget.entry.imagePath != null
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    size: 18),
                onPressed: _editEntry,
                tooltip: 'Düzenle',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: widget.entry.imagePath != null
                        ? Colors.white70
                        : Colors.red.shade400,
                    size: 18),
                onPressed: _deleteEntry,
                tooltip: 'Sil',
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: widget.entry.imagePath != null
                ? FlexibleSpaceBar(
                    background: Hero(
                      tag: 'image_${widget.entry.id}',
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          kIsWeb
                              ? Image.network(widget.entry.imagePath!,
                                  fit: BoxFit.cover)
                              : Image.file(File(widget.entry.imagePath!),
                                  fit: BoxFit.cover),
                          // Koyu gradyan overlay (sadece burada — metin okuma için)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withAlpha(120),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarih + ruh hali
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d MMMM', 'tr').format(widget.entry.date),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy, EEEE', 'tr').format(widget.entry.date),
                            style: GoogleFonts.outfit(
                              fontSize: 13, color: sub),
                          ),
                        ],
                      ),
                      if (widget.entry.mood != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: MoodColors.getColor(widget.entry.mood)
                                  .withAlpha(150),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            widget.entry.mood!.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: MoodColors.getColor(widget.entry.mood),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Konum
                  if (widget.entry.locationName != null &&
                      widget.entry.locationName!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: sub, size: 14),
                        const SizedBox(width: 6),
                        Text(widget.entry.locationName!,
                          style: GoogleFonts.outfit(
                              fontSize: 13, color: sub)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),
                  Divider(color: theme.dividerColor, thickness: 1),
                  const SizedBox(height: 32),

                  // Anı metni
                  Text(
                    widget.entry.text,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                      height: 1.9,
                    ),
                  ),

                  // Sesli anı
                  if (widget.entry.audioPath != null) ...[
                    const SizedBox(height: 40),
                    Divider(color: theme.dividerColor, thickness: 1),
                    const SizedBox(height: 20),
                    Text('SESLİ ANI',
                      style: GoogleFonts.outfit(
                        fontSize: 10, letterSpacing: 2,
                        fontWeight: FontWeight.w700, color: sub)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.dividerColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _togglePlayback,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Oynat',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: _duration.inMilliseconds > 0
                                      ? _position.inMilliseconds /
                                          _duration.inMilliseconds
                                      : 0.0,
                                  backgroundColor:
                                      theme.dividerColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary),
                                  borderRadius: BorderRadius.circular(2),
                                  minHeight: 2,
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