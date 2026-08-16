import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../widgets/side_menu.dart';
import '../utils/quotes.dart';
import '../utils/streak_calculator.dart';
import '../utils/mood_colors.dart';
import 'add_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _currentQuote;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentQuote = Quotes.getRandomQuote();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi Geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi Günler';
    if (hour < 22) return 'İyi Akşamlar';
    return 'İyi Geceler';
  }

  Entry? _entryForDay(Box<Entry> box, DateTime day) {
    try {
      return box.values.firstWhere((e) =>
        e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day);
    } catch (_) { return null; }
  }

  Entry? _lastYearEntry(Box<Entry> box) {
    final today = DateTime.now();
    return _entryForDay(box, DateTime(today.year - 1, today.month, today.day));
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const SideMenu(),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Entry>('entries').listenable(),
        builder: (context, Box<Entry> box, _) {
          final allEntries = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
          final currentStreak = StreakCalculator.calculate(allEntries);
          final lastYear = _lastYearEntry(box);
          final todayEntry = _entryForDay(box, DateTime.now());

          final entries = allEntries.where((entry) {
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            final textMatch = entry.text.toLowerCase().contains(query);
            final locMatch = entry.locationName?.toLowerCase().contains(query) ?? false;
            final moodMatch = entry.mood?.toLowerCase().contains(query) ?? false;
            return textMatch || locMatch || moodMatch;
          }).toList();

          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // --- TOPBAR ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: Icon(Icons.menu_rounded,
                              color: theme.colorScheme.onSurface, size: 22),
                        ),
                        if (currentStreak > 0)
                          Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak gün',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // --- BAŞLIK & SELAMLama ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMMM, EEEE', 'tr').format(DateTime.now()),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: sub,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- GÜNÜN SOZU ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '"$_currentQuote"',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: sub,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- BUGÜNÜ KAYDET / MÜHÜRLENDI ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: todayEntry == null
                        ? GestureDetector(
                            onTap: () => Navigator.push(context, _createRoute(const AddScreen())),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bugünü kaydet',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: theme.colorScheme.onPrimary, size: 18),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Icon(Icons.check_rounded,
                                  color: theme.colorScheme.primary, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Bugün mühürlendi.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // --- DIVIDER ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Divider(color: theme.dividerColor, thickness: 1),
                  ),
                ),

                // --- GEÇEN YIL BUGÜN ---
                if (lastYear != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context, _createRoute(DetailScreen(entry: lastYear))),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: theme.dividerColor, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GEÇEN YIL BUGÜN',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                  color: sub,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"${lastYear.text}"',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // --- ARAMA ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: GoogleFonts.outfit(
                            color: theme.colorScheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Anılarda ara...',
                          hintStyle: GoogleFonts.outfit(
                              color: sub, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: sub, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded, color: sub, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    FocusScope.of(context).unfocus();
                                  })
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- BAŞLIK ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Zaman Tüneli',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${allEntries.length} anı',
                          style: GoogleFonts.outfit(fontSize: 12, color: sub),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- LISTE ---
                entries.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Text(
                            'Henüz bir anı yok.\nİlk sayfayı aralamalısın...',
                            style: GoogleFonts.outfit(
                                color: sub, fontSize: 15, height: 1.6),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildTimelineItem(context, entries[index], index == entries.length - 1),
                          childCount: entries.length,
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
      // Flat FAB
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => Navigator.push(context, _createRoute(const AddScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded,
                    color: Theme.of(context).colorScheme.onPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Yeni Anı',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Entry entry, bool isLast) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol tarih sütunu
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '${entry.date.day}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'tr').format(entry.date).toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: sub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Zaman çizgisi
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1,
                        color: theme.dividerColor,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Kart
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, _createRoute(DetailScreen(entry: entry))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: isLast
                          ? BorderSide.none
                          : BorderSide(color: theme.dividerColor, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf
                      if (entry.imagePath != null) ...[
                        const SizedBox(height: 12),
                        Hero(
                          tag: 'image_${entry.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: kIsWeb
                                ? Image.network(entry.imagePath!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover)
                                : Image.file(File(entry.imagePath!),
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ],

                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Etiketler satırı
                            if (entry.mood != null ||
                                (entry.locationName != null &&
                                    entry.locationName!.isNotEmpty) ||
                                entry.audioPath != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    if (entry.mood != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: MoodColors.getColor(entry.mood)
                                                  .withAlpha(120),
                                              width: 1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          entry.mood!.toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w700,
                                            color: MoodColors.getColor(entry.mood),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    if (entry.locationName != null &&
                                        entry.locationName!.isNotEmpty) ...[
                                      Icon(Icons.location_on_outlined,
                                          size: 11, color: sub),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          entry.locationName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                              fontSize: 11, color: sub),
                                        ),
                                      ),
                                    ],
                                    if (entry.audioPath != null)
                                      Icon(Icons.mic_none_rounded,
                                          size: 13, color: sub),
                                  ],
                                ),
                              ),

                            // Anı metni
                            Text(
                              entry.text,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                              ),
                            ),

                            // İşlem menüsü
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      _createRoute(AddScreen(entryToEdit: entry))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      'Düzenle',
                                      style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: sub,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: theme.colorScheme.surface,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8)),
                                        title: Text('Anıyı sil',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        content: Text(
                                            'Bu anıyı silmek istediğinizden emin misiniz?',
                                            style: GoogleFonts.outfit(fontSize: 14)),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text('Vazgeç',
                                                style: GoogleFonts.outfit(
                                                    color: sub)),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text('Sil',
                                                style: GoogleFonts.outfit(
                                                    color: Colors.red.shade700,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await entry.delete();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      'Sil',
                                      style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: Colors.red.shade400,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}