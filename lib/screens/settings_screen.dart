import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box _profileBox = Hive.box('profile');
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _isReminderEnabled = false;
  bool _isDarkMode = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _isBiometricEnabled = _profileBox.get('biometricEnabled', defaultValue: false);
    _isReminderEnabled = _profileBox.get('reminderEnabled', defaultValue: false);
    _isDarkMode = _profileBox.get('isDarkMode', defaultValue: false);
    int rHour = _profileBox.get('reminderHour', defaultValue: 20);
    int rMinute = _profileBox.get('reminderMinute', defaultValue: 0);
    _reminderTime = TimeOfDay(hour: rHour, minute: rMinute);
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
          backgroundColor: Theme.of(context).colorScheme.onSurface,
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
        // Hata
      }
    } else {
      await _profileBox.put('biometricEnabled', false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Ayarlar', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  // --- Karanlık Tema ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text('Karanlık Tema', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Switch(
                        value: _isDarkMode,
                        onChanged: (value) async {
                          await _profileBox.put('isDarkMode', value);
                          setState(() => _isDarkMode = value);
                        },
                        activeColor: const Color(0xFF5A67D8),
                      ),
                    ],
                  ),
                  Divider(height: 32, color: Theme.of(context).dividerColor),
                  // --- Biyometrik Kilit ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fingerprint_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24),
                          const SizedBox(width: 12),
                          Text('Biyometrik Kilit', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Switch(
                        value: _isBiometricEnabled,
                        onChanged: _toggleBiometric,
                        activeColor: const Color(0xFF5A67D8),
                      ),
                    ],
                  ),
                  Divider(height: 32, color: Theme.of(context).dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Günlük Hatırlatma', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                              if (_isReminderEnabled)
                                GestureDetector(
                                  onTap: () async {
                                    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _reminderTime);
                                    if (picked != null && picked != _reminderTime) {
                                      setState(() => _reminderTime = picked);
                                      await _profileBox.put('reminderHour', picked.hour);
                                      await _profileBox.put('reminderMinute', picked.minute);
                                      _scheduleReminder();
                                    }
                                  },
                                  child: Text('${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.outfit(color: const Color(0xFF5A67D8), fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isReminderEnabled,
                        onChanged: _toggleReminder,
                        activeColor: const Color(0xFF5A67D8),
                      ),
                    ],
                  ),
                  Divider(height: 32, color: Theme.of(context).dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Veri Yedekleme', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                      Text('Sadece Cihazda', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFF5A67D8))),
                    ],
                  ),
                  Divider(height: 32, color: Theme.of(context).dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Versiyon', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                      Text('v3.0.0 (Zen)', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
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
