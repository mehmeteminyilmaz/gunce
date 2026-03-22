import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Box _profileBox = Hive.box('profile');
  final LocalAuthentication auth = LocalAuthentication();
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isBiometricEnabled = false;
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileBox.get('name', defaultValue: 'Gezgin'));
    _isBiometricEnabled = _profileBox.get('biometricEnabled', defaultValue: false);
    _isReminderEnabled = _profileBox.get('reminderEnabled', defaultValue: false);
    int rHour = _profileBox.get('reminderHour', defaultValue: 20);
    int rMinute = _profileBox.get('reminderMinute', defaultValue: 0);
    _reminderTime = TimeOfDay(hour: rHour, minute: rMinute);
  }

  Future<void> _saveName() async {
    await _profileBox.put('name', _nameController.text.trim());
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    await _profileBox.put('reminderEnabled', value);
    setState(() => _isReminderEnabled = value);
    
    if (value) {
      _scheduleReminder();
    } else {
      await NotificationService().cancelReminder(1);
    }
  }

  void _scheduleReminder() {
    NotificationService().scheduleDailyReminder(
      1,
      'Bugününü kaydettin mi?',
      'Günce\'ye hemen yeni bir anı ekle ve serini bozma 🔥',
      _reminderTime.hour, 
      _reminderTime.minute
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isSecure = await auth.isDeviceSupported();
      
      if (!isSecure && !canCheckBiometrics) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cihazınızda biyometrik güvenlik (FaceID/Parmak İzi) aktif değil.',
            style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: const Color(0xFF2D3142),
        ));
        return;
      }
      
      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Biyometrik kilidi aktif etmek için doğrulayın',
        );
        if (authenticated) {
          await _profileBox.put('biometricEnabled', true);
          setState(() => _isBiometricEnabled = true);
        }
      } catch (e) {
        // Hata (Cancel vs)
      }
    } else {
      await _profileBox.put('biometricEnabled', false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text('Profilim', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20, offset: const Offset(0, 10),
                        )
                      ]
                    ),
                    child: const Icon(Icons.person_rounded, size: 60, color: Color(0xFFE0E0E0)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7D9B76),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.outfit(fontSize: 24, color: const Color(0xFF2D3142)),
                        decoration: InputDecoration(
                          hintText: 'Adınız',
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7D9B76))),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF7D9B76), size: 32),
                      onPressed: _saveName,
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_nameController.text,
                      style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: const Icon(Icons.edit_rounded, color: Color(0xFF9E9E9E), size: 20),
                    )
                  ],
                ),
            
            const SizedBox(height: 8),
            Text('Günce ile yeni anılar biriktiriyor',
              style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF8E8E93))),
              
            const SizedBox(height: 48),
            
            // Kişisel Ayarlar ve İstatistikler
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
                border: Border.all(color: const Color(0xFFF4F1EA)),
              ),
              child: Column(
                children: [
                  // Biyometrik Kilit Ayarı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fingerprint_rounded, color: Color(0xFF2D3142), size: 24),
                          const SizedBox(width: 12),
                          Text('Biyometrik Kilit', style: GoogleFonts.outfit(color: const Color(0xFF2D3142), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Switch(
                        value: _isBiometricEnabled,
                        onChanged: _toggleBiometric,
                        activeColor: const Color(0xFF7D9B76),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFF4F1EA)),
                  // Günlük Hatırlatma Ayarı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: Color(0xFF2D3142), size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Günlük Hatırlatma', style: GoogleFonts.outfit(color: const Color(0xFF2D3142), fontWeight: FontWeight.w500)),
                              if (_isReminderEnabled)
                                GestureDetector(
                                  onTap: () async {
                                    final TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: _reminderTime,
                                    );
                                    if (picked != null && picked != _reminderTime) {
                                      setState(() => _reminderTime = picked);
                                      await _profileBox.put('reminderHour', picked.hour);
                                      await _profileBox.put('reminderMinute', picked.minute);
                                      _scheduleReminder();
                                    }
                                  },
                                  child: Text('${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.outfit(color: const Color(0xFF7D9B76), fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isReminderEnabled,
                        onChanged: _toggleReminder,
                        activeColor: const Color(0xFF7D9B76),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFF4F1EA)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Katılım Tarihi', style: GoogleFonts.outfit(color: const Color(0xFF8E8E93))),
                      Text('Bugün', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFF2D3142))),
                    ],
                  ),
                  const Divider(height: 32, color: Color(0xFFF4F1EA)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Veri Yedekleme', style: GoogleFonts.outfit(color: const Color(0xFF8E8E93))),
                      Text('Cihazda', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFF7D9B76))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
