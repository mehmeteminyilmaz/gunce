import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/entry.dart';
import '../utils/mood_colors.dart';
import '../utils/gemini_service.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _textController = TextEditingController();
  final _locationController = TextEditingController(); 
  String? _imagePath;
  String? _selectedMood;
  String? _audioPath;
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool _isRecording = false;
  bool _gettingLocation = false;
  bool _isAnalyzingMood = false;
  bool _isLoadingQuestion = false;
  String? _aiQuestion;
  late AudioRecorder _audioRecorder;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    setState(() => _isLoadingQuestion = true);
    final question = await GeminiService.getReflectiveQuestion();
    if (mounted) {
      setState(() {
        _aiQuestion = question;
        _isLoadingQuestion = false;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String? path;
        
        // kIsWeb kontrolü (foundation importu kullanılarak)
        if (!kIsWeb) {
          try {
            final directory = await getApplicationDocumentsDirectory();
            path = p.join(directory.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');
          } catch (e) {
            debugPrint("Dizin alınamadı (Web tahmini): $e");
          }
        }
        
        // Web'de path boş bırakılırsa record paketi doğru çalışır
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.opus), path: path ?? '');
        setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint("Kayıt başlatılamadı: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      debugPrint("Kayıt durduruluyor...");
      final path = await _audioRecorder.stop();
      debugPrint("Kayıt durduruldu. Alınan Path: $path");
      
      setState(() {
        _isRecording = false;
        if (path != null) {
          _audioPath = path;
        }
      });
      
      if (path == null) {
        debugPrint("UYARI: Kayıt dosyası oluşturulamadı (Çok kısa süreli mi bastınız?).");
      }
    } catch (e) {
      debugPrint("Kayıt durdurulamadı Hatası: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Konum servisleri kapalı.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Konum izni reddedildi.';
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _gettingLocation = false;
      });
      debugPrint("Konum alındı: $_latitude, $_longitude");

      // Otomatik adres yakalama
      final address = await _getAddressFromLatLng(position.latitude, position.longitude);
      if (address != null && mounted) {
        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      debugPrint("Konum hatası: $e");
      setState(() => _gettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum alınamadı: $e'), backgroundColor: Colors.redAccent)
        );
      }
    }
  }

  Future<String?> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1');
      // Nominatim User-Agent kuralına uymak gerek: 'gunce-app'
      final response = await http.get(url, headers: {'User-Agent': 'gunce-diary-app'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        String name = '';
        if (address['suburb'] != null) name += address['suburb'] + ", ";
        if (address['city'] != null) name += address['city'];
        else if (address['province'] != null) name += address['province'];
        else if (address['country'] != null) name += address['country'];
        return name.isEmpty ? "Seçilen Konum" : name;
      }
    } catch (e) {
      debugPrint("Adres bulma hatası: $e");
    }
    return null;
  }

  Future<void> _showLocationPicker() async {
    LatLng? pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => _LocationPickerDialog(
        initialLocation: _latitude != null ? LatLng(_latitude!, _longitude!) : null,
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _latitude = pickedLocation.latitude;
        _longitude = pickedLocation.longitude;
      });
      // Otomatik adres bulma
      final address = await _getAddressFromLatLng(pickedLocation.latitude, pickedLocation.longitude);
      if (address != null && mounted) {
        setState(() {
          _locationController.text = address;
        });
      }
    }
  }

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
      audioPath: _audioPath,
      latitude: _latitude,
      longitude: _longitude,
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
            // AI Soru Kartı (Yeni)
            if (_aiQuestion != null || _isLoadingQuestion)
              _buildAIQuestionCard(),
            
            const SizedBox(height: 32),

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
                  IconButton(
                    icon: _gettingLocation 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.secondary))
                      : Icon(_latitude != null ? Icons.gps_fixed_rounded : Icons.my_location_rounded, 
                             color: _latitude != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
                    onPressed: _getCurrentLocation,
                    tooltip: 'O anki konumu otomatik al',
                  ),
                  IconButton(
                    icon: Icon(Icons.map_rounded, color: _latitude != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
                    onPressed: _showLocationPicker,
                    tooltip: 'Haritadan seç',
                  )
                ],
              ),
            ),
            if (_latitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 20),
                child: Text('Koordinatlar: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}', 
                  style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF5A67D8).withOpacity(0.7))),
              ),
            
            const SizedBox(height: 32),

            // Ruh Hali Seçimi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nasıl hissediyorsun?',
                  style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                // AI Analiz Butonu
                GestureDetector(
                  onTap: _isAnalyzingMood ? null : () async {
                    final text = _textController.text;
                    if (text.trim().length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Analiz için en az 10 karakter yazmalısın.',
                            style: GoogleFonts.outfit(color: Colors.white)),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    setState(() => _isAnalyzingMood = true);
                    try {
                      final mood = await GeminiService.analyzeMood(text);
                      setState(() {
                        _isAnalyzingMood = false;
                        if (mood != null) _selectedMood = mood;
                      });
                      if (!mounted) return;
                      if (mood != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('AI ruh halinizi "$mood" olarak belirledi.',
                              style: GoogleFonts.outfit(color: Colors.white)),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Metin anlaşılamadı, lütfen daha fazla yazın.',
                              style: GoogleFonts.outfit(color: Colors.white)),
                            backgroundColor: Colors.orange.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() => _isAnalyzingMood = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e',
                            style: GoogleFonts.outfit(color: Colors.white)),
                          backgroundColor: Colors.red.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isAnalyzingMood
                          ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isAnalyzingMood)
                          SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Theme.of(context).colorScheme.secondary),
                          )
                        else
                          Icon(Icons.auto_awesome_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 6),
                        Text(
                          _isAnalyzingMood ? 'Analiz ediliyor...' : 'AI ile Analiz Et',
                          style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                        color: isSelected ? MoodColors.getColor(mood) : Theme.of(context).colorScheme.surface,
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

            // Sesli Anı Kaydı
            Text('Sesli Anı',
              style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              onLongPressCancel: () => _stopRecording(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isRecording ? Colors.red : (_audioPath != null ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic_rounded : (_audioPath != null ? Icons.check_rounded : Icons.mic_none_rounded),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRecording ? 'Kayıt Yapılıyor...' : (_audioPath != null ? 'Sesli Anı Kaydedildi' : 'Kayıt için basılı tutun'),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: _isRecording ? Colors.red : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (_audioPath == null && !_isRecording)
                            Text('Düşüncelerini fısılda...', 
                              style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          if (_audioPath != null)
                            Text('Anına sesinle dokundun.', 
                              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF5A67D8).withOpacity(0.7))),
                        ],
                      ),
                    ),
                    if (_audioPath != null && !_isRecording)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () => setState(() => _audioPath = null),
                      ),
                  ],
                ),
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
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Icon(Icons.add_photo_alternate_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
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

  Widget _buildAIQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.08), Theme.of(context).colorScheme.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_alt_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('GÜNÜN SORUSU', 
                    style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              if (!_isLoadingQuestion)
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                  onPressed: _loadQuestion,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingQuestion)
            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF5A67D8)))
          else
            Text(
              _aiQuestion ?? 'Bugün üzerine düşünmek istediğin bir şey var mı?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface, height: 1.4),
            ),
        ],
      ),
    );
  }
}

class _LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  const _LocationPickerDialog({this.initialLocation});

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late LatLng _currentLocation;
  bool _pinSelected = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation ?? LatLng(39.1, 35.4); // Türkiye merkezi fallback
    _pinSelected = widget.initialLocation != null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _currentLocation,
                  initialZoom: 5.5,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _currentLocation = point;
                      _pinSelected = true;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (_pinSelected)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                        )
                      ],
                    ),
                ],
              ),
              Positioned(
                top: 16, right: 16,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 24, left: 24, right: 24,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A67D8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context, _currentLocation),
                  child: Text('Konumu Mühürle', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 16, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                  ),
                  child: Text('Haritada istediğin yere dokun.', style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}