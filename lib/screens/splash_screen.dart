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
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _slideUp;
  late Animation<double> _pulse;
  final LocalAuthentication auth = LocalAuthentication();
  bool _needsAuth = false;

  @override
  void initState() {
    super.initState();

    // Ana animasyon
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _slideUp = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // İkon nefes çekme animasyonu
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _ctrl.forward();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
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
      if (authenticated) _goToHome();
    } catch (_) {}
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, anim2) => const HomeScreen(),
        transitionsBuilder: (context, anim, anim2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 900),
      ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema rengini Hive'dan oku
    final profileBox = Hive.box('profile');
    final isDark = profileBox.get('isDarkMode', defaultValue: false) as bool;

    final bgColor = isDark ? const Color(0xFF10101F) : const Color(0xFF5A67D8); // Klasik Lavanta Indigo
    final textColor = Colors.white; 
    final subColor = Colors.white70;
    final accentColor = const Color(0xFF9F7AEA); // Lavanta Parıltısı

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Arka plan gradient leke efekti — Lavanta tonları
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: isDark ? 0.15 : 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Ana İçerik
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // İkon Alanı
                  GestureDetector(
                    onTap: _needsAuth ? _authenticateUser : null,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.04),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: _needsAuth
                              ? const Icon(Icons.fingerprint_rounded,
                                  color: Color(0xFF2D3748), size: 40)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Uygulama Adı
                  Text(
                    'günce',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Alt Başlık
                  Text(
                    _needsAuth
                        ? 'devam etmek için dokunun'
                        : 'yazdıkça büyürsün.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: subColor,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Yükleniyor indikatörü (ince çizgi)
                  if (!_needsAuth)
                    SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accentColor.withValues(alpha: 0.4),
                        ),
                        minHeight: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
