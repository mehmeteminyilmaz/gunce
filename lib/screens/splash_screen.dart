import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  final LocalAuthentication auth = LocalAuthentication();
  bool _needsAuth = false; // Biyometrik kilit varsa bekleyecek

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    final profileBox = Hive.box('profile');
    bool isLockEnabled = profileBox.get('biometricEnabled', defaultValue: false);

    if (isLockEnabled) {
      setState(() => _needsAuth = true);
      _authenticateUser();
    } else {
      _goToHome();
    }
  }

  Future<void> _authenticateUser() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Güncenize erişmek için kilidi açın',
      );
      if (authenticated) {
        _goToHome();
      }
    } catch (e) {
      // Hata veya reddetme durumu, ekranda kilit butonu görünmeye devam edecek.
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC), // Krem Arka Plan
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _needsAuth ? _authenticateUser : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: _needsAuth ? const Color(0xFF9F7AEA).withOpacity(0.3) : const Color(0xFF5A67D8).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(_needsAuth ? Icons.fingerprint_rounded : Icons.spa_rounded,
                          color: _needsAuth ? const Color(0xFF9F7AEA) : const Color(0xFF5A67D8), size: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('günce.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A202C),
                      letterSpacing: -1,
                    )),
                const SizedBox(height: 8),
                Text(_needsAuth ? 'kilidi açmak için dokunun' : 'anıların dinginliği.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF5A67D8),
                      letterSpacing: _needsAuth ? 1 : 3,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
