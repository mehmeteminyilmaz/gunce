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
  late Animation<double> _fade;
  late Animation<double> _slideUp;
  final LocalAuthentication auth = LocalAuthentication();
  bool _needsAuth = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 20, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    final profileBox = Hive.box('profile');
    bool isLockEnabled =
        profileBox.get('biometricEnabled', defaultValue: false);
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
        transitionDuration: const Duration(milliseconds: 700),
      ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg   = isDark ? const Color(0xFF151210) : const Color(0xFFF5F0E8);
    final fg   = isDark ? const Color(0xFFF0E6D3) : const Color(0xFF1C1C1E);
    final sub  = isDark ? const Color(0xFF8C7A62) : const Color(0xFF8C7A62);

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slideUp.value),
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Sol üst ince yatay çizgi — defter hissi
            Positioned(
              top: 60,
              left: 32,
              right: 32,
              child: Divider(color: sub.withAlpha(60), thickness: 1),
            ),

            // Ana içerik
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo ikonu — sade kutu
                    GestureDetector(
                      onTap: _needsAuth ? _authenticateUser : null,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: fg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: _needsAuth
                              ? Icon(Icons.fingerprint_rounded,
                                  color: bg, size: 28)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Uygulama adı
                    Text(
                      'günce.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        color: fg,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Alt başlık
                    Text(
                      _needsAuth
                          ? 'devam etmek için dokunun'
                          : 'yazdıkça büyürsün.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: sub,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Alt çizgi
            Positioned(
              bottom: 48,
              left: 32,
              child: Text(
                'Günce',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: sub.withAlpha(100),
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
