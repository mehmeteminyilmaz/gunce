import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../widgets/side_menu.dart';
import '../utils/quotes.dart';
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

  @override
  void initState() {
    super.initState();
    _currentQuote = Quotes.getRandomQuote();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi Geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'Keyifli Günler';
    if (hour < 22) return 'İyi Akşamlar';
    return 'Huzurlu Geceler';
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
    return _entryForDay(box,
      DateTime(today.year - 1, today.month, today.day));
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFDFBF7), // Krem zemin
      drawer: const SideMenu(),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Entry>('entries').listenable(),
        builder: (context, Box<Entry> box, _) {
          final entries = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
          final lastYear = _lastYearEntry(box);
          final todayEntry = _entryForDay(box, DateTime.now());

          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Minimalist App Bar (Light Theme)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE8E4D9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10, offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: const Icon(Icons.sort_rounded, color: Color(0xFF2D3142), size: 20),
                          ),
                        ),
                        Text(_getGreeting().toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: const Color(0xFF7D9B76), // Adaçayı
                          )),
                        Container(width: 44), // Sağ boşluk
                      ],
                    ),
                  ),
                ),

                // Günlük Motivasyon Sözü
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
                    child: Text('"$_currentQuote"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF8E8E93),
                        height: 1.5,
                      )),
                  ),
                ),

                // Flashback Panosu
                if (lastYear != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, _createRoute(DetailScreen(entry: lastYear))),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            image: lastYear.imagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(lastYear.imagePath!)),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                                  )
                                : null,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7D9B76).withOpacity(0.15),
                                  blurRadius: 20, offset: const Offset(0, 10),
                                )
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.history_edu_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('GEÇEN YIL BUGÜN',
                                    style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('"${lastYear.text}"',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bugün Butonu
                if (todayEntry == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: InkWell(
                        onTap: () => Navigator.push(context, _createRoute(const AddScreen())),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7D9B76), // Ana Renk
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7D9B76).withOpacity(0.3),
                                blurRadius: 15, offset: const Offset(0, 8),
                              )
                            ]
                          ),
                          child: Center(
                            child: Text('Bugünü Kaydet',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Timeline Başlığı
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Text('Zaman Tüneli',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3142),
                      )),
                  ),
                ),

                // Timeline Listesi
                entries.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text('İlk sayfayı aralamalısın...',
                            style: GoogleFonts.outfit(color: const Color(0xFF8E8E93), fontSize: 16)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = entries[index];
                          return _buildTimelineItem(context, entry);
                        },
                        childCount: entries.length,
                      ),
                    ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Alt boşluk
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Entry entry) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _createRoute(DetailScreen(entry: entry))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol Tarih Kısmı (Light Theme)
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text('${entry.date.day}',
                    style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142))),
                  Text(DateFormat('MMM', 'tr').format(entry.date).toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500, color: const Color(0xFF7D9B76))),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Beyaz Ferah Kart
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15, offset: const Offset(0, 8),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.imagePath != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.file(
                          File(entry.imagePath!),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.mood != null || entry.locationName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  if (entry.mood != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDFBF7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE8E4D9))
                                      ),
                                      child: Text(entry.mood!.toUpperCase(),
                                        style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1, color: const Color(0xFF7D9B76), fontWeight: FontWeight.w500)),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (entry.locationName != null && entry.locationName!.isNotEmpty) ...[
                                    Icon(Icons.location_on_rounded, size: 12, color: const Color(0xFFFFB38E)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(entry.locationName!,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF8E8E93))),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          Text(entry.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: const Color(0xFF4F5D75),
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}