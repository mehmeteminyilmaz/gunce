import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'models/entry.dart';
import 'screens/splash_screen.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');
  // Profil bilgileri için ayrı bir kutu açıyoruz (isim, avatar vb.)
  await Hive.openBox('profile');
  
  await NotificationService().init();

  runApp(const GunceApp());
}

class GunceApp extends StatelessWidget {
  const GunceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Günce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), // Krem/Kağıt Beyazı
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        colorScheme: const ColorScheme.light().copyWith(
          primary: const Color(0xFF7D9B76), // Adaçayı Yeşili
          secondary: const Color(0xFFFFB38E), // Pastel Şeftali
          surface: const Color(0xFFFFFFFF), // Beyaz Yüzeyler
          surfaceContainerHighest: const Color(0xFFF4F1EA), // Gri yerine çok açık bej
          onSurface: const Color(0xFF2D3142), // Koyu Gri Yazılar
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF2D3142)),
          titleTextStyle: TextStyle(color: Color(0xFF2D3142), fontSize: 18),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}