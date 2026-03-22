import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'models/entry.dart';
import 'screens/splash_screen.dart';
import 'utils/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');
  await Hive.openBox('profile');
  await NotificationService().init();

  runApp(const GunceApp());
}

class GunceApp extends StatefulWidget {
  const GunceApp({super.key});

  @override
  State<GunceApp> createState() => _GunceAppState();
}

class _GunceAppState extends State<GunceApp> {
  late Timer _themeTimer;
  late bool _isNight;

  @override
  void initState() {
    super.initState();
    _isNight = AppTheme.isNightNow;

    // Her dakika saati kontrol edip gerekirse temayı değiştir
    _themeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final nowNight = AppTheme.isNightNow;
      if (nowNight != _isNight) {
        setState(() => _isNight = nowNight);
      }
    });
  }

  @override
  void dispose() {
    _themeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Günce',
      debugShowCheckedModeBanner: false,
      theme: _isNight ? AppTheme.dark : AppTheme.light,
      home: const SplashScreen(),
    );
  }
}