import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../utils/mood_colors.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _textController = TextEditingController();
  final _locationController = TextEditingController(); // Anı Haritası Altyapısı
  String? _imagePath;
  String? _selectedMood;
  bool _saving = false;

  final List<String> _moods = [
    'Harika', 'Mutlu', 'Huzurlu', 'Sakin', 'Odaklanmış', 
    'Düşünceli', 'Heyecanlı', 'Stresli', 'Yorgun', 'Hüzünlü'
  ];

  Future<void> _pickImageSource() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Fotoğraf Seç', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt_rounded, 'Kamera', ImageSource.camera),
                _buildSourceOption(Icons.photo_library_rounded, 'Galeri', ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pickImage(source);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor)
            ),
            child: Icon(icon, color: const Color(0xFF5A67D8), size: 32),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _save() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bugünü anlatacak bir şeyler yazmalısın.', style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    setState(() => _saving = true);
    final box = Hive.box<Entry>('entries');
    final entry = Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      text: _textController.text.trim(),
      imagePath: _imagePath,
      mood: _selectedMood,
      locationName: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
    );
    await box.add(entry);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMMM yyyy', 'tr').format(DateTime.now());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(today,
          style: GoogleFonts.outfit(
            fontSize: 16, letterSpacing: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w400)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '...' : 'Kaydet',
                style: GoogleFonts.outfit(color: const Color(0xFF5A67D8), fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Konum Alanı (Yeni Özellik)
            Text('Neredesin?',
              style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10, offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xFF9F7AEA), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Konum ekle (örn: Moda Sahil)',
                        hintStyle: GoogleFonts.outfit(color: const Color(0xFFB0B0B0), fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Ruh Hali Seçimi
            Text('Nasıl hissediyorsun?',
              style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? MoodColors.getColor(mood) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? MoodColors.getColor(mood) : Theme.of(context).dividerColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: MoodColors.getColor(mood).withOpacity(0.3),
                              blurRadius: 10, offset: const Offset(0, 4)
                            )
                        ]
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isSelected) ...[
                            Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: MoodColors.getColor(mood)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(mood,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            )
                          ),
                        ],
                      )
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Fotoğraf alanı
            GestureDetector(
              onTap: _pickImageSource,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                  image: _imagePath != null
                    ? DecorationImage(
                        image: kIsWeb 
                            ? NetworkImage(_imagePath!) as ImageProvider 
                            : FileImage(File(_imagePath!)),
                        fit: BoxFit.cover)
                    : null,
                ),
                child: _imagePath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF5A67D8), size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text('Fotoğraf Ekle',
                          style: GoogleFonts.outfit(
                            fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      ])
                  : null,
              ),
            ),

            const SizedBox(height: 32),

            // Cümle alanı
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                maxLength: 250,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500, height: 1.6),
                decoration: InputDecoration(
                  hintText: 'Bugünden aklında kalanlar...',
                  hintStyle: GoogleFonts.playfairDisplay(color: const Color(0xFFB0B0B0), fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  counterStyle: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 48), // Padding alt
          ]),
      ),
    );
  }
}