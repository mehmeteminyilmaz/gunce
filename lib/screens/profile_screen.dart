import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../utils/streak_calculator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Box _profileBox = Hive.box('profile');
  late TextEditingController _nameController;
  bool _isEditing = false;
  String? _profilePhoto;
  late DateTime _joinDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileBox.get('name', defaultValue: 'Gezgin'));
    _profilePhoto = _profileBox.get('profile_photo');
    
    // Katılım tarihi yoksa bugünü kaydet
    final savedJoin = _profileBox.get('join_date');
    if (savedJoin != null) {
      _joinDate = DateTime.tryParse(savedJoin) ?? DateTime.now();
    } else {
      _joinDate = DateTime.now();
      _profileBox.put('join_date', _joinDate.toIso8601String());
    }
  }

  Future<void> _saveName() async {
    final text = _nameController.text.trim();
    if (text.isNotEmpty) {
      await _profileBox.put('name', text);
    }
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _pickProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Profil Fotoğrafını Değiştir',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt_rounded, 'Kamera', ImageSource.camera),
                _buildSourceOption(Icons.photo_library_rounded, 'Galeri', ImageSource.gallery),
                if (_profilePhoto != null)
                  _buildRemoveOption(),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: source, imageQuality: 85);
        if (picked != null) {
          await _profileBox.put('profile_photo', picked.path);
          setState(() {
            _profilePhoto = picked.path;
          });
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveOption() {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await _profileBox.delete('profile_photo');
        setState(() {
          _profilePhoto = null;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Kaldır',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final joinDateStr = DateFormat('d MMMM yyyy', 'tr').format(_joinDate);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profilim', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: theme.colorScheme.onSurface),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Entry>('entries').listenable(),
        builder: (context, Box<Entry> box, _) {
          final entries = box.values.toList();
          final totalEntries = entries.length;
          final currentStreak = StreakCalculator.calculate(entries);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // Profil Fotoğrafı ve Düzenle İkonu
                Center(
                  child: GestureDetector(
                    onTap: _pickProfilePhoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surface,
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: _profilePhoto != null
                                ? (kIsWeb
                                    ? Image.network(_profilePhoto!, fit: BoxFit.cover)
                                    : Image.file(File(_profilePhoto!), fit: BoxFit.cover))
                                : Icon(
                                    Icons.person_rounded,
                                    size: 64,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                  ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.surface, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              )
                            ]
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // İsim Alanı ve Düzenleme
                _isEditing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _nameController,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Adınız',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                              ),
                              onSubmitted: (_) => _saveName(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 28),
                            onPressed: _saveName,
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _nameController.text,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _isEditing = true),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 14),
                            ),
                          )
                        ],
                      ),

                const SizedBox(height: 6),
                Text(
                  'Günce ile yaşam yolculuğu',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 36),

                // İstatistik Kartları Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Toplam Anı',
                        value: '$totalEntries',
                        icon: Icons.book_rounded,
                        color: const Color(0xFF5A67D8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Günlük Seri',
                        value: '$currentStreak Gün',
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFED8936),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Detay Bilgiler Kartı
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                'Katılım Tarihi',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            joinDateStr,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
